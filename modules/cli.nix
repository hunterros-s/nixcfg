{
  home =
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
    };
}
