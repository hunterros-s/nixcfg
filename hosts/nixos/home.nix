{ ... }:
{
  imports = [
    ../../home/hunter.nix
  ];

  programs.zsh.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake ~/nixcfg#nixos";
    build = "nixos-rebuild build --flake ~/nixcfg#nixos";
    update = "nix flake update ~/nixcfg && sudo nixos-rebuild switch --flake ~/nixcfg#nixos";
  };
}
