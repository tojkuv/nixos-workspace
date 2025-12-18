# Users Configuration Module  
# Handles user accounts and SSH configuration

{ config, pkgs, lib, ... }:

{
  users = {
    mutableUsers = false;
    
    users.tojkuv = {
      isNormalUser = true;
      description = "Tojkuv";
      extraGroups = [
        "wheel" "networkmanager" "podman" "kvm" "libvirtd"
        "audio" "video" "input" "storage" "adbusers" "waydroid"
      ];
      shell = pkgs.bash;
      
      openssh.authorizedKeys.keys = [
        # Add your SSH keys here for automation
      ];
      
       hashedPassword = "$6$BaLzSjEpHY5o1U8b$kyjm0KGrKdal4MnYmqIhWkxrl7xI6W0dEy9oKMs1JcSaYv9TtQKzFBl0Q2xluyrW/ls1jolLGZz/xmmk8HlIH.";
    };
  };
}