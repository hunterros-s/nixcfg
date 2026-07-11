let
  hunter = import ../users/hunter.nix;

  commonHome = [
    ../modules/home/cli.nix
    ../modules/home/tmux.nix
    ../modules/home/fzf.nix
    ../modules/home/direnv.nix
    ../modules/home/git.nix
    ../modules/home/zsh.nix
    ../modules/home/neovim.nix
    ../modules/home/pi.nix
  ];

  commonNixos = [
    ../modules/nixos/system.nix
    ../modules/nixos/zsh.nix
    ../modules/nixos/pi.nix
  ];
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

    homeModules = commonHome ++ [
      ./arch-home.nix
      ../modules/home/dev.nix
      ../modules/home/desktop
    ];
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

    homeModules = commonHome;
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

    homeModules = commonHome ++ [
      ../modules/home/dev.nix
      ../modules/home/desktop
    ];

    nixosModules = commonNixos ++ [
      ./aspire
      ../modules/nixos/desktop.nix
      ../modules/nixos/openssh.nix
      ../modules/nixos/tailscale.nix
    ];
  };
}
