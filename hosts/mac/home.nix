{ ... }:
{
  imports = [
    ../../home/hunter.nix
  ];

  home.username = "hunterross";
  home.homeDirectory = "/Users/hunterross";

  programs.home-manager.enable = true;

  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/nixcfg#hunter-mac";
    hmb = "home-manager build --flake ~/nixcfg#hunter-mac";
    nfu = "nix flake update ~/nixcfg";
  };
}
