{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./niri.nix
    ./waybar.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    btop
    overskride
    pavucontrol

    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
