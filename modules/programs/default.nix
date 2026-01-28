# Browser Configuration Module
# Handles browser packages and settings

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Browser-specific packages and CLI tools
  environment.systemPackages = [
    pkgs.firefox-devedition
  ];

  # Font configuration for better browser rendering
  fonts.packages = [
    pkgs.noto-fonts
    pkgs.fira-code
    pkgs.jetbrains-mono
  ];

  # Direnv for automatic shell environment activation
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  # Add OpenCode to PATH for all users (login shells)
  environment.etc."profile.local".text = ''
    # OpenCode PATH
    export PATH="$HOME/.opencode/bin:$PATH"
  '';

  # Add OpenCode to PATH for interactive non-login shells
  environment.etc."bashrc.local".text = ''
    # OpenCode PATH
    export PATH="$HOME/.opencode/bin:$PATH"
  '';
}
