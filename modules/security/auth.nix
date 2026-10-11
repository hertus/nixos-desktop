# modules/security/auth.nix
{ config, pkgs, ... }:

{
  # -------------------------------------------------------------
  # 1. Face Authentication (Howdy - Windows Hello equivalent)
  # -------------------------------------------------------------
  # To activate:
  # 1. Change `enable = true`
  # 2. Check camera path with `v4l2-ctl --list-devices` (default is /dev/video0)
  # 3. Run `sudo howdy add` to enroll face models
  # 4. Test recognition with `sudo howdy test`
  services.howdy = {
    enable = false;
    package = pkgs.howdy;
    settings = {
      core = {
        no_confirmation = true;
        abort_if_ssh = true;
        detection_notice = true;
      };
      video = {
        # Path to camera device (e.g. /dev/video0 or /dev/v4l/by-id/...)
        device_path = "/dev/video0";
        # Set to true if using an infrared (IR) camera
        use_dark_mode = true;
        # Camera sensor resolution and scaling
        certainty = 3.5;
      };
    };
  };

  # -------------------------------------------------------------
  # 2. Hardware PIN / FIDO2 / YubiKey (PAM U2F)
  # -------------------------------------------------------------
  # Allows logging in with FIDO2 hardware key and PIN.
  # To enroll:
  # 1. Set PIN: `ykman fido access change-pin`
  # 2. Register key: `mkdir -p ~/.config/Yubico && pamu2fcfg -P -N > ~/.config/Yubico/u2f_keys`
  security.pam.u2f = {
    enable = true;
    cue = true;              # Provides visual cue prompt to touch the key
    control = "sufficient";  # Allows FIDO2/PIN to satisfy authentication without password
    settings = {
      userverification = 1;  # Enforces FIDO2 PIN verification
    };
  };

  # PAM service integrations for SDDM, Console, Sudo, and KDE Lockscreen
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
    sddm.u2fAuth = true;
    kde.u2fAuth = true;      # KDE Plasma 6 lockscreen
  };

  # -------------------------------------------------------------
  # 3. Biometric Fingerprint Daemon (fprintd)
  # -------------------------------------------------------------
  # Enable if laptop or external USB fingerprint reader is present.
  # Enroll fingers via `fprintd-enroll`.
  services.fprintd = {
    enable = false;
  };

  # Required helper tools for camera diagnosis and FIDO2 enrollment
  environment.systemPackages = with pkgs; [
    pam_u2f
    yubikey-manager
    v4l-utils # provides v4l2-ctl for camera discovery
  ];
}

