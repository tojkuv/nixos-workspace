# Integration tests for critical system services
# Run with: nix-instantiate --eval tests.nix or use make test-integration

{ config, pkgs, lib, ... }:

let
  inherit (lib) types;
in
{
  options = {
    tests = {
      enable = lib.mkEnableOption "Integration tests for critical services";

      # Network connectivity test
      networkConnectivity = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Test basic network connectivity";
      };

      # Service health checks
      serviceHealth = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Check that critical services are running";
      };

      # GPU availability test
      gpuAvailable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Test GPU detection and drivers";
      };
    };
  };

  config = lib.mkIf config.tests.enable {
    # Test utilities and scripts
    environment.systemPackages = [
      # Test runner script
      (pkgs.writeScriptBin "nixos-test-runner" ''
        #!/usr/bin/env bash
        ${pkgs.writeText "test-script" (builtins.readFile ./run-tests.sh)}
        bash "$1"
      '')
    ];
  };
}
