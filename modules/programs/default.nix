# Browser Configuration Module
# Handles browser packages and settings

{ config, pkgs, lib, ... }:

{
  # Browser-specific packages
  environment.systemPackages = with pkgs; [
    # Browser development tools
    firefox-devedition           # Developer Edition for advanced users
  ];

  # Font configuration for better browser rendering
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    jetbrains-mono
  ];
}