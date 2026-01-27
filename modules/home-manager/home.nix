# Home Manager User Configuration
# This file defines user-level settings managed by Home Manager
# It is imported by modules/home-manager/default.nix

{ config, pkgs, lib, ... }:

{
  # Home Manager settings
  home = {
    username = "tojkuv";
    homeDirectory = "/home/tojkuv";
    stateVersion = "25.05";
    profileDirectory = ".profile";
  };

  # Disable version mismatch warning (we use unstable nixpkgs)
  home.enableNixpkgsReleaseCheck = false;

  # Enable bash integration
  programs.bash = {
    enable = true;
    initExtra = ''
      # Source system-wide environment
      if [ -f /etc/profile ]; then
        . /etc/profile
      fi

      # Nix shell environment
      if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Starship prompt
      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init bash)"
      fi
    '';
  };

  # Enable zsh integration
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Source system-wide environment
      if [ -f /etc/profile ]; then
        . /etc/profile
      fi

      # Nix shell environment
      if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Starship prompt
      if command -v starship >/dev/null 2>&1; then
        eval "$(starship init zsh)"
      fi
    '';
  };

  # User environment variables
  home.sessionVariables = {
    # Enable Wayland for Firefox
    MOZ_ENABLE_WAYLAND = "1";

    # DRI for GPU passthrough
    DRI_PRIME = "1";

    # SSL certificates
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";

    # Editor preferences
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";

    # Terminal improvements
    TERM = "xterm-256color";
    COLORTERM = "truecolor";

    # XDG directories
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";

    # History settings
    HISTSIZE = "100000";
    HISTFILESIZE = "100000";
    HISTCONTROL = "ignoreboth:erasedups";

    # Git settings
    GIT_PAGER = "delta";
  };

  # Home Manager file links for system files
  home.file = {
    ".profile".text = ''
      # ~/.profile: executed by the command interpreter for login shells.

      # Source nix-shell environment
      if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # Source user's bashrc
      if [ -n "$BASH_VERSION" ] && [ -f ~/.bashrc ]; then
        . ~/.bashrc
      fi
    '';
  };

  # Packages for user environment
  home.packages = with pkgs; [
    # Terminal utilities
    ripgrep
    fd
    bat
    eza
    fzf
    jq
    yq
    htop
    btop
    tokei

    # Git tools
    git
    delta
    lazygit

    # File managers
    ranger
    nnn

    # Starship prompt
    starship

    # Shell completions
    fish
    zsh-completions
  ];

  # XDG mimeapps - force overwrite to avoid conflicts
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "nvim.desktop" ];
    "application/x-shellscript" = [ "nvim.desktop" ];
    "text/x-shellscript" = [ "nvim.desktop" ];
  };

  # Disable i18n to avoid fcitx5 package issues
  i18n.inputMethod.enabled = "none";
}
