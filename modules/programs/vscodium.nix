# modules/programs/vscodium.nix
{ pkgs, ... }:

let
  # vscodeExtensions packaged in nixpkgs (official and verified namespace)
  vscodiumCustom = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = with pkgs.vscode-extensions; [
      # Languages & Runtimes
      golang.go
      ms-python.python

      # Formatters & Linters
      redhat.vscode-yaml
      redhat.vscode-xml
      redhat.ansible
      esbenp.prettier-vscode
      tamasfe.even-better-toml
      mechatroner.rainbow-csv
      eamodio.gitlens
    ];
  };
in
{
  environment.systemPackages = [
    vscodiumCustom
  ];
}
