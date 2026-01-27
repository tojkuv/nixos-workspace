#!/usr/bin/env bash
# NixOS Configuration Troubleshooting Script
# Diagnoses common issues with the NixOS configuration
# Run: ./troubleshoot.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== NixOS Configuration Troubleshooting ===${NC}"
echo ""

# Track issues
ISSUES=0
WARNINGS=0

# Function to check and report
check() {
    local name="$1"
    local command="$2"
    
    echo -n "Checking: $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        ((ISSUES++))
    fi
}

check_warning() {
    local name="$1"
    local command="$2"
    
    echo -n "Checking: $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${YELLOW}WARNING${NC}"
        ((WARNINGS++))
    fi
}

# --- System Checks ---
echo -e "${BLUE}--- System Configuration ---${NC}"

check "Nix daemon running" "systemctl is-active nix-daemon"
check "Current system exists" "test -L /run/current-system"
check "Configuration imports exist" "test -f configuration.nix"
check "Modules directory exists" "test -d modules"

# --- Flake Checks ---
echo ""
echo -e "${BLUE}--- Flake Configuration ---${NC}"

check "Flake.nix exists" "test -f flake.nix"
check "Flake.lock exists" "test -f flake.lock"
check_warning "Flake check passes" "cd /home/tojkuv/Documents/GitHub/tojkuv/nixos-workspace && nix flake check > /dev/null 2>&1"

# --- Network Checks ---
echo ""
echo -e "${BLUE}--- Network Configuration ---${NC}"

check "NetworkManager running" "systemctl is-active NetworkManager"
check "DNS resolution works" "nslookup cache.nixos.org > /dev/null 2>&1"

# --- Service Checks ---
echo ""
echo -e "${BLUE}--- Critical Services ---${NC}"

check "SSH enabled" "systemctl is-active sshd || systemctl is-active ssh"
check "DBus running" "systemctl is-active dbus"

# --- Hardware Checks ---
echo ""
echo -e "${BLUE}--- Hardware ---${NC}"

check_warning "GPU detected" "lspci | grep -iE 'vga|3d' | grep -q ."
check_warning "NVIDIA driver loaded" "lsmod | grep -q nvidia"

# --- Environment Variables ---
echo ""
echo -e "${BLUE}--- Environment Variables ---${NC}"

check_warning "DRI_PRIME set" "test -n \"\$DRI_PRIME\""
check_warning "MOZ_ENABLE_WAYLAND set" "test -n \"\$MOZ_ENABLE_WAYLAND\""

# --- Build Check ---
echo ""
echo -e "${BLUE}--- Build Test ---${NC}"

check_warning "Configuration parses" "cd /home/tojkuv/Documents/GitHub/tojkuv/nixos-workspace && nix-instantiate --parse configuration.nix > /dev/null 2>&1"

# --- Common Issues Report ---
echo ""
echo -e "${BLUE}=== Common Issues ===${NC}"
echo ""
echo "1. If flake check fails:"
echo "   - Run: cd /home/tojkuv/Documents/GitHub/tojkuv/nixos-workspace && nix flake update"
echo "   - Check: nix log /nix/store/... for details"
echo ""
echo "2. If environment variables not set:"
echo "   - Run: source /etc/set-environment"
echo "   - Or logout/login to refresh session"
echo ""
echo "3. If GPU issues:"
echo "   - Check: nvidia-smi"
echo "   - Verify: nix run .#dev-workstation --no-build-output -- nvidia-smi"
echo ""
echo "4. If services fail to start:"
echo "   - Check: systemctl status <service>"
echo "   - Logs: journalctl -u <service>"
echo ""

# --- Summary ---
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Issues: ${RED}$ISSUES${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ISSUES -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
elif [ $ISSUES -eq 0 ]; then
    echo -e "${YELLOW}Configuration looks OK with some warnings.${NC}"
    echo "Review warnings above for potential issues."
    exit 0
else
    echo -e "${RED}Issues found. Please review the output above.${NC}"
    exit 1
fi
