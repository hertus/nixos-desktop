# modules/desktop/plasma.nix
{ lib, pkgs, ... }:

{
  # Desktop Environment: KDE Plasma 6
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Disable KDE Wallet completely (prevents popups with auto-login, passwordless family user, and FIDO2/U2F)
  security.pam.services = {
    sddm.kwallet.enable = lib.mkForce false;
    login.kwallet.enable = lib.mkForce false;
    kde.kwallet.enable = lib.mkForce false;
  };

  environment.etc."xdg/kwalletrc".text = ''
    [Wallet]
    Enabled=false
    First Use=false
  '';

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwalletmanager
  ];

  # Auto-login as 'family' user
  services.displayManager.autoLogin = {
    enable = true;
    user = "family";
  };
  services.displayManager.defaultSession = "plasma";

  # Default Application Handlers
  xdg.mime.defaultApplications = {
    "text/html" = [ "brave-browser.desktop" ];
    "x-scheme-handler/http" = [ "brave-browser.desktop" ];
    "x-scheme-handler/https" = [ "brave-browser.desktop" ];
  };
}

