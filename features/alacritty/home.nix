{ ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
        dynamic_padding = true;
      };

      scrolling.history = 10000;

      font.size = 12.0;

      mouse.hide_when_typing = true;
    };
  };
}
