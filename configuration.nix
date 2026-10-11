# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules
  ];

  # System & Base Networking
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
      "electron-39"
      "electron-29"
      "electron-28"
      "electron-27"
    ];
  };
  networking.hostName = "nixos-nb";
  networking.networkmanager.enable = true;

  # Hardware Profile Selection:
  # Options: "amd-workstation" (default) | "intel-laptop" | "generic"
#   custom.hardware.profile = "amd-workstation";
  # For Dell Intel Evo Laptop, switch to:
  custom.hardware.profile = "intel-laptop";

  # Optional: Disk Encryption & TPM 2.0 Auto-Unlock (Disabled by default)
  # When disabled, disk & filesystem layout is inherited from hardware-configuration.nix.
  custom.storage.encryption = {
    enable = true;
    tpmAutoUnlock = true;
    device = "/dev/disk/by-partlabel/cryptroot";
  };

  system.stateVersion = "24.11";
}