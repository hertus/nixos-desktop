# modules/hardware/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.custom.hardware;
in
{
  options.custom.hardware = {
    profile = mkOption {
      type = types.enum [ "amd-workstation" "intel-laptop" "generic" ];
      default = "amd-workstation";
      description = ''
        Select hardware profile:
        - "amd-workstation": AMD Ryzen CPU, AMDGPU drivers, VAAPI/VDPAU, nested kvm-amd.
        - "intel-laptop": Dell Intel Evo i7, Iris Xe GPU acceleration (intel-media-driver), thermald, TLP power management.
        - "generic": Common audio, bluetooth, and base graphics only.
      '';
    };
  };

  imports = [
    ./common.nix
  ];

  config = mkMerge [
    (mkIf (cfg.profile == "amd-workstation") {
      imports = [ ./amd-workstation.nix ];
    })

    (mkIf (cfg.profile == "intel-laptop") {
      imports = [ ./intel-laptop.nix ];
    })
  ];
}

