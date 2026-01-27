# Common library functions for NixOS modules
# Provides reusable helpers for module development

{ lib }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkMerge
    types
    ;
in
{
  inherit mkEnableOption;

  # Create an option with a description
  mkDesc =
    description:
    mkOption {
      inherit description;
    };

  # Create an option with a default value
  mkDefaultDesc =
    default: description:
    mkOption {
      inherit default description;
    };

  # Create a percentage option (0-100)
  mkPercentage =
    default: description:
    mkOption {
      type = types.percentage;
      inherit default description;
    };

  # Create a port option
  mkPort =
    default: description:
    mkOption {
      type = types.port;
      inherit default description;
    };

  # Create a path option
  mkPath =
    default: description:
    mkOption {
      type = types.path;
      inherit default description;
    };

  # Create a string option with regex validation
  mkStringMatch =
    regex: default: description:
    mkOption {
      type = types.strMatching regex;
      inherit default description;
    };

  # Package list helper - ensures all items are packages
  mkPackageList =
    description:
    mkOption {
      type = types.listOf types.package;
      default = [ ];
      inherit description;
    };

  # Systemd unit enable helper
  mkServiceEnable = serviceName: {
    enable = mkEnableOption "${serviceName} service";
  };

  # Common systemd timer options
  mkTimerOptions = {
    onCalendar = mkOption {
      type = types.str;
      default = "*-*-* *:00:00";
      description = "When to run the timer (systemd calendar format)";
    };
    persistent = mkOption {
      type = types.bool;
      default = false;
      description = "Run missed service on boot";
    };
  };

  # Network interface options
  mkNetworkInterface = {
    interface = mkOption {
      type = types.str;
      description = "Network interface name";
    };
    address = mkOption {
      type = types.str;
      description = "IP address with CIDR notation";
    };
    gateway = mkOption {
      type = types.str;
      description = "Default gateway";
    };
  };

  # GPU passthrough defaults for common cards
  gpuDefaults = {
    nvidia-3060 = {
      vendor = "10de";
      device = "2560";
      audioDevice = "228e";
    };
    amd-vega = {
      vendor = "1002";
      device = "1638";
    };
    intel-integrated = {
      vendor = "8086";
      device = "8a12";
    };
  };

  # Check for duplicate option declarations across modules
  # Usage: lib.custom.validateNoDuplicateOptions modules
  validateNoDuplicateOptions = modules:
    let
      allOptions = lib.foldl' (acc: module:
        acc // (lib.mapAttrs' (name: value:
          lib.nameValuePair "${module._file}:${name}" value
        ) (module.options or { }))
      ) { } modules;

      duplicates = lib.genAttrs (lib.attrNames (lib.groupBy (opt:
        lib.concatStringsSep ":" (lib.init (lib.splitString ":" opt))
      ) (lib.attrNames allOptions))) (key:
        lib.head (lib.getAttr key (lib.groupBy (opt:
          lib.concatStringsSep ":" (lib.init (lib.splitString ":" opt))
        ) (lib.attrNames allOptions)))
      );

      duplicatesList = lib.attrNames (lib.filter (count: count > 1) (lib.mapAttrs (name: value: lib.length value) (lib.groupBy (opt:
        lib.concatStringsSep ":" (lib.init (lib.splitString ":" opt))
      ) (lib.attrNames allOptions))));

      result = if duplicatesList == [ ] then [ ] else duplicatesList;
    in
    if result == [ ] then
      true
    else
      throw "Duplicate options found: ${lib.concatStringsSep ", " result}";

  # Validate module imports exist
  validateImports = modules:
    let
      checked = lib.foldl' (acc: module:
        let
          file = module._file or "unknown";
          imports = (module.config or { }).imports or [ ];
          existingImports = builtins.filter (imp:
            builtins.pathExists (if builtins.isPath imp then imp else imp)
          ) imports;
          missingImports = builtins.filter (imp:
            !builtins.elem imp existingImports
          ) imports;
        in
        acc // { ${file} = missingImports; }
      ) { } modules;
      missing = lib.concatStringsSep ", " (lib.attrValues (lib.filter (v: v != [ ]) checked));
    in
    if missing == "" then true else throw "Missing imports: ${missing}";

  # Check for common anti-patterns in modules
  checkModuleHealth = module:
    let
      file = module._file or "unknown";
      issues = [ ];

      # Check for rec { }
      hasRec = builtins.match "rec\s*{" (builtins.toJSON module) != null;

      # Check for with pkgs
      hasWithPkgs = builtins.match "(^|\n)\s*with\s+[^;]*pkgs" (builtins.toJSON module) != null;

      # Check for hardcoded paths
      hasHardcodedPaths = builtins.match "/home/[a-zA-Z0-9_-]+" (builtins.toJSON module) != null;

      allIssues = builtins.concatLists [
        (if hasRec then [ "Uses 'rec { }' instead of 'let ... in'" ] else [ ])
        (if hasWithPkgs then [ "Uses 'with pkgs' instead of explicit imports" ] else [ ])
        (if hasHardcodedPaths then [ "Contains hardcoded home directory paths" ] else [ ])
      ];
    in
    if allIssues == [ ] then true else throw "Module ${file} has issues: ${lib.concatStringsSep ", " allIssues}";
}
