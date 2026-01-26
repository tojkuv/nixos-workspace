# Browser Configuration Module
# Handles environment variables and settings for different browsers

{ config, pkgs, lib, ... }:

{
  environment.sessionVariables = {
    # Force AMD GPU usage globally (Solution 1: Explicit GPU Selection)
    DRI_PRIME = "1";                    # Use primary GPU (AMD)
    __GLX_VENDOR_LIBRARY_NAME = "mesa";  # Force Mesa over NVIDIA
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi"; # Force AMD driver
    EGL_PLATFORM = "wayland";             # Explicit Wayland EGL
    
    # Firefox Wayland optimizations with AMD GPU
    MOZ_ENABLE_WAYLAND = "1";          # Keep Wayland
    MOZ_DISABLE_RDD_SANDBOX = "1";     # Already working
    MOZ_WEBRENDERER = "1";              # Re-enable WebRender with AMD
    MOZ_ACCELERATED = "1";              # Re-enable acceleration with AMD
    
    # General browser stability
    NO_AT_BRIDGE = "1";                # Prevent assistive tech conflicts
    GTK_USE_PORTAL = "1";             # Use native file dialogs
    
    # Chromium-based browsers (Edge) fixes
    ELECTRON_IS_DEV = "0";
    CHROME_WRAPPER = "microsoft-edge";
  };
  
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