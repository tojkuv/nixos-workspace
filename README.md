# NixOS Development Workstation Configuration

Flake-based NixOS configuration for a professional development machine.

## Features

- **Modular Architecture**: Clean separation of concerns with modules
- **Flake-first**: Reproducible builds with pinned nixpkgs
- **Development Tools**: Neovim, VS Code, zed, tmux, starship
- **Gaming Support**: MangoHUD, Gamemode, Prism Launcher
- **Virtualization**: QEMU, virt-manager, Looking Glass
- **Container Support**: Podman, Docker, Kubernetes tools
- **GPU Passthrough**: Ready for Windows VM with NVIDIA GPU
- **Home Manager**: Declarative user-level configuration

## Quick Start

```bash
# Rebuild and switch to new configuration
just rebuild

# Enter development shell
just dev

# Run tests
just test-integration

# Format and lint
just format
```

## Directory Structure

```
nixos-workspace/
├── flake.nix              # Main flake with all outputs
├── configuration.nix      # Entry point
├── hardware-configuration.nix
├── justfile               # Task runner (use 'just' instead of Makefile)
├── shell.nix              # Dev shell (imports from flake)
├── formatter.nix          # Treefmt configuration
├── .editorconfig          # Editor configuration
├── .envrc                 # Direnv configuration
│
├── modules/
│   ├── lib/               # Reusable helpers (see modules/README.md)
│   ├── tests/             # Integration tests
│   ├── home-manager/      # User-level configuration
│   ├── boot/              # Boot configuration
│   ├── networking/        # NetworkManager, firewall
│   ├── users/             # User management
│   ├── services/          # SSH, DBus, etc.
│   ├── security/          # Security hardening
│   ├── virtualisation/    # QEMU, libvirt
│   ├── hardware/          # GPU, audio, input
│   ├── desktop/           # Display manager, desktop
│   ├── fonts/             # Typography
│   ├── packages/          # System packages
│   ├── programs/          # Program configs
│   └── environment/       # Env vars, paths
│
├── overlays/              # Custom package overlays
│   └── default.nix
│
└── .ref/                  # Reference materials from nix.dev
```

## Common Commands

| Command | Description |
|---------|-------------|
| `just rebuild` | Rebuild and switch configuration |
| `just test` | Build without switching |
| `just boot` | Build boot entry |
| `just diff` | Show config diff |
| `just fmt` | Format Nix files |
| `just lint` | Lint with statix |
| `just format` | Format and lint |
| `just validate` | Full validation (flake check + build + lint + tests) |
| `just dev` | Enter dev shell |
| `just upgrade` | Update flake inputs |
| `just gc` | Garbage collection |
| `just troubleshoot` | Run diagnostics |
| `just test-integration` | Run tests |

## Best Practices

This configuration follows [nix.dev best practices](https://nix.dev/guides/best-practices):

### Module Best Practices

1. **Use `let ... in` instead of `rec { }`**
   ```nix
   let
     pkgs = import nixpkgs { config = {}; overlays = []; };
   in
   { ... }
   ```

2. **Avoid `with pkgs` at top level**
   ```nix
   # Instead of
   with pkgs; [ curl jq ]
   
   # Use
   inherit (pkgs) curl jq;
   ```

3. **Merge repeated attribute set keys**
   ```nix
   # Instead of
   boot.kernelModules = [...];
   boot.kernel.sysctl = { ... };
   
   # Use
   boot = {
     kernelModules = [...];
     kernel.sysctl = { ... };
   };
   ```

4. **Use typed option helpers**
   ```nix
   helpers.mkPort 8080 "Service port"
   helpers.mkPath "/var/data" "Data directory"
   helpers.mkPercentage 50 "CPU limit"
   ```

### Adding New Packages

Edit `modules/packages/default.nix` and add packages to the list:

```nix
environment.systemPackages = with pkgs; [
  new-package
];
```

### Creating New Modules

1. Create `modules/newmodule/default.nix`
2. Import it in `configuration.nix`
3. Use helpers from `modules/lib/default.nix`:

```nix
{ lib, ... }:
let
  helpers = import ../lib { inherit lib; };
in
{
  options.myOption = helpers.mkPort 8080 "Service port";
}
```

See `modules/README.md` for full documentation of available helpers.

## Home Manager

This configuration includes Home Manager for user-level configuration.

**To enable:**

```bash
# Enable in configuration.nix
programs.home-manager.enable = true

# Rebuild system
just rebuild

# As user 'tojkuv', run:
install-home-manager
home-manager switch
```

Home Manager manages:
- Shell configuration (`.bashrc`, `.zshrc`, `.profile`)
- Dotfiles (Neovim config, tmux config, etc.)
- User-level packages

## Development

```bash
# Enter development environment
nix develop

# Format code
nix fmt

# Lint code
statix check

# Run tests
just test-integration

# Full validation
just validate
```

## Troubleshooting

```bash
# Check configuration
just troubleshoot

# View logs
journalctl -xe

# Rollback
just rollback
```

## References

- [NixOS Wiki](https://nixos.org/wiki)
- [Nix Pills](https://nixos.org/nix pills)
- [nix.dev](https://nix.dev)
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs)
