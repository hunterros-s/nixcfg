{
  home =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = false;
          decorations = "Full";
          opacity = 0.96;
        };

        scrolling.history = 10000;

        font = {
          size = 12.0;
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Italic";
          };
          bold_italic = {
            family = "JetBrainsMono Nerd Font";
            style = "Bold Italic";
          };
        };

        cursor = {
          style = {
            shape = "Block";
            blinking = "Off";
          };
          unfocused_hollow = true;
        };

        mouse.hide_when_typing = true;

        colors = {
          primary = {
            background = "#0f1117";
            foreground = "#d8dee9";
          };
          normal = {
            black = "#3b4252";
            red = "#bf616a";
            green = "#a3be8c";
            yellow = "#ebcb8b";
            blue = "#81a1c1";
            magenta = "#b48ead";
            cyan = "#88c0d0";
            white = "#e5e9f0";
          };
          bright = {
            black = "#4c566a";
            red = "#bf616a";
            green = "#a3be8c";
            yellow = "#ebcb8b";
            blue = "#81a1c1";
            magenta = "#b48ead";
            cyan = "#8fbcbb";
            white = "#eceff4";
          };
        };
      };

      toml = pkgs.formats.toml { };
    in
    {
      fonts.fontconfig.enable = lib.mkIf pkgs.stdenv.isLinux true;

      home.packages =
        lib.optionals pkgs.stdenv.isLinux [
          pkgs.nerd-fonts.jetbrains-mono
        ]
        ++ lib.optionals (!config.targets.genericLinux.enable && pkgs.stdenv.isLinux) [
          pkgs.alacritty
        ];

      xdg.configFile."alacritty/alacritty.toml".source = toml.generate "alacritty.toml" settings;
    };
}
