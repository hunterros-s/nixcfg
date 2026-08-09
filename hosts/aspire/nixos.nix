{ pkgs, ... }:
let
  user = import ../../users/hunter.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "aspire";
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
    };
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.hunter = {
    isNormalUser = true;
    description = user.fullName;
    extraGroups = [ "wheel" ] ++ (user.extraGroups or [ ]);
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = user.sshKeys or [ ];
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

  systemd.services.reddit-ssd-notifier = {
    description = "r/buildapcsales SSD notifier";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "ntfy-sh.service"
    ];

    environment = {
      NTFY_URL = "http://127.0.0.1:2586/reddit-ssd";
      PYTHONUNBUFFERED = "1";
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 ${./reddit_ssd_notifier.py} --state-file /var/lib/reddit-ssd-notifier/state.json";
      Restart = "always";
      RestartSec = "10s";

      DynamicUser = true;
      StateDirectory = "reddit-ssd-notifier";
      WorkingDirectory = "/var/lib/reddit-ssd-notifier";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
  ];

  system.stateVersion = "26.05"; # do not change
}
