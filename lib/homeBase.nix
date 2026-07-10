{ host, ... }:
{
  home.username = host.user.name;
  home.homeDirectory = host.user.home;
  home.stateVersion = host.stateVersion; # do not change

  programs.home-manager.enable = true;
}
