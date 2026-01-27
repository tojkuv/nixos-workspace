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
