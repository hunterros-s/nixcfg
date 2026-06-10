{ ... }:
{
  imports = [
    ../../home/hunter.nix
    ../../home/dev.nix
  ];

  home.stateVersion = "26.05"; # do not change

  programs.zsh.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixcfg#nixos";
    build = "nixos-rebuild build --flake ~/nixcfg#nixos";
    update = "nix flake update ~/nixcfg && sudo nixos-rebuild switch --flake ~/nixcfg#nixos";
  };
}
