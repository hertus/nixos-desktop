# modules/core/boot.nix
{ ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Note on Disks & LUKS:
  # Disk partitioning and LUKS encryption configurations are defined in
  # `modules/core/storage-encryption.nix` and can be toggled via:
  #   custom.storage.encryption.enable = true;
  #   custom.storage.encryption.tpmAutoUnlock = true;
  # When disabled (default), standard filesystems are inherited from
  # `./hardware-configuration.nix`.
}
