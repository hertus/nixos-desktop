# modules/services/printing.nix
{ pkgs, ... }:

{
  # CUPS Printing Daemon & Epson Drivers
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr   # Epson ESC/P-R driver (EcoTank, WorkForce, Expression)
      epson-escpr2  # Epson ESC/P-R driver v2 (newer EcoTank & WorkForce models)
    ];
  };

  # Network printer autodiscovery via mDNS / DNS-SD (AirPrint, IPP Everywhere)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Driverless IPP-over-USB support for modern USB-connected printers & scanners
  services.ipp-usb.enable = true;

  # SANE Scanner support (for Epson multifunction / All-in-One devices)
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      sane-airscan  # Driverless eSCL / WSD scanner support over network and USB
      epson-escpr
    ];
  };

  # Printing & Scanning GUI utilities for KDE Plasma
  environment.systemPackages = with pkgs; [
    kdePackages.print-manager   # KDE System Settings Printer integration
    kdePackages.skanpage        # KDE scanning utility
    system-config-printer       # Standalone CUPS printer management GUI
  ];
}
