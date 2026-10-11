# modules/virtualization/libvirt.nix
{ pkgs, ... }:

{
  # -------------------------------------------------------------
  # KVM / Libvirt Daemon with Windows 11 Compatibility
  # -------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;

      # Software TPM 2.0 emulation (strict requirement for Windows 11)
      swtpm.enable = true;

      # UEFI firmware with SecureBoot keys support
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # USB device redirection over SPICE (plug USB drives, smartcards directly into VMs)
  virtualisation.spiceUSBRedirection.enable = true;



  # -------------------------------------------------------------
  # Management Tools & Driver Packages
  # -------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # GUI Manager
    virt-manager
    virt-viewer

    # SPICE Client & Protocols for smooth display / clipboard sync
    spice
    spice-gtk
    spice-protocol

    # TPM 2.0 & Windows VirtIO Drivers ISO
    swtpm
    win-virtio # Exposes VirtIO driver ISO in /run/current-system/sw/share/virtio-win/

    # Quickemu (fast CLI / automated Windows 11 testing setup)
    quickemu
    quickgui
  ];

  # Allow network bridge management without prompting for root
  security.polkit.enable = true;
}

