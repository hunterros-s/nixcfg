{
  services.openssh = {
    enable = true; # also opens port 22
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
