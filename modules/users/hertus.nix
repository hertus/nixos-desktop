# modules/users/hertus.nix
{ pkgs, ... }:

{
  # Define user account with sudo ('wheel') and desktop subsystem permissions
  users.users.hertus = {
    isNormalUser = true;
    description = "Hertus";
    extraGroups = [
      "wheel"          # Enables 'sudo' permissions
      "networkmanager" # Manage Wi-Fi & connections without root
      "docker"         # Run Docker containers without sudo
      "libvirtd"       # Manage KVM/QEMU VMs in virt-manager without root password prompts
      "video"          # Access to webcams / video capture devices (for Howdy face recognition)
      "audio"          # Direct audio hardware control
      "dialout"        # Access to serial ports and smartcard/USB devices
      "scanner"        # Access to scanners
      "lp"             # Access to CUPS printer hardware and administration
    ];
    shell = pkgs.bash;
  };
}

