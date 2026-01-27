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
}
