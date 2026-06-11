{ host, ... }:
{
  home.username = host.user.name;
  home.homeDirectory = host.user.home;
  home.stateVersion = host.stateVersion; # do not change

  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  home.sessionVariables = {
    ROCM_PATH = "/opt/rocm";
  };

  home.sessionPath = [
    "/opt/rocm/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

}
