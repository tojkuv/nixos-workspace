#!/usr/bin/env bash
# Integration test runner for NixOS configuration
# Run this script to verify critical services are working

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== NixOS Integration Tests ==="
echo ""

PASSED=0
FAILED=0

# Test function
run_test() {
    local name="$1"
    local command="$2"
    
    echo -n "Testing: $name... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
    fi
}

# Network connectivity tests
echo "--- Network Tests ---"
run_test "Network interface up" "ip link show | grep -q 'state UP'"
run_test "Default route exists" "ip route show default | grep -q ."
run_test "DNS resolution works" "curl -s --connect-timeout 5 https://cache.nixos.org > /dev/null"

# Service health checks
echo ""
echo "--- Service Tests ---"
run_test "SSH service running" "systemctl is-active sshd || systemctl is-active ssh"
run_test "DBus running" "systemctl is-active dbus"
run_test "NetworkManager running" "systemctl is-active NetworkManager || systemctl is-active networkd"

# GPU tests
echo ""
echo "--- GPU Tests ---"
run_test "GPU detected" "lspci | grep -iE 'vga|3d' | grep -q ."
run_test "DRI available" "test -d /dev/dri"
run_test "OpenGL works" "glxinfo 2>/dev/null | grep -q 'OpenGL renderer'"

# System tests
echo ""
echo "--- System Tests ---"
run_test "Nix daemon running" "systemctl is-active nix-daemon"
run_test "Current system symlink exists" "test -L /run/current-system"
run_test "Configuration parsed successfully" "nixos-version --revision | grep -q ."

# Environment variables
echo ""
echo "--- Environment Tests ---"
run_test "DRI_PRIME set" "test -n \"\$DRI_PRIME\""
run_test "MOZ_ENABLE_WAYLAND set" "test -n \"\$MOZ_ENABLE_WAYLAND\""
run_test "SSL_CERT_FILE set" "test -n \"\$SSL_CERT_FILE\""

# Summary
echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
