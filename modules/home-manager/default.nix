# Home Manager Module
# Declarative user-level configuration for dotfiles, shell, and home packages
# Enable by setting programs.home-manager.enable = true

{ config, lib, pkgs, ... }:

let
  cfg = config.programs.home-manager;
in
{
  options.programs.home-manager = {
    enable = lib.mkEnableOption "Home Manager for user configuration";

    enableZshIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zsh integration for Home Manager";
    };

    enableBashIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bash integration for Home Manager";
    };

    extraModules = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Additional Home Manager modules to import";
    };
  };

  config = lib.mkIf cfg.enable {
    # Home Manager requiresflakes and nix-command
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Create user directories for Home Manager
    users.users.tojkuv.home = "/home/tojkuv";

    # Home Manager installation script (run once by user)
    environment.systemPackages = [
      (pkgs.writeScriptBin "install-home-manager" ''
        #!/bin/sh
        # Install Home Manager for this user
        # Run this as the target user (not root)

        set -e

        if [ "$USER" = "root" ]; then
          echo "Error: Do not run as root. Run as your regular user."
          exit 1
        fi

        nix-shell -p home-manager --run "home-manager switch"

        echo "Home Manager installed successfully!"
        echo "Your dotfiles and user configuration are now managed by Home Manager."
      '')
    ];

    # Symlink system-wide files to user home (fallback for non-Home-Manager users)
    # These are managed by Home Manager when enabled
    environment.etc = {
      "bashrc".source = lib.mkIf cfg.enableBashIntegration (lib.mkDefault "/home/tojkuv/.bashrc");
      "zshrc".source = lib.mkIf cfg.enableZshIntegration (lib.mkDefault "/home/tojkuv/.zshrc");
      "profile".source = lib.mkIf cfg.enableBashIntegration (lib.mkDefault "/home/tojkuv/.profile");
    };

    # Provide guidance on using Home Manager
    warnings = lib.mkIf cfg.enable [
      ''
        Home Manager is enabled.
        Run 'install-home-manager' as user 'tojkuv' to install Home Manager.
        Then use 'home-manager switch' to apply user configuration.
      ''
    ];
  };
}
