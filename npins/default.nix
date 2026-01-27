# This file provides nixpkgs pinned by npins
# To update: nix-shell -p npins --run "npins update"

let
  sourcesJson = builtins.readFile ./sources.json;
  sources = builtins.fromJSON sourcesJson;

  nixpkgsData = sources.entries.nixpkgs;
  fetchNixpkgs = { revision, url, sha256 }:
    builtins.fetchTarball {
      inherit url sha256;
      name = "nixpkgs-${revision}";
    };
in
{
  nixpkgs = (builtins.removeAttrs nixpkgsData ["type"]) // {
    outPath = fetchNixpkgs {
      inherit (nixpkgsData) revision url sha256;
    };
  };
}
