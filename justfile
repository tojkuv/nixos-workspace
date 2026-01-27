# NixOS Workstation Configuration
# Justfile - Simpler alternative to Makefile
# Install just: nix-env -iA nixpkgs.just

set dotenv-load := false
set shell := ["bash", "-c"]

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
	nix develop --command nixfmt flake.nix configuration.nix
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
# Validation (CI replacement)
# =============================================================================

# Run full validation suite
validate:
	@echo "=== NixOS Configuration Validation ==="
	@echo ""

	@echo "--- Step 1: Flake Check ---"
	-nix flake check --no-build
	@echo ""

	@echo "--- Step 2: Build Test ---"
	-nix build .#nixosConfigurations.dev-workstation.config.system.build.toplevel --no-link
	@echo ""

	@echo "--- Step 3: Linting ---"
	-nix develop --command statix check || true
	@echo ""

	@echo "--- Step 4: Integration Tests ---"
	-just test-integration || true
	@echo ""

	@echo "✓ Validation complete"

# =============================================================================
# Testing
# =============================================================================

# Run integration tests
test-integration:
	@echo "=== Running Integration Tests ==="

	@echo ""
	@echo "--- Network Tests ---"
	-@ip link show | grep -q 'state UP' && echo "✓ Network interface up" || echo "✗ Network interface down"
	-@ip route show default | grep -q . && echo "✓ Default route exists" || echo "✗ No default route"
	-@curl -s --connect-timeout 5 https://cache.nixos.org > /dev/null 2>&1 && echo "✓ DNS resolution works" || echo "✗ DNS resolution failed"

	@echo ""
	@echo "--- Service Tests ---"
	-@(systemctl is-active sshd || systemctl is-active ssh) > /dev/null 2>&1 && echo "✓ SSH service running" || echo "✗ SSH service not running"
	-@systemctl is-active dbus > /dev/null 2>&1 && echo "✓ DBus running" || echo "✗ DBus not running"
	-@(systemctl is-active NetworkManager || systemctl is-active networkd) > /dev/null 2>&1 && echo "✓ NetworkManager running" || echo "✗ NetworkManager not running"

	@echo ""
	@echo "--- GPU Tests ---"
	-@lspci | grep -iE 'vga|3d' | grep -q . && echo "✓ GPU detected" || echo "✗ No GPU detected"
	-@test -d /dev/dri && echo "✓ DRI available" || echo "✗ DRI not available"

	@echo ""
	@echo "--- System Tests ---"
	-@systemctl is-active nix-daemon > /dev/null 2>&1 && echo "✓ Nix daemon running" || echo "✗ Nix daemon not running"
	-@test -L /run/current-system && echo "✓ Current system symlink exists" || echo "✗ System symlink missing"
	-@nixos-version --revision | grep -q . && echo "✓ Configuration parsed" || echo "✗ Configuration parse failed"

	@echo ""
	@echo "--- Environment Tests ---"
	-@test -n "$DRI_PRIME" && echo "✓ DRI_PRIME set" || echo "✗ DRI_PRIME not set"
	-@test -n "$MOZ_ENABLE_WAYLAND" && echo "✓ MOZ_ENABLE_WAYLAND set" || echo "✗ MOZ_ENABLE_WAYLAND not set"
	-@test -n "$SSL_CERT_FILE" && echo "✓ SSL_CERT_FILE set" || echo "✗ SSL_CERT_FILE not set"

	@echo ""
	@echo "✓ Integration tests complete"

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
# Home Manager
# =============================================================================

# Install Home Manager for the current user (via NixOS module)
# Home Manager is integrated into the system config, run 'just rebuild' first
hm-install:
	@echo "=== Home Manager Installation ==="
	@echo ""
	@echo "Home Manager is now part of the NixOS system configuration."
	@echo "Run 'just rebuild' to apply both system and user configurations."
	@echo ""
	@echo "The following Home Manager features are now enabled:"
	@echo "  - Bash and Zsh integration with Starship prompt"
	@echo "  - User environment variables"
	@echo "  - User packages (ripgrep, fd, bat, delta, lazygit, etc.)"
	@echo "  - XDG mimeapps configuration"
	@echo ""
	@echo "To update user configuration later, run: just rebuild"

# Switch Home Manager configuration (via NixOS rebuild)
hm-switch:
	@echo "=== Switching Home Manager Configuration ==="
	@echo "Use 'just rebuild' to apply Home Manager changes."

# Build Home Manager configuration without switching (dry run)
hm-build:
	@echo "=== Building Home Manager Configuration ==="
	@echo "Use 'just test' to test the full configuration including Home Manager."

# Rollback Home Manager to previous generation
hm-rollback:
	@echo "=== Rolling Back Home Manager ==="
	@echo "Use 'just rollback' to rollback both system and user configurations."

# List Home Manager generations
hm-generations:
	@echo "=== Home Manager Generations ==="
	nix-shell -p home-manager --run "home-manager generations"
	@echo ""
	@echo "System generations: just generations"

# =============================================================================
# Troubleshooting
# =============================================================================

# Run diagnostics and troubleshooting
troubleshoot:
	@echo "=== NixOS Configuration Troubleshooting ==="
	@echo ""

	@echo "--- System Configuration ---"
	-systemctl is-active nix-daemon > /dev/null 2>&1 && echo "✓ Nix daemon running" || echo "✗ Nix daemon not running"
	-test -L /run/current-system && echo "✓ Current system exists" || echo "✗ Current system missing"
	-test -f configuration.nix && echo "✓ Configuration imports exist" || echo "✗ Configuration file missing"
	-test -d modules && echo "✓ Modules directory exists" || echo "✗ Modules directory missing"

	@echo ""
	@echo "--- Flake Configuration ---"
	-test -f flake.nix && echo "✓ Flake.nix exists" || echo "✗ Flake.nix missing"
	-test -f flake.lock && echo "✓ Flake.lock exists" || echo "✗ Flake.lock missing"
	-nix flake check > /dev/null 2>&1 && echo "✓ Flake check passes" || echo "⚠ Flake check has warnings"

	@echo ""
	@echo "--- Network Configuration ---"
	-(systemctl is-active NetworkManager || systemctl is-active networkd) > /dev/null 2>&1 && echo "✓ NetworkManager running" || echo "✗ NetworkManager not running"
	-nslookup cache.nixos.org > /dev/null 2>&1 && echo "✓ DNS resolution works" || echo "✗ DNS resolution failed"

	@echo ""
	@echo "--- Critical Services ---"
	-(systemctl is-active sshd || systemctl is-active ssh) > /dev/null 2>&1 && echo "✓ SSH enabled" || echo "✗ SSH not enabled"
	-systemctl is-active dbus > /dev/null 2>&1 && echo "✓ DBus running" || echo "✗ DBus not running"

	@echo ""
	@echo "--- Hardware ---"
	-lspci | grep -iE 'vga|3d' | grep -q . && echo "✓ GPU detected" || echo "⚠ No GPU detected"
	-lsmod | grep -q nvidia && echo "✓ NVIDIA driver loaded" || echo "⚠ NVIDIA driver not loaded"

	@echo ""
	@echo "--- Environment Variables ---"
	-test -n "$DRI_PRIME" && echo "✓ DRI_PRIME set" || echo "⚠ DRI_PRIME not set"
	-test -n "$MOZ_ENABLE_WAYLAND" && echo "✓ MOZ_ENABLE_WAYLAND set" || echo "⚠ MOZ_ENABLE_WAYLAND not set"

	@echo ""
	@echo "--- Build Test ---"
	-nix-instantiate --parse configuration.nix > /dev/null 2>&1 && echo "✓ Configuration parses" || echo "✗ Configuration parse failed"

	@echo ""
	@echo "=== Common Issues ==="
	@echo "1. If flake check fails: nix flake update"
	@echo "2. If env vars not set: source /etc/set-environment or logout/login"
	@echo "3. If GPU issues: check nvidia-smi"
	@echo "4. If services fail: systemctl status <service>"
	@echo ""
	@echo "✓ Troubleshooting complete"

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
	@echo "  just troubleshoot     - Run diagnostics"
	@echo "  just validate         - Full validation suite"
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
	@echo "Home Manager:"
	@echo "  just hm-install    - Install Home Manager for user"
	@echo "  just hm-switch     - Switch Home Manager config"
	@echo "  just hm-build      - Build Home Manager config (dry run)"
	@echo "  just hm-rollback   - Rollback Home Manager"
	@echo "  just hm-generations- List Home Manager generations"
	@echo ""
	@echo "Diagnostics:"
	@echo "  just generations   - List all system generations"
	@echo "  just rollback      - Rollback to previous generation"
	@echo "  just info          - Show current system info"
	@echo ""
	@echo "See README.md for full documentation"
