# Module Helpers Library

This directory contains reusable helper functions for NixOS module development.

## Usage

Import the helpers in your module:

```nix
{ lib, ... }:
let
  helpers = import ../lib { inherit lib; };
in
{
  options.myOption = helpers.mkPort 8080 "Service port";
}
```

## Available Helpers

### Option Creators

#### `mkDesc description`
Create a simple option with just a description.

```nix
helpers.mkDesc "My option description"
```

#### `mkDefaultDesc default description`
Create an option with a default value and description.

```nix
helpers.mkDefaultDesc 8080 "Port number"
```

#### `mkPercentage default description`
Create a percentage option (0-100).

```nix
helpers.mkPercentage 50 "CPU usage limit"
```

#### `mkPort default description`
Create a port option with type checking.

```nix
helpers.mkPort 8080 "Service port"
```

#### `mkPath default description`
Create a path option.

```nix
helpers.mkPath "/var/data" "Data directory"
```

#### `mkStringMatch regex default description`
Create a string option validated against a regex.

```nix
helpers.mkStringMatch "[a-zA-Z]+" "default" "Name matching regex"
```

#### `mkPackageList description`
Create a list of packages option.

```nix
helpers.mkPackageList "Additional packages"
```

### Service Helpers

#### `mkServiceEnable serviceName`
Create enable option for a systemd service.

```nix
helpers.mkServiceEnable "myservice"
# Results in: myservice.enable
```

#### `mkTimerOptions`
Common timer configuration options.

```nix
{
  onCalendar = mkTimerOptions.onCalendar;
  persistent = mkTimerOptions.persistent;
}
```

### Network Helpers

#### `mkNetworkInterface`
Network interface configuration structure.

```nix
{
  interface = mkNetworkInterface.interface;
  address = mkNetworkInterface.address;
  gateway = mkNetworkInterface.gateway;
}
```

### GPU Helpers

#### `gpuDefaults`
GPU passthrough defaults for common cards.

```nix
let
  gpu = helpers.gpuDefaults.nvidia-3060;
in
{
  vendor = gpu.vendor;      # "10de"
  device = gpu.device;      # "2560"
  audioDevice = gpu.audioDevice;  # "228e"
}
```

Available GPUs:
- `nvidia-3060` - NVIDIA RTX 3060
- `amd-vega` - AMD Radeon Vega
- `intel-integrated` - Intel integrated graphics

### Validation Helpers

#### `validateNoDuplicateOptions modules`
Check for duplicate option declarations across modules.

```nix
helpers.validateNoDuplicateOptions modules
```

#### `validateImports modules`
Verify all imported modules exist.

```nix
helpers.validateImports modules
```

#### `checkModuleHealth module`
Detect anti-patterns in a module:
- Uses `rec { }` instead of `let ... in`
- Uses `with pkgs` at top level
- Contains hardcoded home directory paths

```nix
helpers.checkModuleHealth module
```

## Best Practices

1. **Use typed options** - Use `mkPort`, `mkPath`, `mkPercentage` for type safety
2. **Merge attribute sets** - Use single `boot = { }` instead of `boot.kernelModules = ...` and `boot.kernel.sysctl = ...`
3. **Avoid `rec`** - Use `let ... in` with explicit references
4. **Avoid `with pkgs`** - Use `inherit (pkgs) package1 package2` instead

## Examples

### Complete Module Example

```nix
{ lib, config, pkgs, ... }:
let
  helpers = import ../lib { inherit lib; };
in
{
  options.services.myservice = {
    enable = helpers.mkServiceEnable "My Service";
    port = helpers.mkPort 8080 "Service port";
    dataDir = helpers.mkPath "/var/data" "Data directory";
  };

  config = lib.mkIf config.services.myservice.enable {
    systemd.services.myservice = {
      ExecStart = "${pkgs.myService}/bin/myservice --port ${toString config.services.myservice.port}";
    };
  };
}
```
