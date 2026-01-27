# Virtualisation Module
# Handles QEMU/KVM virtualization and container orchestration

{ config, pkgs, lib, ... }:

{

  # Enable libvirt for VM management
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      verbatimConfig = ''
        user = "root"
        group = "root"
      '';
    };

    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  # GPU passthrough configuration (disabled by default for safety)
  virtualisation.gpuPassthrough.enable = lib.mkDefault false;

    # Enable SPICE for enhanced VM experience
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true;

  # Container orchestration with Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns = ["8.8.8.8"];
  };

  # Groups for VM and USB access
  users.groups = {
    waydroid = {};
    plugdev = {};
    usb = {};
    libvirtd = {};
    qemu-libvirtd = {};
  };

  # Ensure user configs are available for rootless podman
  system.activationScripts.podmanUserConfigs = ''
    for user_home in /home/*; do
      if [ -d "$user_home" ]; then
        user=$(basename "$user_home")
        user_config_dir="$user_home/.config/containers"
        mkdir -p "$user_config_dir"
        cp -f /etc/containers/policy.json "$user_config_dir/policy.json"
        cp -f /etc/containers/registries.conf "$user_config_dir/registries.conf"
        chown -R "$user:users" "$user_config_dir"
      fi
    done
  '';

  # Tools for VM management and GPU passthrough
  environment.systemPackages = [
    pkgs.qemu
    pkgs.qemu_kvm
    pkgs.virt-manager
    pkgs.virt-viewer
    pkgs.spice
    pkgs.spice-gtk
    pkgs.spice-protocol
    pkgs.usbutils
    pkgs.pciutils
    pkgs.dmidecode
    # Additional GUI dependencies for virt-manager
    pkgs.python3
    pkgs.python3Packages.libvirt
    pkgs.python3Packages.pygobject3
    pkgs.python3Packages.requests
    pkgs.gtk3
    pkgs.gtksourceview4
    pkgs.vte
    pkgs.libvirt
    pkgs.libosinfo
    pkgs.cdrtools
    # Windows VM support packages
    pkgs.virtio-win
    pkgs.swtpm
  ];

  # USB device management and permissions
  services.udev.packages = [ pkgs.usbutils ];
  
  # Fix libvirt file access permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt 0755 root libvirtd -"
    "Z /home/tojkuv/Downloads - - qemu-libvirtd -"
    "f /dev/shm/looking-glass 0660 tojkuv qemu-libvirtd -"
  ];

  # Additional kernel modules for virtualization
  boot.kernelModules = [
    "kvm-amd"  # Change to kvm-intel for Intel CPUs
    "vhost_net"  # For virtio networking performance
    "vhost_vsock"  # For host-guest communication
    "vfio-pci"  # Enable for GPU passthrough if needed
    "binder_linux"
    "ashmem_linux"
  ];
}
