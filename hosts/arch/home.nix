{ ... }:
{
  imports = [
    ../../home/hunter.nix
    ../../home/dev.nix
  ];

  home.username = "hunter";
  home.homeDirectory = "/home/hunter";

  targets.genericLinux.enable = true;

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
    nfu = "nix flake update ~/nixcfg";
  };
}
