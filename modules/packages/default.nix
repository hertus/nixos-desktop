# modules/packages/default.nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Essentials
    git
    vim # nano is installed by default builtin
    wget
    curl

    # Infrastructure as Code & Containers
    ansible
    ansible-lint
    docker-compose

    # Hardware Diagnostics (Common)
    cpu-x
    clinfo

    # Security & Secrets Management
    keepassxc
    libfido2
    tpm2-tools

    # Enterprise Access & Remote Apps
    # Note: citrix_workspace is disabled by default because upstream Citrix requires deprecated libsoup-2.4.
    # To enable: uncomment citrix_workspace and add "libsoup-2.4.1" to nixpkgs.config.permittedInsecurePackages.
    # citrix_workspace
    freerdp
    remmina
    bottles

    # Browsers & Communication
    brave
    chromium
    teams-for-linux
    teamspeak6-client
    threema-desktop
    signal-desktop

    # Cloud Storage & Synchronization (Modern OneDrive / Multi-Cloud Alternatives)
    rclone             # High-performance sync/mount for OneDrive, SharePoint, Google Drive, etc.
    celeste            # Modern GUI cloud sync client (supports OneDrive, Google Drive, Nextcloud, etc.)

    # Media, Notes & Proton Suite
    vlc
    logseq
    protonmail-desktop
    proton-pass
    protonvpn-gui
    kdePackages.spectacle
    flameshot

    # Development Core Runtimes & Terminals
    git
    python3
    powershell
    go
    nodejs
    kitty
    kdePackages.konsole
    ollama
  ];
}

