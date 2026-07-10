{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      ripgrep
      fd
      tree
    ]
    ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      fastfetch
    ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = "1";
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    historyLimit = 50000;
    escapeTime = 10;
    terminal = "tmux-256color";
  };

  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
