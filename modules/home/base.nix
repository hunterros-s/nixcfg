# Shared base for every home config: home-manager essentials + the common CLI
# toolchain. Per-machine files then only import this plus their own deltas.
{ ... }:
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

  # Username/home dir are set by each machine's file; stateVersion is the
  # same everywhere today.
  home.stateVersion = "26.05"; # do not change

  programs.home-manager.enable = true;
}
