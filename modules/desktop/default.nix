# Desktop Environment Configuration Module
# Handles X11, display managers, and desktop environment

{ config, pkgs, lib, ... }:

{
  # Desktop environment
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };

    # Video drivers - NVIDIA as primary, AMD as secondary
    videoDrivers = [ "nvidia" "amdgpu" ];
  };

  # Display and desktop managers
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome = {
    gnome-keyring.enable = true;
    sushi.enable = true;
  };

  # Force NVIDIA GPU usage globally for applications
  environment.sessionVariables = {
    # Force NVIDIA for OpenGL applications
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Prefer NVIDIA for Vulkan applications
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    # Force NVIDIA for PRIME offloading
    __NV_PRIME_RENDER_OFFLOAD = "1";
  };
}
