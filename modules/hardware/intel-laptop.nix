# modules/hardware/intel-laptop.nix
{ config, lib, pkgs, ... }:

let
  isIntel = config.custom.hardware.profile == "intel-laptop";
in
lib.mkIf isIntel {
  # Intel CPU Microcode & KVM
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];

  # Nested KVM virtualization for Intel
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
  '';

  # Intel Iris Xe / UHD Graphics Hardware Acceleration
  # (intel-media-driver for Gen9+, intel-compute-runtime for OpenCL)
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver   # Hardware VA-API video decoding / encoding for Intel Iris Xe & UHD
    intel-compute-runtime # OpenCL compute runtime for Intel GPUs
    vpl-gpu-rt           # Intel oneVPL runtime for hardware video processing
  ];

  # 32-bit acceleration for Steam / 32-bit apps
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    intel-media-driver
  ];

  # Laptop Battery & Power Management
  # Thermald manages thermal zones on Intel CPUs to prevent throttling.
  # TLP optimizes battery runtime, CPU frequency scaling, and PCIe power savings.
  # Note: power-profiles-daemon (default in KDE Plasma 6) must be disabled to prevent conflict with TLP.
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
    };
  };

  # Touchpad support & power optimization
  services.libinput.enable = true;
  services.upower.enable = true;

  # Intel GPU Diagnostics, VA-API Inspection & Power Monitoring Tools
  environment.systemPackages = with pkgs; [
    intel-gpu-tools    # intel_gpu_top, intel_reg, etc.
    libva-utils        # vainfo (inspect VA-API hardware decode/encode codecs)
    powertop           # Real-time power consumption and battery discharge monitor
    vulkan-tools       # vkcube, vulkaninfo for Iris Xe
  ];
}
