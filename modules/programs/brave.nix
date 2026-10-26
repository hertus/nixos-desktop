# modules/programs/brave.nix
{ pkgs, ... }:

{
  # Chromium & Brave declarative policies and extensions
  programs.chromium = {
    enable = true;
    enablePlasmaBrowserIntegration = true;
    extensions = [
      "cimiefiiaegbelhefglklhhakcgmhkai" # KDE Plasma Browser Integration
    ];
  };

  # Native messaging hosts and enterprise policies for Brave
  # Ensures Brave communicates seamlessly with KDE Plasma 6 (media controls, download notifications, KDE Connect)
  environment.etc = {
    "brave/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
    "opt/chrome/native-messaging-hosts/org.kde.plasma.browser_integration.json".source =
      "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json";
    "brave/policies/managed/plasma-browser-integration.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "cimiefiiaegbelhefglklhhakcgmhkai;https://clients2.google.com/service/update2/crx"
      ];
    };
  };

  # KDE Plasma 6 Browser Integration host daemon
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-browser-integration
  ];
}
