# Development shell for NixOS configuration
# Use: nix-shell or direnv

{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = { };
    overlays = [ ];
  } }:
pkgs.mkShellNoCC {
  name = "nixos-config-development";

  packages = [
    # NixOS rebuilding and management
    pkgs.nixos-rebuild
    pkgs.nixos-version
    pkgs.nixos-generators

    # Nix exploration and debugging
    pkgs.nix-tree
    pkgs.nix-index
    pkgs.nix-diff
    pkgs.nix-visualize
    pkgs.nix-top-opt
    pkgs.nix-health

    # Configuration analysis
    pkgs.nix-output-monitor
    pkgs.nvd

    # Git and development tools
    pkgs.git
    pkgs.delta

    # Text editors and formatters
    pkgs.statix
    pkgs.nixfmt-rfc-style
    pkgs.nixpkgs-fmt
  ];

  shellHook = ''
    export NIXOS_CONFIG="${pkgs.path}/nixos"
    echo "=== NixOS Config Development Shell ==="
    echo "Useful commands:"
    echo "  nixos-rebuild switch --flake .#dev-workstation"
    echo "  nix flake update"
    echo "  nix tree refs ./configuration.nix"
    echo "  nvd diff /run/current-system"
    echo "======================================"
  '';
}
