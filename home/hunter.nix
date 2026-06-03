{ pkgs, ... }:
{
  home.stateVersion = "26.05"; # matches configuration.nix; do not change.

  home.packages = with pkgs; [ ripgrep fd neovim tree ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = "1";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    history.size = 10000;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixcfg";
      update  = "nix flake update --flake ~/nixcfg && sudo nixos-rebuild switch --flake ~/nixcfg";
      ".."  = "cd ..";
      "..." = "cd ../..";
      v = "nvim";
      c = "clear";
    };

    initContent = ''
      setopt CORRECT NO_BEEP INTERACTIVE_COMMENTS AUTO_PUSHD PUSHD_SILENT

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      mkcd() { mkdir -p "$1" && cd "$1" }
      f() { find . -name "*$1*" }

      autoload -Uz vcs_info
      precmd() { vcs_info }
      setopt prompt_subst
      zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
      PROMPT='[%F{green}%n@%m%f] %F{blue}%~%f''${vcs_info_msg_0_} %# '
    '';
  };

  programs.git = {
    enable = true;
    settings.user = {
      name  = "Hunter Ross";
      email = "hlross@umich.edu";
    };
    settings = {
      init.defaultBranch = "main";
    };
  };

  programs.fzf.enable = true;
}
