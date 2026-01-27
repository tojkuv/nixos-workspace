# Security Configuration Module
# Handles sudo, PAM, AppArmor, and security settings

{ config, pkgs, lib, ... }:

{

  security = {
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = false;

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

    pam.loginLimits = [
      { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
      { domain = "*"; type = "soft"; item = "nproc"; value = "1048576"; }
      { domain = "*"; type = "hard"; item = "nproc"; value = "1048576"; }
      { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
      { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
    ];

    allowUserNamespaces = true;
  };

  environment.sessionVariables = {
    BITWARDEN_CLI_DISABLED = "true";
    PASSWORD_STORE_DISABLED = "true";
    GOPASS_DISABLED = "true";
    ENTERPRISE_SECURITY_POLICY = "CLI_PASSWORD_MANAGERS_DISABLED";
    SSL_CERT_FILE = "/etc/ssl/certs/ca-bundle.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
  };

  environment.interactiveShellInit = ''
    _security_block_notice() {
      echo "SECURITY POLICY: CLI password managers are disabled for enterprise security compliance."
      echo "Use GUI password managers only (Bitwarden GUI, 1Password GUI, etc.)"
      return 1
    }

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
