# modules/services/default.nix
{ pkgs, ... }:

{
  # Container Virtualization (Docker Engine)
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # FIDO2, WebAuthn & TPM Security
  security.tpm2.enable = true;
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [
    libfido2
    yubikey-personalization
  ];

  # Background Daemons
  services.ollama.enable = true;
  services.onedrive.enable = true;
  programs.starship.enable = true;

  # Gaming
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
  programs.gamemode.enable = true;
}

