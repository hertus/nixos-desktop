# modules/programs/tmux.nix
{ pkgs, ... }:

{
  # Declarative Tmux configuration
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    baseIndex = 1;
    terminal = "screen-256color";
    escapeTime = 10;
    historyLimit = 10000;
    extraConfig = ''
      # Enable mouse control (clickable windows, panes, resizable panes)
      set -g mouse on

      # Vi mode keys in copy mode
      setw -g mode-keys vi

      # Status bar styling
      set -g status-style bg=default,fg=white
      set -g status-left "[#S] "
      set -g status-right "%H:%M %d-%b-%y"
    '';
  };

  # Launch tmux automatically as default interactive terminal session
  # Attaches to existing 'main' session or spawns a new one; ignores VSCode/VSCodium terminal
  programs.bash.interactiveShellInit = ''
    if [[ -z "$TMUX" ]] && [[ $- =~ i ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
      exec tmux new-session -A -s main
    fi
  '';
}
