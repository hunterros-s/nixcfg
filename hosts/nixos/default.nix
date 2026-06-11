{ pkgs, ... }:
let
  sshKeys = import ../../shared/ssh-keys.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/pi/nixos.nix
  ];

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.hunter = {
    isNormalUser = true;
    description = "Hunter";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = sshKeys.hunter;
  };

  # nix daemon
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

  programs.zsh.enable = true; # registers zsh as a login shell; HM writes the actual config
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
  ];

  services.openssh = {
    enable = true; # also opens port 22
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.tailscale.enable = true;

  # ignore the lid
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak"; # see gotcha below
  home-manager.users.hunter = import ./home.nix;

  system.stateVersion = "26.05"; # do not change
}
