{ host, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = host.hostname;
    networkmanager.enable = true;
    nftables.enable = true;
    interfaces.enp1s0f1.wakeOnLan.enable = true;

    # Expose remote services only through Tailscale.
    firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [
        22
        2586
        25565
      ];
      allowedUDPPorts = [ 24454 ];
    };
  };

  time.timeZone = host.timeZone or "America/New_York";
  i18n.defaultLocale = host.locale or "en_US.UTF-8";

  users.users.${host.user.name} = {
    isNormalUser = true;
    description = host.user.fullName;
    extraGroups = [ "wheel" ] ++ (host.user.extraGroups or [ ]);
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = host.user.sshKeys or [ ];
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      flake-registry = "";
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    channel.enable = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  programs = {
    nix-ld.enable = true;
    zsh.enable = true;
  };

  services = {
    tailscale.enable = true;

    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    ntfy-sh = {
      enable = true;
      settings = {
        base-url = "http://100.80.194.77:2586";
        listen-http = ":2586";
        # Wake the iOS app through APNs; message contents remain on this server.
        upstream-base-url = "https://ntfy.sh";
      };
    };

    # This machine is usually docked; do not sleep when the lid closes.
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
  ];

  system.stateVersion = host.stateVersion; # do not change
}
