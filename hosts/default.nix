let
  sshKeys = import ../data/ssh-keys.nix;

  commonHome = [
    ../modules/core/home.nix
    ../modules/git/home.nix
    ../modules/zsh/home.nix
    ../modules/neovim/home.nix
  ];

  graphicalHome = [
    ../modules/alacritty/home.nix
  ];

  commonNixos = [
    ../modules/nixos/base.nix
    ../modules/nixos/user.nix
    ../modules/nixos/ssh.nix
  ];
in
{
  hunter-arch = {
    kind = "home";
    hostname = "arch";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = {
      name = "hunter";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/home/hunter";
    };

    desktop = {
      terminal = "/usr/bin/alacritty";

      waybar = {
        cpuTemp = "/sys/class/hwmon/hwmon2/temp1_input";
        gpu = {
          busy = "/sys/class/drm/card1/device/gpu_busy_percent";
          temp = "/sys/class/hwmon/hwmon1/temp1_input";
        };
      };
    };

    homeModules = commonHome ++ [
      ./arch/home.nix
      ../modules/alacritty/home.nix
      ../modules/desktop/waybar/home.nix
      ../modules/dev/home.nix
      ../modules/pi/home.nix
    ];
  };

  hunter-mac = {
    kind = "home";
    hostname = "Hunters-Air";
    system = "aarch64-darwin";
    stateVersion = "26.05";

    user = {
      name = "hunterross";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/Users/hunterross";
    };

    homeModules = commonHome ++ [
      ../modules/pi/home.nix
    ];
  };

  aspire = {
    kind = "nixos";
    hostname = "aspire";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = {
      name = "hunter";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/home/hunter";
      sshKeys = sshKeys.hunter;
    };

    nixosModules = commonNixos ++ [
      ./aspire/default.nix
      ./aspire/hardware-configuration.nix
      ../modules/desktop/niri/nixos.nix
      ../modules/nixos/tailscale.nix
      ../modules/pi/nixos.nix
    ];

    homeModules =
      commonHome
      ++ graphicalHome
      ++ [
        ../modules/desktop/niri/home.nix
        ../modules/dev/home.nix
        ../modules/pi/home.nix
      ];
  };
}
