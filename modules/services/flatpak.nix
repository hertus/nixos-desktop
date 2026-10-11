# modules/services/flatpak.nix
{ pkgs, ... }:

{
  # Enable Flatpak runtime service
  services.flatpak.enable = true;

  # Integration packages for KDE Plasma Discover and Flatpak permissions
  environment.systemPackages = with pkgs; [
    kdePackages.discover # Plasma GUI software center with Flatpak backend support
  ];

  # Systemd activation service to automatically configure the Flathub repository
  # and install / update declarative Flatpaks on boot / rebuild
  systemd.services.configure-flathub-and-flatpaks = {
    description = "Configure Flathub remote and install default Flatpaks";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      # 1. Add Flathub repository if not already present
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # 2. Install Spotify
      if ! flatpak info com.spotify.Client &>/dev/null; then
        flatpak install -y --noninteractive flathub com.spotify.Client || true
      fi

      # 3. Install Threema (Modern / Multi-device version on Flathub)
      if ! flatpak info ch.threema.threema-web-desktop &>/dev/null; then
        flatpak install -y --noninteractive flathub ch.threema.threema-web-desktop || true
      fi
    '';
  };
}

