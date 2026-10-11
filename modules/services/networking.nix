# modules/services/networking.nix
{ pkgs, ... }:

{
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

