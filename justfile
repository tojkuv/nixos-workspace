# NixOS Workstation Configuration
# Justfile - Simpler alternative to Makefile
# Install just: nix-env -iA nixpkgs.just

set dotenv-load := false
set shell := ["bash", "-c"]
set ignore_comments := false

# Default recipe - show help
default:
    @just --list

# =============================================================================
# Configuration Management (Flake-based - Pinned nixpkgs)
# =============================================================================

# Rebuild and switch to new configuration
rebuild:
    @echo "=== Rebuilding NixOS Configuration (Flakes) ==="
    sudo nixos-rebuild switch --flake .#dev-workstation

# Alias for rebuild
switch: rebuild

# Build and test configuration (no boot entry)
test:
    @echo "=== Testing NixOS Configuration (Flakes) ==="
    nix build .#nixosConfigurations.dev-workstation.config.system.build.toplevel
    echo "✓ Configuration test successful"

# Build boot entry (active on next boot)
boot:
    @echo "=== Building Boot Configuration (Flakes) ==="
    sudo nixos-rebuild boot --flake .#dev-workstation

# Validate configuration syntax
check:
    @echo "=== Checking Configuration Syntax (Flakes) ==="
    nix build .#nixosConfigurations.dev-workstation.config.system.build.toplevel
    echo "✓ Configuration syntax valid"

# Show diff between current and new config
diff:
    @echo "=== Configuration Diff (Flakes) ==="
    nix build .#nixosConfigurations.dev-workstation.config.system.build.toplevel
    nix store diff-closures /run/current-system ./result || true
    rm -f ./result

# =============================================================================
# Flake Management
# =============================================================================

# Update flake inputs and rebuild
upgrade:
    @echo "=== Upgrading NixOS Configuration (Flakes) ==="
    nix flake update
    sudo nixos-rebuild switch --flake .#dev-workstation

# Update flake inputs without rebuilding
update-flake:
    @echo "=== Updating Flake Inputs ==="
    nix flake update
    echo "✓ Flake inputs updated. Run 'just rebuild' to apply."

# Lock flake (update flake.lock)
lock-flake:
    @echo "=== Locking Flake ==="
    nix flake lock
    echo "✓ Flake.lock updated"

# =============================================================================
# Formatting and Linting
# =============================================================================

# Format all Nix files
fmt:
    @echo "=== Formatting Nix Files ==="
    nix fmt
    echo "✓ All files formatted"

# Lint Nix files with statix
lint:
    @echo "=== Linting Nix Files ==="
    nix develop --command statix check
    echo "✓ Linting complete"

# Format and lint
format: fmt lint
    @echo "✓ Formatting and linting complete"

# =============================================================================
# Testing
# =============================================================================

# Run integration tests
test-integration:
    @echo "=== Running Integration Tests ==="
    if [ -f modules/tests/run-tests.sh ]; then
        bash modules/tests/run-tests.sh
    else
        echo "Test script not found"
        exit 1
    fi

# =============================================================================
# Development Shell
# =============================================================================

# Enter development shell
dev:
    @echo "=== Entering Development Shell ==="
    nix develop
    echo "Type 'exit' to leave"

# Enter development shell (alias)
shell: dev

# =============================================================================
# Maintenance
# =============================================================================

# Garbage collection
gc:
    @echo "=== Running Garbage Collection ==="
    sudo nix-collect-garbage -d
    echo "✓ Garbage collection complete"

# Remove old generations (30+ days)
gc-old:
    @echo "=== Removing Old Generations (30+ days) ==="
    sudo nix-collect-garbage --delete-older-than 30d
    echo "✓ Old generations removed"

# Clean build artifacts
clean:
    @echo "=== Cleaning Build Artifacts ==="
    rm -f result*
    rm -rf ./result
    echo "✓ Build artifacts cleaned"

# Optimize nix store
optimize:
    @echo "=== Optimizing Nix Store ==="
    sudo nix-store --optimize
    echo "✓ Nix store optimized"

# =============================================================================
# Diagnostics
# =============================================================================

# List system generations
generations:
    @echo "=== System Generations ==="
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
rollback:
    @echo "=== Rolling Back to Previous Generation ==="
    sudo nixos-rebuild switch --rollback
    echo "✓ Rolled back to previous generation"

# Show current system info
info:
    @echo "=== Current System Info ==="
    nixos-version
    echo ""
    echo "Configuration file: $(pwd)/configuration.nix"
    echo "Hardware config: $(pwd)/hardware-configuration.nix"
    echo ""
    echo "Modules:"
    ls -1 modules/

# =============================================================================
# Help
# =============================================================================

help:
    @echo "=== NixOS Workstation Management ==="
    @echo ""
    @echo "Configuration Management (Flake-based - Pinned nixpkgs):"
    @echo "  just rebuild       - Rebuild and switch to new configuration"
    @echo "  just switch        - Alias for rebuild"
    @echo "  just test          - Build and test configuration (no boot entry)"
    @echo "  just boot          - Build and set as next boot default (no switch)"
    @echo "  just check         - Validate configuration syntax"
    @echo "  just diff          - Show diff between current and new config"
    @echo ""
    @echo "Flake Management:"
    @echo "  just upgrade       - Update flake inputs and rebuild"
    @echo "  just update-flake  - Update flake inputs without rebuilding"
    @echo "  just lock-flake    - Update flake.lock without rebuilding"
    @echo ""
    @echo "Formatting and Linting:"
    @echo "  just fmt           - Format all Nix files"
    @echo "  just lint          - Lint Nix files with statix"
    @echo "  just format        - Format and lint"
    @echo ""
    @echo "Testing:"
    @echo "  just test-integration - Run integration tests"
    @echo ""
    @echo "Development:"
    @echo "  just dev           - Enter development shell"
    @echo "  just shell         - Alias for dev"
    @echo ""
    @echo "Maintenance:"
    @echo "  just gc            - Run garbage collection"
    @echo "  just gc-old        - Remove generations older than 30 days"
    @echo "  just clean         - Clean build artifacts"
    @echo "  just optimize      - Optimize nix store"
    @echo ""
    @echo "Diagnostics:"
    @echo "  just generations   - List all system generations"
    @echo "  just rollback      - Rollback to previous generation"
    @echo "  just info          - Show current system info"
    @echo ""
    @echo "Run 'just' without arguments to see this help"
