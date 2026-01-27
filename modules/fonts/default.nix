# Fonts Configuration Module
# Handles system fonts and font rendering

{ config, pkgs, lib, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    
    packages = [
      # Professional coding fonts
      pkgs.nerd-fonts.fira-code
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.hack
      pkgs.nerd-fonts.sauce-code-pro
      pkgs.nerd-fonts.victor-mono
      pkgs.nerd-fonts.ubuntu-mono
      
      # System fonts
      pkgs.dejavu_fonts
      pkgs.liberation_ttf
      pkgs.noto-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-color-emoji
      
      # Professional presentation fonts
      pkgs.source-sans-pro
      pkgs.source-serif-pro
      pkgs.inter
    ];
    
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      
      hinting = {
        enable = true;
        style = "slight";
        autohint = false;
      };
      
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      
      defaultFonts = {
        monospace = [ "JetBrains Mono" "FiraCode Nerd Font" ];
        sansSerif = [ "Inter" "Source Sans Pro" ];
        serif = [ "Source Serif Pro" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}