# NixOS VM Integration Tests
# Tests the configuration in a virtual machine
# Run with: nix build .#nixosConfigurations.dev-workstation.config.system.build.toplevel
#          or use just test-integration

{ pkgs, ... }:
let
  testScript = ''
    # Test NetworkManager is running
    machine.succeed("systemctl is-active NetworkManager")

    # Test SSH is enabled
    machine.succeed("systemctl is-active sshd")

    # Test DBus is running
    machine.succeed("systemctl is-active dbus")

    # Test that we can query hostname
    machine.succeed("hostnamectl hostname")

    # Test basic networking (loopback)
    machine.succeed("ping -c 1 127.0.0.1")

    # Test that nix-daemon is running
    machine.succeed("systemctl is-active nix-daemon")

    # Test GPU detection (should detect NVIDIA or Mesa)
    machine.succeed("lspci | grep -E 'VGA|3D'")

    # Test user exists
    machine.succeed("id tojkuv")

    # Test shell is set correctly
    machine.succeed("getent passwd tojkuv | grep -E '/run/current-system/sw/bin/(bash|zsh|fish)'")

    # Test direnv is available
    machine.succeed("which direnv")

    # Test nix command is available
    machine.succeed("which nix")

    # Test nix-ld is configured
    machine.succeed("systemctl is-active nix-ld")

    # Test Podman is available
    machine.succeed("which podman")

    # Test firewall is configured
    machine.succeed("iptables -L -n | head -5")

    # Test resolved is running
    machine.succeed("systemctl is-active systemd-resolved")

    # Print success message
    print("All VM tests passed!")
  '';
in
{
  name = "nixos-workspace-vm-test";

  nodes = {
    machine = { imports = [ ../configuration.nix ]; };
  };

  machine.test = ''
    ${testScript}
  '';
}
