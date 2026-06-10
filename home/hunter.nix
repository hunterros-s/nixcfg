{ pkgs, ... }:
{
  home.stateVersion = "26.05"; # matches configuration.nix; do not change.

  home.packages = with pkgs; [
    ripgrep fd tree
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    fastfetch
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
      pull.rebase = false;
      push.autoSetupRemote = true;
    };

    ignores = [
      # macOS Finder / filesystem noise
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "Icon?"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"

      # Cross-platform desktop noise
      "Desktop.ini"
      "Thumbs.db"
    ];
  };

  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
