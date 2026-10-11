# modules/desktop/plasma.nix
{ ... }:

{
  # Desktop Environment: KDE Plasma 6
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Default Application Handlers
  xdg.mime.defaultApplications = {
    "text/html" = [ "brave-browser.desktop" ];
    "x-scheme-handler/http" = [ "brave-browser.desktop" ];
    "x-scheme-handler/https" = [ "brave-browser.desktop" ];
  };
}

