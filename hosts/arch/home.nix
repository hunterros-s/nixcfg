{ ... }:
{
  imports = [
    ../../home/hunter.nix
    ../../home/dev.nix
    ../../profiles/pi/home.nix
  ];

  home.username = "hunter";
  home.homeDirectory = "/home/hunter";
  home.stateVersion = "26.05"; # do not change

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

  programs.zsh.shellAliases = {
    hms = "home-manager switch --flake ~/nixcfg#hunter-arch";
    hmb = "home-manager build --flake ~/nixcfg#hunter-arch";
    nfu = "nix flake update --flake ~/nixcfg";
  };
}
