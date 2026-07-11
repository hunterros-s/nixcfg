{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    historyLimit = 50000;
    escapeTime = 10;
    terminal = "tmux-256color";
  };
}
