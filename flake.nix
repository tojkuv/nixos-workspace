{
  description = "NixOS Development Workstation Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Import custom overlays as a set
      customOverlays = import ./overlays { inherit nixpkgs; };

      # Convert overlay set to list for module import
      overlayList = builtins.attrValues customOverlays;
    in
    {
      # Shared nix configuration for all nix tools
      nixConfig = {
        experimental-features = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
        auto-optimise-store = true;
        max-jobs = "auto";
        cores = 0;
        keep-outputs = true;
        keep-derivations = true;
        builders-use-substitutes = true;
        fallback = false;
        accept-flake-config = true;
        warn-dirty = false;
        allow-import-from-derivation = true;
        sandbox = true;
        restrict-eval = false;
        substituters = [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://devenv.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        ];
        trusted-users = [ "root" "tojkuv" ];
        allowed-users = [ "@wheel" ];
      };

      nixosConfigurations = {
        dev-workstation = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            { nixpkgs.overlays = overlayList; }
          ];
        };
      };

      # Expose overlays for external use as a set
      overlays = customOverlays;

      # Development shell for nix development
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          name = "nixos-config-dev";
          packages = with nixpkgs.legacyPackages.${system}; [
            nixfmt-rfc-style
            statix
            treefmt
          ];
          shellHook = ''
            echo "=== NixOS Config Development Shell ==="
            echo "Run 'nix fmt' to format all Nix files"
            echo "Run 'statix check' to lint Nix files"
            echo "======================================"
          '';
        };
      });

      # Default package for nix fmt
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
