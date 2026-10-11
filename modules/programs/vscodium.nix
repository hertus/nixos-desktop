# modules/programs/vscodium.nix
{ pkgs, ... }:

let
  vscodiumCustom = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = with pkgs.vscode-extensions; [
      # Remote & Source Control
      jeanp413.open-remote-ssh
      eamodio.gitlens

      # Languages & Development Runtimes
      ms-python.python
      ms-vscode.powershell
      golang.go
      ms-azuretools.vscode-docker

      # Data & File Formatters / Linters
      mechatroner.rainbow-csv
      redhat.vscode-xml
      redhat.vscode-yaml
      redhat.ansible
      esbenp.prettier-vscode
      tamasfe.even-better-toml
    ];
  };
in
{
  environment.systemPackages = [
    vscodiumCustom
  ];
}

