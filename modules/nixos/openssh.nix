{ host, ... }:
{
  services.openssh = {
    enable = true; # also opens port 22
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.${host.user.name}.openssh.authorizedKeys.keys = host.user.sshKeys or [ ];
}
