# modules/core/hardware.nix
{ pkgs, ... }:

{
  # AMD Ryzen (AM4) & Radeon Graphics Acceleration
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Audio & Bluetooth
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
}

