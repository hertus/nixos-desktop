# modules/hardware/common.nix
{ pkgs, ... }:

{
  # Common Audio Stack (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Common Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Modern graphics foundation (OpenGL / Vulkan)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}

