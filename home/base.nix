# Everything every machine gets: shared packages, environment, git.
{ pkgs, ... }:
let
  user = import ../users/hunter.nix;
in
{
  imports = [
    ./neovim.nix
    ./pi.nix
    ./shell.nix
  ];

  home.stateVersion = "26.05"; # do not change

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ripgrep
    fd
    tree
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    fastfetch
    btop
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLICOLOR = "1";
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = user.fullName;
        email = user.email;
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
}
