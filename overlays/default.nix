# Custom package overlays for NixOS configuration
# These overlays are applied on top of nixpkgs to modify packages
# Usage: Add to flake.nix or import directly

{ nixpkgs }:
let
  # Security overlay - block problematic packages at build time
  securityOverlay = final: prev: {
    bitwarden-cli = throw "bitwarden-cli is BLOCKED. Use Bitwarden GUI only.";
    bw = throw "bw (Bitwarden CLI) is BLOCKED. Use Bitwarden GUI only.";
    rbw = throw "rbw (Bitwarden CLI) is BLOCKED. Use Bitwarden GUI only.";
    pass = throw "pass (password-store) CLI is BLOCKED. Use GUI password manager only.";
    gopass = throw "gopass CLI is BLOCKED. Use GUI password manager only.";
    keeper-cli = throw "keeper-cli is BLOCKED. Use GUI password manager only.";
    dashlane-cli = throw "dashlane-cli is BLOCKED. Use GUI password manager only.";
    pwgen = throw "pwgen is BLOCKED. Use secure password generation in GUI tools only.";
    keepassxc-cli = throw "keepassxc-cli is BLOCKED. Use KeePassXC GUI only.";
    password-store = throw "password-store (pass) is BLOCKED.";
  };

in
{
  inherit securityOverlay;
}
