# modules/packages/default.nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Infrastructure as Code & Containers
    ansible
    ansible-lint
    docker-compose

    # Desktop Docks
    cairo-dock

    # Hardware Diagnostics
    cpu-x
    radeontop
    nvtopPackages.amd
    clinfo
    vulkan-tools

    # Security & Secrets Management
    keepassxc
    libfido2
    tpm2-tools

    # Enterprise Access & Remote Apps
    citrix_workspace
    freerdp3
    remmina
    bottles

    # Browsers & Communication
    brave
    chromium
    teams-for-linux
    teamspeak5_client
    threema-desktop
    signal-desktop

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

