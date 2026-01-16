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

    # Configure GNOME settings
    gnome-settings-daemon.enable = true;
  };

  # Set Chromium as default browser in GNOME
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/applications/browser" = {
        exec = "chromium";
        needs-terminal = false;
      };
      "org/gnome/desktop/url-handlers/http" = {
        enabled = true;
        exec = "chromium %s";
        needs-terminal = false;
      };
      "org/gnome/desktop/url-handlers/https" = {
        enabled = true;
        exec = "chromium %s";
        needs-terminal = false;
      };
      "org/gnome/desktop/url-handlers/about" = {
        enabled = true;
        exec = "chromium %s";
        needs-terminal = false;
      };
    };
  }];

  # Force NVIDIA GPU usage globally for applications
  environment.sessionVariables = {
    # Force NVIDIA for OpenGL applications
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Prefer NVIDIA for Vulkan applications
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    # Force NVIDIA for PRIME offloading
    __NV_PRIME_RENDER_OFFLOAD = "1";

    # Ensure proper browser integration
    BROWSER = "chromium";
  };

  # Configure default applications and MIME types
  environment.systemPackages = with pkgs; [
    xdg-utils  # For xdg-open and other desktop integration tools
  ];

  # Set up default applications
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
      ];
    };
  };
}
