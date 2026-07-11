{ pkgs, host, ... }:
{
  networking.hostName = host.hostname;

  time.timeZone = host.timeZone or "America/New_York";
  i18n.defaultLocale = host.locale or "en_US.UTF-8";

  users.users.${host.user.name} = {
    isNormalUser = true;
    description = host.user.fullName;
    extraGroups = [ "wheel" ] ++ (host.user.extraGroups or [ ]);
  };

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
