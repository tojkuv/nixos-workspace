# Networking Configuration Module
# Handles network settings, firewall, and DNS configuration

{ config, pkgs, lib, ... }:

let
  developmentEnvironment = "dev-unstable";
in

{
  networking = {
    hostName = "dev-workstation-${developmentEnvironment}";
    networkmanager.enable = true;
    # nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ]; # Disabled - let resolved handle DNS

    # Enable IPv6 support explicitly
    enableIPv6 = true;

    # Enable IP forwarding for VPN
    firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o wlp2s0 -j MASQUERADE
    '';
    
    # Simple firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # SSH
        80 443 # HTTP/HTTPS
        3000  # Development server
        8080  # Life Signal API development server
        22220 # SSH forwarded port for Windows Server
        33389 # RDP forwarded port for Windows Server
        139 445 # SMB/CIFS for Windows Server VM file sharing
      ];
      allowedUDPPorts = [
        137 138 # NetBIOS for SMB discovery
        51820   # WireGuard VPN
      ];
    };

    # Enable IP forwarding for VPN
    iproute2.enable = true;


    
    # WireGuard VPN configuration
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.0.0.1/24" ];
        listenPort = 51820;
        privateKeyFile = "/etc/wireguard/server_private.key";

        peers = [
          {
            # Phone client
            publicKey = "d6zuPjGtX8iJhgMhuruI4XtEFygqfA1HRGZABpNIBgs=";
            allowedIPs = [ "10.0.0.2/32" ];
          }
        ];
      };
    };

    # Simple network configuration
    interfaces = {
      lo = {
      };
    };
  };
}