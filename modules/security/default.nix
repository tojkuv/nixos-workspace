# Security Configuration Module
# Handles sudo, PAM, AppArmor, and security settings

{ config, pkgs, lib, ... }:

{
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    
    sudo = {
      enable = true;
      wheelNeedsPassword = false;  # Development workstation - passwordless sudo for wheel group

      extraRules = [
        {
          users = [ "tojkuv" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" "SETENV" ];
            }
          ];
        }
      ];

      # Preserve environment variables for development tools
      extraConfig = ''
        Defaults env_keep += "NIX_LD NIX_LD_LIBRARY_PATH PATH"
        Defaults !authenticate
      '';
    };
    
    pam.services = {
      login.enableGnomeKeyring = true;
      passwd.enableGnomeKeyring = true;
    };
    
    apparmor = {
      enable = true;
      killUnconfinedConfinables = false;
    };
    
    # System limits for development workloads and container orchestration
    pam.loginLimits = [
      { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "soft"; item = "nproc"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nproc"; value = "1048576"; }
      { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
      { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
    ];
    
     # SSL/TLS Certificate Authority configuration
     # Note: Modern NixOS handles certificates automatically through NSS and p11-kit
     # No manual certificateFiles configuration needed
    
    # Enable user namespaces for better container and development flexibility
    allowUserNamespaces = true;
  };
  
  # Security overlay that blacklists CLI password managers
  nixpkgs.overlays = [
    (final: prev: {
      # Blacklist CLI password manager packages
      bitwarden-cli = throw "bitwarden-cli is BLOCKED for security reasons. Use Bitwarden GUI only.";
      bw = throw "bw (Bitwarden CLI) is BLOCKED for security reasons. Use Bitwarden GUI only.";
      rbw = throw "rbw (Bitwarden CLI) is BLOCKED for security reasons. Use Bitwarden GUI only.";
      
      # Block other CLI password managers
      pass = throw "pass (password-store) CLI is BLOCKED for security reasons. Use GUI password manager only.";
      gopass = throw "gopass CLI is BLOCKED for security reasons. Use GUI password manager only.";
      keeper-cli = throw "keeper-cli is BLOCKED for security reasons. Use GUI password manager only.";
      dashlane-cli = throw "dashlane-cli is BLOCKED for security reasons. Use GUI password manager only.";
      
      # Block additional password management CLI tools
      pwgen = throw "pwgen is BLOCKED for security reasons. Use secure password generation in GUI tools only.";
      keepassxc-cli = throw "keepassxc-cli is BLOCKED for security reasons. Use KeePassXC GUI only.";
      password-store = throw "password-store (pass) is BLOCKED for security reasons.";
    })
  ];
  
   # System-level environment variables to prevent CLI usage and fix SSL certificates
    environment.sessionVariables = {
      # Prevent common CLI password managers from being used
      BITWARDEN_CLI_DISABLED = "true";
      PASSWORD_STORE_DISABLED = "true";
      GOPASS_DISABLED = "true";
      ENTERPRISE_SECURITY_POLICY = "CLI_PASSWORD_MANAGERS_DISABLED";

      # Fix SSL certificate validation by setting the certificate file path
      SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    };
  
  # Add security notice to shell profiles
  environment.interactiveShellInit = ''
    # Ensure SSL certificate environment variables are loaded
    if [ -z "$SSL_CERT_FILE" ]; then
      . /etc/set-environment
    fi

    # Security notice function for blocked commands
    _security_block_notice() {
      echo "🔒 SECURITY POLICY: CLI password managers are disabled for enterprise security compliance."
      echo "Use GUI password managers only (Bitwarden GUI, 1Password GUI, etc.)"
      return 1
    }
    
    # Create blocking aliases for common CLI password manager commands
    alias bw='_security_block_notice'
    alias bitwarden-cli='_security_block_notice' 
    alias rbw='_security_block_notice'
    alias pass='_security_block_notice'
    alias gopass='_security_block_notice'
    alias op='_security_block_notice'
    alias pwgen='_security_block_notice'
    alias keepassxc-cli='_security_block_notice'
  '';
}