# Browser Configuration Module
# Handles browser packages and settings

{ config, pkgs, lib, ... }:

{
  # Browser-specific packages
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
}