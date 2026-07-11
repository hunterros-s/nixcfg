let
  hunter = import ../users/hunter.nix;

  homeBase =
    { host, ... }:
    {
      home.username = host.user.name;
      home.homeDirectory = host.user.home;
      home.stateVersion = host.stateVersion; # do not change

      programs.home-manager.enable = true;
    };
in
{
  hunter-arch = {
    kind = "home";
    hostname = "arch";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = hunter // {
      name = "hunter";
      home = "/home/hunter";
    };

    waybar = {
      cpuTemp = "/sys/class/hwmon/hwmon2/temp1_input";
      gpu = {
        busy = "/sys/class/drm/card1/device/gpu_busy_percent";
        temp = "/sys/class/hwmon/hwmon1/temp1_input";
      };
    };

    homeModule = {
      imports = [
        homeBase
        ../modules/home/cli.nix
        ../modules/home/tmux.nix
        ../modules/home/fzf.nix
        ../modules/home/direnv.nix
        ../modules/home/git.nix
        ../modules/home/zsh.nix
        ../modules/home/neovim.nix
        ../modules/home/pi.nix
        ../modules/home/dev.nix
        ../modules/home/desktop
      ];

      # Also enables GPU support for Nix GUI applications.
      targets.genericLinux.enable = true;

      home.sessionVariables.ROCM_PATH = "/opt/rocm";

      home.sessionPath = [
        "/opt/rocm/bin"
        "$HOME/.local/bin"
        "$HOME/.npm-global/bin"
      ];
    };
  };

  hunter-mac = {
    kind = "home";
    hostname = "Hunters-MacBook-Air";
    system = "aarch64-darwin";
    stateVersion = "26.05";

    user = hunter // {
      name = "hunterross";
      home = "/Users/hunterross";
    };

    homeModule.imports = [
      homeBase
      ../modules/home/cli.nix
      ../modules/home/tmux.nix
      ../modules/home/fzf.nix
      ../modules/home/direnv.nix
      ../modules/home/git.nix
      ../modules/home/zsh.nix
      ../modules/home/neovim.nix
      ../modules/home/pi.nix
    ];
  };

  aspire = {
    kind = "nixos";
    hostname = "aspire";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = hunter // {
      name = "hunter";
      home = "/home/hunter";
    };

    homeModule.imports = [
      homeBase
      ../modules/home/cli.nix
      ../modules/home/tmux.nix
      ../modules/home/fzf.nix
      ../modules/home/direnv.nix
      ../modules/home/git.nix
      ../modules/home/zsh.nix
      ../modules/home/neovim.nix
      ../modules/home/pi.nix
      ../modules/home/dev.nix
      ../modules/home/desktop
    ];

    nixosModule =
      { pkgs, ... }:
      {
        imports = [
          ./aspire/hardware-configuration.nix
          ../modules/nixos/system.nix
          ../modules/nixos/zsh.nix
          ../modules/nixos/pi.nix
          ../modules/nixos/desktop.nix
          ../modules/nixos/openssh.nix
          ../modules/nixos/tailscale.nix
        ];

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;

        networking.networkmanager.enable = true;
        networking.interfaces.enp1s0f1.wakeOnLan.enable = true;

        # This machine is usually docked; do not sleep when the lid closes.
        services.logind.settings.Login = {
          HandleLidSwitch = "ignore";
          HandleLidSwitchExternalPower = "ignore";
          HandleLidSwitchDocked = "ignore";
        };
      };
  };
}
