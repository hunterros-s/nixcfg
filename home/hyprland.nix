{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland
    ghostty
    hyprlauncher
  ];

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
