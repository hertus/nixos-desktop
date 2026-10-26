# modules/users/family.nix
{ pkgs, ... }:

{
  # Unprivileged 'family' user account:
  # - Passwordless login (empty initial password)
  # - Strictly unprivileged: NO root/admin permissions (no 'wheel', 'docker', or 'libvirtd')
  users.users.family = {
    isNormalUser = true;
    description = "Family";
    initialHashedPassword = ""; # Passwordless / empty password
    extraGroups = [
      "networkmanager" # Connect to Wi-Fi without admin prompts
      "scanner"        # Scan documents on the network/USB scanner
      "lp"             # Print documents on CUPS printers
    ];
    shell = pkgs.bash;
  };

  # Allow unlocking the KDE Plasma lockscreen and SDDM with empty password
  security.pam.services.sddm.allowNullPassword = true;
  security.pam.services.kde.allowNullPassword = true;
}
