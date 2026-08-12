{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland
    hyprpaper
    ghostty
    hyprlauncher
    xwayland
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "~/wallpapers/wallpaper.jpg";
        }  
      ];
    };
  };
}
