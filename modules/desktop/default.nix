# Desktop Environment Configuration Module
# Handles X11, display managers, and desktop environment

{ config, pkgs, lib, ... }:

{
  services = {
    xserver = {
      enable = true;

      xkb = {
        layout = "us";
        variant = "";
      };

      videoDrivers = [ "amdgpu" ];
    };

    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    gnome = {
      gnome-keyring.enable = true;
      sushi.enable = true;

      gnome-settings-daemon.enable = true;
    };
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

  # Configure default applications and MIME types
  environment.systemPackages = [
    pkgs.xdg-utils
  ];

  # Set up default applications
  xdg = {
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
      ];
    };
  };
}
