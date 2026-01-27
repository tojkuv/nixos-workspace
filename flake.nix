{
  description = "NixOS Development Workstation Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      customOverlays = import ./overlays { inherit nixpkgs; };
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

      overlays = customOverlays;

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          name = "nixos-config-dev";
          packages = with nixpkgs.legacyPackages.${system}; [
            nixfmt-rfc-style
            statix
            treefmt
            nil
          ];
          shellHook = ''
            echo "=== NixOS Config Development Shell ==="
            echo "Run 'nix fmt' to format all Nix files"
            echo "Run 'statix check' to lint Nix files"
            echo "Run 'nil --analysis .' for LSP diagnostics"
            echo "======================================"
          '';
        };
      });

      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      });
    };
}
