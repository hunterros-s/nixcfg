{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    history.size = 10000;
    shellAliases = {
      ".." = "cd ..";
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
}
