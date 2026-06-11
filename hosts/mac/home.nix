{ ... }:
{
  imports = [
    ../../home/hunter.nix
    ../../profiles/pi/home.nix
  ];

  home.username = "hunterross";
  home.homeDirectory = "/Users/hunterross";
  home.stateVersion = "26.05"; # do not change

  programs.home-manager.enable = true;

  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/nixcfg#hunter-mac";
    hmb = "home-manager build --flake ~/nixcfg#hunter-mac";
    nfu = "nix flake update --flake ~/nixcfg";
  };
}
