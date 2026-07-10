let
  hunter = import ../users/hunter.nix;

  common = [
    ../modules/cli.nix
    ../modules/tmux.nix
    ../modules/fzf.nix
    ../modules/direnv.nix
    ../modules/git.nix
    ../modules/zsh.nix
    ../modules/neovim.nix
    ../modules/pi.nix
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
      terminal = "/usr/bin/alacritty";
      cpuTemp = "/sys/class/hwmon/hwmon2/temp1_input";
      gpu = {
        busy = "/sys/class/drm/card1/device/gpu_busy_percent";
        temp = "/sys/class/hwmon/hwmon1/temp1_input";
      };
    };

    modules = common ++ [
      ./arch.nix
      ../modules/dev.nix
      ../modules/alacritty.nix
      ../modules/niri
      ../modules/waybar.nix
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

    modules = common;
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

    modules = common ++ [
      ./aspire
      ../modules/system.nix
      ../modules/openssh.nix
      ../modules/tailscale.nix
      ../modules/dev.nix
      ../modules/alacritty.nix
      ../modules/niri
      ../modules/waybar.nix
    ];
  };
}
