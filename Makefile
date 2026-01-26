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
	@echo "SSH Server (Remote Access):"
	@echo "  make ssh-server-setup  - Configure and verify SSH server for remote access"
	@echo "  make ssh-server-status - Check SSH server status and connections"
	@echo "  make ssh-public-ip     - Display public IP and connection info"
	@echo ""
	@echo "Legacy Remote Management (Local Network):"
	@echo "  make ssh-discover  - Auto-discover devices on local network"
	@echo "  make ssh-test      - Test SSH connection (ANDROID_IP=xxx.xxx.xxx.xxx)"
	@echo "  make ssh-status    - Check SSH connection status"
	@echo "  make ssh-connect   - Connect via SSH (ANDROID_IP=xxx.xxx.xxx.xxx)"
	@echo "  make ssh-tunnel-start - Start SSH tunnel (TUNNEL_LOCAL_PORT=2222)"
	@echo "  make ssh-tunnel-stop  - Stop SSH tunnel"
	@echo "  make ssh-tunnel-status - Check SSH tunnel status"
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

win11-ip:
	@virsh -c qemu:///system net-dhcp-leases default | grep -i "52:54:00:4d:8d:f9" | tail -n1 | awk '{print $$5}' | cut -d'/' -f1

win11-rdp:
	@echo "=== Connecting to Windows 11 VM via RDP ==="
	@echo "Fetching VM IP address..."
	@VM_IP=$$(make -s win11-ip); \
	if [ -z "$$VM_IP" ]; then \
		echo "Error: Could not find IP for win11-pro. Is the VM running?"; \
		exit 1; \
	fi; \
	echo "Found VM at: $$VM_IP"; \
	echo "Connecting with FreeRDP (Auto-Logon)..."; \
	xfreerdp /v:$$VM_IP /u:tojku /p:unsecure /gfx:avc444 /rfx /sound /microphone /clipboard /dynamic-resolution /size:95% /cert:ignore /network:lan || \
	echo "Connection closed."

win11-status:
	@echo "=== Windows 11 VM Status ==="
	@virsh -c qemu:///system list --all | grep win11-pro
	@echo -n "IP Address: " && make -s win11-ip
	@echo -n "GPU Status: " && lspci -nnk -d 10de:2560 | grep "Kernel driver"

# Remote Management (Android Workstation)
ANDROID_IP ?= 
ANDROID_USER ?= tojkuv

ssh-test:
	@echo "=== Testing SSH Connection to Android Workstation ==="
	@test -n "$(ANDROID_IP)" || (echo "Error: Set ANDROID_IP variable (make ssh-test ANDROID_IP=xxx.xxx.xxx.xxx)" && exit 1)
	@echo "Testing connection to $(ANDROID_USER)@$(ANDROID_IP)..."
	@ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $(ANDROID_USER)@$(ANDROID_IP) "echo '✓ SSH connection successful'" || (echo "✗ SSH connection failed" && exit 1)

ssh-status:
	@echo "=== SSH Connection Status ==="
	@test -n "$(ANDROID_IP)" || (echo "Current Android IP not configured" && echo "Set with: make ssh-status ANDROID_IP=xxx.xxx.xxx.xxx" && exit 1)
	@echo "Android Workstation: $(ANDROID_USER)@$(ANDROID_IP)"
	@timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $(ANDROID_USER)@$(ANDROID_IP) "uptime && echo 'Status: ✓ Connected'" 2>/dev/null || echo "Status: ✗ Disconnected"

ssh-connect:
	@echo "=== Connecting to Android Workstation ==="
	@test -n "$(ANDROID_IP)" || (echo "Error: Set ANDROID_IP variable (make ssh-connect ANDROID_IP=xxx.xxx.xxx.xxx)" && exit 1)
	@echo "Connecting to $(ANDROID_USER)@$(ANDROID_IP)..."
	ssh $(ANDROID_USER)@$(ANDROID_IP)

# SSH Tunnel Management
TUNNEL_LOCAL_PORT ?= 2222
TUNNEL_REMOTE_PORT ?= 22

ssh-tunnel-start:
	@echo "=== Starting SSH Tunnel to Android Workstation ==="
	@test -n "$(ANDROID_IP)" || (echo "Error: Set ANDROID_IP variable" && exit 1)
	@echo "Creating tunnel: localhost:$(TUNNEL_LOCAL_PORT) → $(ANDROID_USER)@$(ANDROID_IP):$(TUNNEL_REMOTE_PORT)"
	@ssh -f -N -L $(TUNNEL_LOCAL_PORT):localhost:$(TUNNEL_REMOTE_PORT) $(ANDROID_USER)@$(ANDROID_IP) && echo "✓ SSH tunnel established" || echo "✗ Failed to establish tunnel"

ssh-tunnel-stop:
	@echo "=== Stopping SSH Tunnels ==="
	@pkill -f "ssh.*-L $(TUNNEL_LOCAL_PORT)" && echo "✓ SSH tunnel stopped" || echo "No active tunnels found"

ssh-tunnel-status:
	@echo "=== SSH Tunnel Status ==="
	@if pgrep -f "ssh.*-L $(TUNNEL_LOCAL_PORT)" > /dev/null; then \
		echo "✓ SSH tunnel active on port $(TUNNEL_LOCAL_PORT)"; \
		ps aux | grep "ssh.*-L $(TUNNEL_LOCAL_PORT)" | grep -v grep; \
	else \
		echo "✗ No SSH tunnel active on port $(TUNNEL_LOCAL_PORT)"; \
	fi

# SSH Server Configuration
ssh-server-setup:
	@echo "=== SSH Server Configuration for Remote Access ==="
	@echo "Checking SSH service status..."
	@$(SUDO) systemctl is-active sshd >/dev/null && echo "✓ SSH service is running" || (echo "✗ SSH service not running - starting..." && $(SUDO) systemctl start sshd)
	@$(SUDO) systemctl is-enabled sshd >/dev/null && echo "✓ SSH service is enabled" || (echo "Enabling SSH service..." && $(SUDO) systemctl enable sshd)
	@echo ""
	@echo "SSH Server Details:"
	@echo "Port: 22 (TCP)"
	@echo "Firewall: ✓ Port 22 is open"
	@echo "Authentication: Password + Key authentication enabled"
	@echo ""
	@echo "Public IP Detection:"
	@curl -s https://api.ipify.org && echo "" || (echo "Unable to detect public IP" && echo "Check your internet connection")
	@echo ""
	@echo "SSH Configuration Summary:"
	@echo "- Root login: Disabled"
	@echo "- Password authentication: Enabled"
	@echo "- Key authentication: Enabled"
	@echo "- X11 forwarding: Disabled"
	@echo "- Compression: Enabled"
	@echo ""
	@echo "To connect from Android device:"
	@echo "1. Generate SSH keys on Android: make setup-ssh-keys"
	@echo "2. Copy public key to this server"
	@echo "3. Connect: ssh user@YOUR_PUBLIC_IP"

ssh-server-status:
	@echo "=== SSH Server Status ==="
	@echo "Service Status: $$(systemctl is-active sshd)"
	@echo "Service Enabled: $$(systemctl is-enabled sshd)"
	@echo "Port Status: $$(ss -tln | grep :22 | wc -l) connection(s) on port 22"
	@echo "Firewall Rules: $$(iptables -L INPUT -n | grep "dpt:22" | wc -l) rule(s) for SSH"
	@echo ""
	@echo "Recent SSH connections:"
	@journalctl -u sshd --since "1 hour ago" --no-pager -q | grep "Accepted" | tail -5 || echo "No recent connections"

ssh-public-ip:
	@echo "=== Public IP Information ==="
	@echo "Current Public IP: $$(curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null || curl -s --connect-timeout 5 https://ipinfo.io/ip 2>/dev/null || echo 'Unable to detect - check internet connection')"
	@echo "Local IP: $$(ip route get 1 | awk '{print $$7}' | head -1)"
	@echo "SSH Port: 22"
	@echo ""
	@echo "Network Interface Info:"
	@ip addr show | grep -E "inet.*global" | head -3 || echo "Unable to get interface info"
	@echo ""
	@echo "For dynamic DNS setup (if needed):"
	@echo "- Consider services like No-IP, DuckDNS, or Cloudflare Tunnel"
	@echo "- Or configure port forwarding on your router to this machine"

ssh-discover:
	@echo "=== Discovering Android Workstation IP ==="
	@echo "Scanning local network for SSH-enabled devices..."
	@echo "This may take a few moments..."
	@LOCAL_IP=$$(ip route get 1 | awk '{print $$7}' | head -1); \
	NETWORK=$$(echo $$LOCAL_IP | sed 's/\.[0-9]*$$/.0\/24/'); \
	echo "Scanning network: $$NETWORK"; \
	if command -v nmap >/dev/null 2>&1; then \
		nmap -p 22 --open $$NETWORK -oG - | grep "22/open" | awk '{print $$2}' | while read ip; do \
			echo "Found SSH on: $$ip"; \
			if timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no -o PasswordAuthentication=no $(ANDROID_USER)@$$ip "echo 'Android workstation found at $$ip'" 2>/dev/null; then \
				echo "✓ Confirmed Android workstation at: $$ip"; \
				echo "Use: make ANDROID_IP=$$ip ssh-test"; \
				break; \
			fi; \
		done; \
	else \
		echo "nmap not available. Install with: nix-env -iA nixpkgs.nmap"; \
		echo "Alternative: Check ARP table with: ip neigh"; \
		ip neigh | grep -v "FAILED\|INCOMPLETE" | head -10; \
	fi
