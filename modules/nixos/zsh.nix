{ host, pkgs, ... }:
{
  programs.zsh.enable = true;
  users.users.${host.user.name}.shell = pkgs.zsh;
}
