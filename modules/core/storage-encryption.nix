# modules/core/storage-encryption.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.custom.storage.encryption;
in
{
  options.custom.storage.encryption = {
    enable = mkEnableOption "LUKS disk encryption and Btrfs layout" // {
      default = false;
    };

    tpmAutoUnlock = mkOption {
      type = types.bool;
      default = false;
      description = "Enable TPM 2.0 PCR-bound auto-unlock in initrd for LUKS";
    };

    device = mkOption {
      type = types.str;
      default = "/dev/disk/by-partlabel/cryptroot";
      description = "Path to underlying encrypted disk partition";
    };

    dmName = mkOption {
      type = types.str;
      default = "cryptroot";
      description = "Device-mapper name for unlocked container (/dev/mapper/<dmName>)";
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = cfg.tpmAutoUnlock;

    boot.initrd.luks.devices."${cfg.dmName}" = {
      device = mkDefault cfg.device;
      crypttabExtraOpts = mkIf cfg.tpmAutoUnlock [ "tpm2-device=auto" ];
    };

    # Btrfs Subvolume Layout over LUKS
    fileSystems."/" = {
      device = mkDefault "/dev/mapper/${cfg.dmName}";
      fsType = mkDefault "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" ];
    };

    fileSystems."/home" = {
      device = mkDefault "/dev/mapper/${cfg.dmName}";
      fsType = mkDefault "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };

    fileSystems."/nix" = {
      device = mkDefault "/dev/mapper/${cfg.dmName}";
      fsType = mkDefault "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };

    fileSystems."/boot" = {
      device = mkDefault "/dev/disk/by-partlabel/boot";
      fsType = mkDefault "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };
}

