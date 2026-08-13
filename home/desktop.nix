{ pkgs, ... }:
{
  imports = [
    ./hyprland.nix
  ];
  home.packages = with pkgs; [
    firefox
    amdgpu_top
    xwayland-satellite
    vulkan-tools
    bluez
    overskride
  ];

  fonts.fontconfig.enable = true;
}
