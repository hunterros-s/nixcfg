{
  home =
    { host, ... }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = host.user.fullName;
            email = host.user.email;
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
    };
}
