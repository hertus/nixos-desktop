# modules/default.nix
{ ... }:

{
  imports = [
    ./core/boot.nix
    ./core/storage-encryption.nix
    ./hardware
    ./desktop/plasma.nix
    ./services/default.nix
    ./services/networking.nix
    ./services/flatpak.nix
    ./services/printing.nix
    ./security/auth.nix
    ./virtualization/libvirt.nix
    ./users/hertus.nix
    ./packages/default.nix
    ./programs/vscodium.nix
  ];
}

