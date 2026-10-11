# modules/default.nix
{ ... }:

{
  imports = [
    ./core/boot.nix
    ./core/hardware.nix
    ./desktop/plasma.nix
    ./services/default.nix
    ./services/networking.nix
    ./packages/default.nix
    ./programs/vscodium.nix
  ];
}

