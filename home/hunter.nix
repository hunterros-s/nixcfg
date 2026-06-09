{ pkgs, ... }:
{
  home.stateVersion = "26.05"; # matches configuration.nix; do not change.

  home.packages = with pkgs; [
    ripgrep fd tree fastfetch
  ];

  imports = [ 
    ./zsh.nix
    ./neovim.nix
    ./pi.nix
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

  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Hunter Ross";
        email = "hlross@umich.edu";
      };
      init.defaultBranch = "main";
    };
  };

  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
