{ pkgs, ... }:
{
  home.packages = with pkgs; [
    steam
    steam-run
    gamescope
    gamemode
    mangohud
    wineWow64Packages.stable
    winetricks
    prismlauncher
  ];
}
