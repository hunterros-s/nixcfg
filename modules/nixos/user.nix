{ pkgs, host, ... }:
{
  users.users.${host.user.name} = {
    isNormalUser = true;
    description = host.user.fullName;
    extraGroups = [ "wheel" ] ++ (host.user.extraGroups or [ ]);
    shell = host.user.shell or pkgs.zsh;
    openssh.authorizedKeys.keys = host.user.sshKeys or [ ];
  };

  # Registers zsh as a login shell; Home Manager writes the actual config.
  programs.zsh.enable = true;
}
