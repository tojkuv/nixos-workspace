# Formatter configuration for treefmt
# Use: nix fmt or treefmt

{
  # Use nixfmt-rfc-style as the primary Nix formatter
  # Alternative: nixpkgs-fmt, alejandra
  
  settings.formatter = {
    # Nix files
    nix = {
      command = "nixfmt";
      options = [ "--RFC-style" ];
    };
    
    # EditorConfig files
    editorconfig = {
      command = "editorconfig-checker";
      options = [ "-lint" ];
    };
    
    # Shell scripts
    sh = {
      command = "shfmt";
      options = [ "-i" "2" "-ci" "-sr" ];
    };
    
    # Markdown
    md = {
      command = "markdownlint";
      options = [ "--disable" "MD013" "MD033" ];
    };
    
    # YAML
    yaml = {
      command = "yamlfmt";
      options = [ "-indentation" "2" ];
    };
    
    # JSON
    json = {
      command = "jq";
      options = [ "--indent" "2" "--monochrome-output" ];
    };
  };
}
