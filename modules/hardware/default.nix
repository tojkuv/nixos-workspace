# Hardware Configuration Module
# Handles graphics, CPU, Bluetooth, power management, and GPU passthrough

{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.hardware.hybridGraphics = lib.mkOption {
    description = "Hybrid graphics configuration (AMD integrated primary, NVIDIA available for offload)";
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "hybrid graphics with AMD primary and NVIDIA offload";
        nvidiaBusId = lib.mkOption {
          type = lib.types.str;
          default = "PCI:1@0:0:0";
          description = "NVIDIA GPU bus ID (find with: lspci | grep -i nvidia)";
        };
        amdgpuBusId = lib.mkOption {
          type = lib.types.str;
          default = "PCI:0@0:1:0";
          description = "AMD GPU bus ID (find with: lspci | grep -i amd)";
        };
        sessionVariables = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Set system-wide GPU session variables (DRI_PRIME, etc.). Set to false to allow per-shell control via flake.nix/.envrc";
        };
      };
    };
  };

  options.virtualisation.gpuPassthrough = lib.mkOption {
    description = "GPU passthrough configuration for virtualization";
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "GPU passthrough for VM";
        primaryGpu = {
          vendor = lib.mkOption {
            type = lib.types.str;
            default = "10de";
            description = "Primary GPU vendor ID (10de = NVIDIA)";
          };
          device = lib.mkOption {
            type = lib.types.str;
            default = "2560";
            description = "Primary GPU device ID (2560 = RTX 3060 Mobile)";
          };
          audioDevice = lib.mkOption {
            type = lib.types.str;
            default = "228e";
            description = "Primary GPU audio device ID (228e = NVIDIA Audio)";
          };
        };
        fallbackGpu = {
          vendor = lib.mkOption {
            type = lib.types.str;
            default = "1002";
            description = "Fallback GPU vendor ID (1002 = AMD)";
          };
          device = lib.mkOption {
            type = lib.types.str;
            default = "1638";
            description = "Fallback GPU device ID (1638 = AMD Radeon Vega)";
          };
        };
      };
    };
  };

  config = {
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          mesa
          libva-vdpau-driver
          libvdpau-va-gl
          vulkan-tools
          vulkan-loader
        ];
      };

      nvidia = lib.mkIf (config.services.xserver.videoDrivers or [ ] == [ "nvidia" ]) {
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

    environment.sessionVariables = lib.mkMerge [
      (lib.mkIf config.hardware.hybridGraphics.enable {
        DRI_PRIME = "1";
      })
      (lib.mkIf (config.hardware.hybridGraphics.enable && config.hardware.hybridGraphics.sessionVariables)
        {
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
        }
      )
    ];

    environment.systemPackages = lib.mkIf config.hardware.hybridGraphics.enable [
      (pkgs.writeShellScriptBin "nvidia-offload" ''
        export __NV_PRIME_RENDER_OFFLOAD=1
        export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export __VK_LAYER_NV_optimus=NVIDIA_only
        exec "$@"
      '')
    ];

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 25;
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = lib.mkDefault "ondemand";
    };

    boot = {
      kernelModules = [
        "vhci-hcd"
        "usbip_core"
        "usbip_host"
      ];
      kernel.sysctl = {
        "dev.i915.perf_stream_paranoid" = "0";
      };
      kernelParams = lib.mkIf config.virtualisation.gpuPassthrough.enable [
        "vfio-pci.ids=10de:2560,10de:228e,100de:1638"
      ];
    };

    services.udev.packages = [
      pkgs.usbutils
      (pkgs.writeTextDir "etc/udev/rules.d/99-usb-devices.rules" ''
        SUBSYSTEM=="usb", MODE="0664", GROUP="users"
        SUBSYSTEM=="usb_device", MODE="0664", GROUP="users"
        SUBSYSTEM=="block", ENV{ID_BUS}=="usb", MODE="0664", GROUP="users"
        SUBSYSTEM=="usb", GROUP="libvirtd", MODE="0664"
        SUBSYSTEM=="usb_device", GROUP="libvirtd", MODE="0664"
      '')
    ];
  };
}
