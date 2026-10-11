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
    ./security/auth.nix
    ./virtualization/libvirt.nix
    ./packages/default.nix
    ./programs/vscodium.nix
  ];
}

