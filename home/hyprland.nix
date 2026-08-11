{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland
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
}
