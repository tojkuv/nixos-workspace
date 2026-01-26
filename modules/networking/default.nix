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
    
    # Disable ModemManager to avoid udev rule validation errors (not needed for development workstation)
    modemmanager.enable = false;
    # nameservers = [ "1.1.1.1" "8.8.8.8" "8.8.4.4" ]; # Disabled - let resolved handle DNS

    # Enable IPv6 support explicitly
    enableIPv6 = true;

    # Enable IP forwarding for VPN and VMs
    firewall.extraCommands = ''
      iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -j MASQUERADE
      iptables -t nat -A POSTROUTING -s 192.168.122.0/24 -j MASQUERADE
      iptables -A FORWARD -i virbr0 -j ACCEPT
      iptables -A FORWARD -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
      # Allow DHCP/DNS from VMs to host
      iptables -A INPUT -i virbr0 -j ACCEPT
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
    # wireguard.interfaces = {
    #   wg0 = {
    #     ips = [ "10.0.0.1/24" ];
    #     listenPort = 51820;
    #     privateKeyFile = "/etc/wireguard/server_private.key";

    #     peers = [
    #       {
    #         # Android client
    #         publicKey = "avMBqSWyzXv3iY46OtE1rgHGJVsxl3rnB4PFCpNhwD0=";
    #         allowedIPs = [ "10.0.0.2/32" ];
    #       }
    #     ];
    #   };
    # };

    # Configure libvirt bridge (Managed by libvirtd 'default' network)
    # bridges = {
    #   virbr0.interfaces = [];
    # };

    # Simple network configuration
    interfaces = {
      lo = {
      };
      # virbr0 = {
      #   ipv4.addresses = [
      #     {
      #       address = "192.168.122.1";
      #       prefixLength = 24;
      #     }
      #   ];
      # };
    };
  };
}
