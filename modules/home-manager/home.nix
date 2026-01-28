# Home Manager User Configuration
# This file defines user-level settings managed by Home Manager
# It is imported by modules/home-manager/default.nix

{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager settings
  home = {
    username = "tojkuv";
    homeDirectory = "/home/tojkuv";
    stateVersion = "25.05";
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
    ".bash_profile".text = ''
      # ~/.bash_profile: executed by bash login shells

      # Source .bashrc for interactive login shells
      if [ -f ~/.bashrc ]; then
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

  # Disable i18n input method to avoid fcitx5 package issues
  i18n.inputMethod.enable = lib.mkDefault false;

  # OpenCode installation via direct binary download
  # Runs during home-manager switch as the user
  home.activation.installOpenCode = ''
    INSTALL_DIR="$HOME/.opencode/bin"
    if ! command -v opencode >/dev/null 2>&1; then
      echo "Installing OpenCode..."
      mkdir -p "$INSTALL_DIR"

      arch=$(uname -m)
      case "$arch" in
        x86_64) target_arch="x64" ;;
        aarch64|arm64) target_arch="arm64" ;;
        *) echo "Unsupported architecture: $arch" >&2; exit 1 ;;
      esac

      version=$(/run/current-system/sw/bin/curl -sS https://api.github.com/repos/anomalyco/opencode/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
      if [ -z "$version" ]; then
        echo "Failed to fetch OpenCode version" >&2
        exit 1
      fi

      url="https://github.com/anomalyco/opencode/releases/download/v$version/opencode-linux-$target_arch.tar.gz"
      echo "Downloading OpenCode $version from $url"
      temp_dir=$(mktemp -d)
      export PATH="/run/current-system/sw/bin:$PATH"
      /run/current-system/sw/bin/curl -fsSL -o "$temp_dir/opencode.tar.gz" "$url"
      /run/current-system/sw/bin/tar -xzf "$temp_dir/opencode.tar.gz" -C "$temp_dir"
      mv "$temp_dir/opencode" "$INSTALL_DIR/opencode"
      chmod 755 "$INSTALL_DIR/opencode"
      rm -rf "$temp_dir"

      echo "OpenCode $version installed successfully to $INSTALL_DIR"
    else
      echo "OpenCode already installed"
    fi
  '';

  # Add OpenCode to PATH
  home.sessionVariables = {
    PATH = "$HOME/.opencode/bin:$PATH";
  };
}
