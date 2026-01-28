# Environment Variables Configuration Module
# Centralized management of all session environment variables
# Uses environment.sessionVariables to ensure variables are available in user sessions

{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.sessionVariables = {
    # GPU and Graphics Configuration (controlled by hardware module for hybrid GPU)
    EGL_PLATFORM = "wayland";

    # Firefox Wayland optimizations
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    MOZ_WEBRENDERER = "1";
    MOZ_ACCELERATED = "1";

    # Browser stability settings
    NO_AT_BRIDGE = "1";
    GTK_USE_PORTAL = "1";

    # Electron/Chromium settings
    ELECTRON_IS_DEV = "0";

    # Development Tool Configuration
    # PKG_CONFIG_PATH for development libraries
    PKG_CONFIG_PATH = "${pkgs.wayland.dev}/lib/pkgconfig:${pkgs.libxkbcommon.dev}/lib/pkgconfig:${pkgs.alsa-lib.dev}/lib/pkgconfig:${pkgs.udev.dev}/lib/pkgconfig";

    # Security and SSL Configuration
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";

    # Enterprise Security Policy - CLI Password Managers Disabled
    BITWARDEN_CLI_DISABLED = "true";
    PASSWORD_STORE_DISABLED = "true";
    GOPASS_DISABLED = "true";
    ENTERPRISE_SECURITY_POLICY = "CLI_PASSWORD_MANAGERS_DISABLED";
  }
  // lib.optionalAttrs config.hardware.hybridGraphics.enable {
    # Only set MESA_LOADER_DRIVER_OVERRIDE when using hybrid graphics
    # Set to "radeonsi" for AMD driver, or leave unset for auto-detection
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };
}
