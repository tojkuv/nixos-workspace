# Hardware Configuration Module
# Handles graphics, CPU, Bluetooth, power management, and GPU passthrough

{ config, pkgs, lib, ... }:

{
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

        extraPackages = [
          pkgs.mesa
          pkgs.libva-vdpau-driver
          pkgs.libvdpau-va-gl
        ] ++ lib.optionals (config.services.xserver.videoDrivers or [] == [ "nvidia" ] && !config.virtualisation.gpuPassthrough.enable) [
          pkgs.nvidia-vaapi-driver
        ];
      };

      nvidia = lib.mkIf (!config.virtualisation.gpuPassthrough.enable && config.services.xserver.videoDrivers or [] == [ "nvidia" ]) {
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
      kernelModules = [ "vhci-hcd" "usbip_core" "usbip_host" ];
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