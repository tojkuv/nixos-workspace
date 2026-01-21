# Hardware Configuration Module
# Handles graphics, CPU, Bluetooth, and power management

{ config, pkgs, lib, ... }:

{
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        mesa
        libva-vdpau-driver
        libvdpau-va-gl
      ] ++ lib.optionals (config.services.xserver.videoDrivers or [] == [ "nvidia" ]) [
        nvidia-vaapi-driver
      ];
    };

    # Nvidia configuration - NVIDIA as primary GPU
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
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
}