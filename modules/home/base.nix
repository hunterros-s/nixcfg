# Shared base for every home config: home-manager essentials + the common CLI
# toolchain. Per-host modules then only need to import this plus their deltas.
{ host, ... }:
{
  imports = [
    ./cli.nix
    ./tmux.nix
    ./fzf.nix
    ./direnv.nix
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./pi.nix
  ];

  home.username = host.user.name;
  home.homeDirectory = host.user.home;
  home.stateVersion = host.stateVersion; # do not change

  programs.home-manager.enable = true;
}
