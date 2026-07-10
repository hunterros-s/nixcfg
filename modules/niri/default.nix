{
  home = {
    xdg.configFile."niri/config.kdl".source = ./config.kdl;
  };

  nixos = {
    programs.niri.enable = true;
  };
}
