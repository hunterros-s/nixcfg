{ pkgs, host, ... }:
{
  networking.hostName = host.hostname or host.name;

  time.timeZone = host.timeZone or "America/New_York";
  i18n.defaultLocale = host.locale or "en_US.UTF-8";

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    flake-registry = "";
  };

  nix.channel.enable = false;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
  ];

  system.stateVersion = host.stateVersion; # do not change
}
