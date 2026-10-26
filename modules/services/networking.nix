# modules/services/networking.nix
{ pkgs, ... }:

{
  # Family DNS Filtering (CleanBrowsing Family Filter)
  # Blocks adult / phishing / malicious content and enforces SafeSearch
  networking.nameservers = [
    "185.228.168.168"
    "185.228.169.168"
    "2a0d:2a00:1::"
    "2a0d:2a00:2::"
  ];

  # Ensure NetworkManager inserts CleanBrowsing at the beginning of the DNS list
  # for all network connections (preventing local router DHCP DNS from overriding it)
  networking.networkmanager.insertNameservers = [
    "185.228.168.168"
    "185.228.169.168"
    "2a0d:2a00:1::"
    "2a0d:2a00:2::"
  ];

  # WireGuard CLI tools
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  # NetBird Mesh VPN Client
  # Provides background daemon and systemd integration.
  # Use `netbird up` or the GUI client to connect.
  services.netbird = {
    enable = true;
    # package = pkgs.netbird; # Default package
  };

  # Optional GUI client for NetBird
  # environment.systemPackages = [ pkgs.netbird-ui ];
}

