.PHONY: help rebuild switch test boot upgrade gc clean check diff adb-restart adb-devices adb-wireless adb-connect adb-disconnect android-studio android-build android-install android-build-install vnc-remmina vnc-tigervnc vnc-gnome-connections podman-prune podman-system-prune podman-volume-prune podman-image-prune

SUDO_PASSWORD := unsecure
SUDO := echo "$(SUDO_PASSWORD)" | sudo -S

help:
	@echo "=== NixOS Workstation Management ==="
	@echo ""
	@echo "Configuration Management:"
	@echo "  make rebuild       - Rebuild and switch to new configuration"
	@echo "  make switch        - Alias for rebuild"
	@echo "  make test          - Build and test configuration (no boot entry)"
	@echo "  make boot          - Build and set as next boot default (no switch)"
	@echo ""
	@echo "Updates:"
	@echo "  make upgrade       - Update channels and rebuild"
	@echo "  make update-channels - Update nix channels only (no rebuild)"
	@echo ""
	@echo "Maintenance:"
	@echo "  make gc            - Run garbage collection (remove old generations)"
	@echo "  make gc-old        - Remove generations older than 30 days"
	@echo "  make clean         - Clean build artifacts"
	@echo "  make optimize      - Optimize nix store"
	@echo "  make podman-prune    - Prune all podman resources"
	@echo "  make podman-system-prune - Prune unused containers, networks, images"
	@echo "  make podman-volume-prune - Prune unused volumes"
	@echo "  make podman-image-prune - Prune unused images"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make check         - Check configuration syntax"
	@echo "  make diff          - Show diff between current and new config"
	@echo "  make generations   - List all system generations"
	@echo "  make rollback      - Rollback to previous generation"
	@echo ""
	@echo "VNC Clients:"
	@echo "  make vnc-remmina   - Launch Remmina VNC client"
	@echo "  make vnc-tigervnc  - Launch TigerVNC client"
	@echo "  make vnc-gnome-connections - Launch GNOME Connections VNC client"
	@echo ""
	@echo "Admin Password: unsecure"

rebuild:
	@echo "=== Rebuilding NixOS Configuration ==="
	@echo "This will rebuild and switch to the new configuration"
	@cd $(PWD) && $(SUDO) nixos-rebuild switch -I nixos-config=$(PWD)/configuration.nix
	@rm -f $(PWD)/result*

switch: rebuild

test:
	@echo "=== Testing NixOS Configuration ==="
	@echo "Building configuration without creating boot entry"
	@cd $(PWD) && $(SUDO) nixos-rebuild test -I nixos-config=$(PWD)/configuration.nix
	@rm -f $(PWD)/result*

boot:
	@echo "=== Building Boot Configuration ==="
	@echo "Configuration will be active on next boot"
	@cd $(PWD) && $(SUDO) nixos-rebuild boot -I nixos-config=$(PWD)/configuration.nix
	@rm -f $(PWD)/result*

upgrade:
	@echo "=== Upgrading NixOS Configuration ==="
	@echo "Updating channels and rebuilding"
	@$(SUDO) nix-channel --update
	@cd $(PWD) && $(SUDO) nixos-rebuild switch --upgrade -I nixos-config=$(PWD)/configuration.nix
	@rm -f $(PWD)/result*

update-channels:
	@echo "=== Updating Nix Channels ==="
	@$(SUDO) nix-channel --update
	@echo "✓ Run 'make rebuild' to apply updates"

gc:
	@echo "=== Running Garbage Collection ==="
	@$(SUDO) nix-collect-garbage -d
	@echo "✓ Garbage collection complete"

gc-old:
	@echo "=== Removing Old Generations (30+ days) ==="
	@$(SUDO) nix-collect-garbage --delete-older-than 30d
	@echo "✓ Old generations removed"

clean:
	@echo "=== Cleaning Build Artifacts ==="
	@rm -f $(PWD)/result*
	@echo "✓ Build artifacts cleaned"

optimize:
	@echo "=== Optimizing Nix Store ==="
	@echo "This may take several minutes..."
	@$(SUDO) nix-store --optimize
	@echo "✓ Nix store optimized"

podman-prune: podman-system-prune podman-volume-prune podman-image-prune
	@echo "✓ All podman resources pruned"

podman-system-prune:
	@echo "=== Pruning Podman System ==="
	@$(SUDO) podman system prune -a
	@echo "✓ Podman system pruned"

podman-volume-prune:
	@echo "=== Pruning Podman Volumes ==="
	@$(SUDO) podman volume prune
	@echo "✓ Podman volumes pruned"

podman-image-prune:
	@echo "=== Pruning Podman Images ==="
	@$(SUDO) podman image prune -a
	@echo "✓ Podman images pruned"

check:
	@echo "=== Checking Configuration Syntax ==="
	@cd $(PWD) && nixos-rebuild dry-build -I nixos-config=$(PWD)/configuration.nix
	@rm -f $(PWD)/result*
	@echo "✓ Configuration syntax valid"

diff:
	@echo "=== Configuration Diff ==="
	@echo "Building new configuration..."
	@cd $(PWD) && nixos-rebuild build -I nixos-config=$(PWD)/configuration.nix
	@echo ""
	@echo "Comparing with current system:"
	@cd $(PWD) && nix store diff-closures /run/current-system ./result || echo "No differences or error occurred"
	@rm -f $(PWD)/result*
	@echo ""
	@echo "Run 'make rebuild' to apply changes"

generations:
	@echo "=== System Generations ==="
	@$(SUDO) nix-env --list-generations --profile /nix/var/nix/profiles/system

rollback:
	@echo "=== Rolling Back to Previous Generation ==="
	@$(SUDO) nixos-rebuild switch --rollback
	@echo "✓ Rolled back to previous generation"

list-packages:
	@echo "=== Installed Packages ==="
	nix-env -q

search:
	@echo "Usage: make search PACKAGE=firefox"
	@test -n "$(PACKAGE)" || (echo "Error: PACKAGE not specified" && exit 1)
	nix search nixpkgs $(PACKAGE)

show-config:
	@echo "=== Current Configuration ==="
	@echo "Configuration file: $(PWD)/configuration.nix"
	@echo "Hardware config: $(PWD)/hardware-configuration.nix"
	@echo ""
	@echo "Modules:"
	@ls -1 modules/

reboot:
	@echo "=== Rebooting System ==="
	@echo "This will reboot the workstation"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	@$(SUDO) reboot

vnc-remmina:
	@echo "=== Launching Remmina VNC Client ==="
	remmina

vnc-tigervnc:
	@echo "=== Launching TigerVNC Client ==="
	vncviewer localhost:5999

vnc-gnome-connections:
	@echo "=== Launching GNOME Connections VNC Client ==="
	gnome-connections
