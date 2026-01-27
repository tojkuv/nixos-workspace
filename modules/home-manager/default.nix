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
    # Home Manager requires flakes and nix-command
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Home Manager configuration
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      users.tojkuv = import ./home.nix;
    };

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

        # First time install - use backup mode to handle existing files
        nix-shell -p home-manager --run "home-manager switch -b backup"

        echo "Home Manager installed successfully!"
        echo "Your dotfiles and user configuration are now managed by Home Manager."
        echo "Existing files were backed up with '.backup' extension."
      '')
    ];

    # Remove symlinks to user config files (now managed by Home Manager)
    # This prevents conflicts between system /etc and user ~/.config
    environment.etc = lib.mkIf cfg.enableBashIntegration {
      "profile".source = lib.mkDefault "/home/tojkuv/.profile";
    } // lib.mkIf cfg.enableZshIntegration {
      "zshrc".source = lib.mkDefault "/home/tojkuv/.zshrc";
    };

    # Provide guidance on using Home Manager
    warnings = lib.mkIf cfg.enable [
      ''
        Home Manager is enabled.
        Run 'install-home-manager' as user 'tojkuv' to install Home Manager.
        Existing files will be backed up with '.backup' extension.
      ''
    ];
  };
}
