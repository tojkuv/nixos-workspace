# Hardware Configuration Module
# Handles graphics, CPU, Bluetooth, power management, and GPU passthrough

{ config, pkgs, lib, ... }:

let
  cfg = config.virtualisation.gpuPassthrough;
in

{
  options.virtualisation.gpuPassthrough = {
    enable = lib.mkEnableOption "GPU passthrough for VM";
    primaryGpu = {
      vendor = lib.mkOption {
        type = lib.types.str;
        default = "10de"; # NVIDIA
        description = "Primary GPU vendor ID";
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = "2560"; # RTX 3060 Mobile
        description = "Primary GPU device ID";
      };
      audioDevice = lib.mkOption {
        type = lib.types.str;
        default = "228e"; # NVIDIA Audio
        description = "Primary GPU audio device ID";
      };
    };
    fallbackGpu = {
      vendor = lib.mkOption {
        type = lib.types.str;
        default = "1002"; # AMD
        description = "Fallback GPU vendor ID";
      };
      device = lib.mkOption {
        type = lib.types.str;
        default = "1638"; # AMD Radeon Vega
        description = "Fallback GPU device ID";
      };
    };
  };

  config = lib.mkMerge [
    {
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
        libva-vdpau-driver
        libvdpau-va-gl
      ] ++ lib.optionals (config.services.xserver.videoDrivers or [] == [ "nvidia" ] && !config.virtualisation.gpuPassthrough.enable) [
        nvidia-vaapi-driver
      ];
    };


    # Only configure NVIDIA if GPU passthrough is disabled
    nvidia = lib.mkIf (!config.virtualisation.gpuPassthrough.enable) {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };



  # Performance optimizations
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "ondemand";
  };

    # USB device passthrough configuration (COMMENTED OUT GPU PASSTHROUGH)
    # Enable USB kernel modules for virtualization
    boot.kernelModules = [ "vhci-hcd" "usbip_core" "usbip_host" ];

  # Udev rules packages - cleaner approach than extraRules
  services.udev.packages = with pkgs; [
    usbutils
    
    # USB device permissions rules
    (pkgs.writeTextDir "etc/udev/rules.d/99-usb-devices.rules" ''
      # Grant access to USB devices for users group
      SUBSYSTEM=="usb", MODE="0664", GROUP="users"
      SUBSYSTEM=="usb_device", MODE="0664", GROUP="users"
      
      # Specific rules for USB storage devices
      SUBSYSTEM=="block", ENV{ID_BUS}=="usb", MODE="0664", GROUP="users"
      
      # Allow libvirtd group to access all USB devices
      SUBSYSTEM=="usb", GROUP="libvirtd", MODE="0664"
      SUBSYSTEM=="usb_device", GROUP="libvirtd", MODE="0664"
    '')
  ];

    # GPU passthrough configuration
    boot.kernelParams = lib.optionals cfg.enable [
      # Enable IOMMU for device passthrough
      "intel_iommu=on"
      "amd_iommu=on" 
      "iommu=pt"
      
      # Isolate devices for VM security
      #"isolcpus=1"
      
      # PCI settings for GPU passthrough
      "pci=realloc,hpiosize=4096"
      
      # VFIO device IDs for NVIDIA GPU
      "vfio-pci.ids=${cfg.primaryGpu.vendor}:${cfg.primaryGpu.device},${cfg.primaryGpu.vendor}:${cfg.primaryGpu.audioDevice}"
    ];
    


    # Blacklist conflicting drivers
    boot.blacklistedKernelModules = lib.optionals cfg.enable [
      "nouveau"  # Prevent nouveau from loading NVIDIA GPU
      "nvidia"    # Prevent nvidia driver from loading
      "nvidia_drm" # Prevent nvidia DRM from loading
    ];

    # Early kernel module loading for VFIO - CRITICAL for proper binding
    boot.initrd.kernelModules = lib.optionals cfg.enable [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    
    # Ensure VFIO modules load before any graphics drivers
    boot.initrd.preDeviceCommands = lib.mkIf cfg.enable ''
      modprobe vfio_pci
      modprobe vfio
      modprobe vfio_iommu_type1
    '';

    # Scripts for GPU switching
    environment.systemPackages = lib.optionals cfg.enable (with pkgs; [
      (pkgs.writeShellScriptBin "gpu-to-vm" ''
        #!/usr/bin/env bash
        echo "Preparing GPU for VM passthrough..."
        
        # Unload conflicting modules
        sudo rmmod nvidia_drm nvidia nouveau 2>/dev/null || true
        sudo rmmod nvidia_uvm nvidia_modeset 2>/dev/null || true
        
        # Bind GPU to VFIO
        echo "10de 2560" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || true
        echo "10de 228e" | sudo tee /sys/bus/pci/drivers/vfio-pci/new_id 2>/dev/null || true
        
        echo "GPU prepared for VM passthrough"
      '')
      
      (pkgs.writeShellScriptBin "gpu-to-host" ''
        #!/usr/bin/env bash
        echo "Returning GPU to host..."
        
        # Unbind from VFIO
        echo "0000:01:00.0" | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
        echo "0000:01:00.1" | sudo tee /sys/bus/pci/drivers/vfio-pci/unbind 2>/dev/null || true
        
        # Remove VFIO binding
        echo "10de 2560" | sudo tee /sys/bus/pci/drivers/vfio-pci/remove_id 2>/dev/null || true
        echo "10de 228e" | sudo tee /sys/bus/pci/drivers/vfio-pci/remove_id 2>/dev/null || true
        
        # Reload NVIDIA driver
        sudo modprobe nvidia nvidia_drm modeset=1
        
        echo "GPU returned to host"
      '')
    ]);
  }
  ];
}