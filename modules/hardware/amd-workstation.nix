# modules/hardware/amd-workstation.nix
{ pkgs, ... }:

{
  # AMD Ryzen (AM4) CPU Microcode & KVM
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];

  # Nested KVM virtualization for AMD
  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
  '';

  # Radeon Graphics Video Acceleration (VA-API / VDPAU)
  hardware.graphics.extraPackages = with pkgs; [
    vaapiVdpau
    libvdpau-va-gl
  ];
}

