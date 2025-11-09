# Virtualisation Configuration Module
# Handles Podman, libvirtd, and container settings

{ config, pkgs, lib, ... }:

{
  virtualisation = {
    waydroid.enable = false;

    podman = {
      enable = true;
      
      # Docker compatibility for seamless transition
      dockerCompat = true;
      dockerSocket.enable = true;
      
      # Default network settings
      defaultNetwork.settings.dns_enabled = true;
      
      # Auto-update and cleanup
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = [ "--all" ];
      };
      
      # Extra packages for full compatibility
      extraPackages = with pkgs; [ 
        buildah 
        skopeo 
        runc 
        crun
        fuse-overlayfs
        slirp4netns
      ];
    };
    
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };

    containers.enable = true;
  };
  
  # Podman container configuration files
  environment.etc = {
    "containers/policy.json" = lib.mkForce {
      text = ''
        {
          "default": [
            {
              "type": "insecureAcceptAnything"
            }
          ],
          "transports": {
            "docker-daemon": {
              "": [{"type": "insecureAcceptAnything"}]
            }
          }
        }
      '';
      mode = "0644";
    };

    "containers/registries.conf" = lib.mkForce {
      text = ''
        unqualified-search-registries = ["docker.io"]

        [[registry]]
        prefix = "docker.io"
        location = "docker.io"
      '';
      mode = "0644";
    };
  };
  
  # Systemd optimizations for container orchestration
  systemd.services = {
    # Override systemd service settings for better container support
    podman.serviceConfig = {
      TimeoutStopSec = 30;
      TimeoutStartSec = 30;
      LimitNOFILE = 1048576;
      LimitNPROC = 1048576;
      LimitMEMLOCK = "infinity";
    };
  };

  # Enable systemd-resolved for container DNS
  services.resolved.enable = true;

  # Waydroid user group
  users.groups.waydroid = {};

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
}