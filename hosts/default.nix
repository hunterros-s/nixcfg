# Host registry. Each host is data (kind/system/user) plus a minimal
# homeModule that pulls in the shared base and only its own deltas.
let
  hunter = import ../users/hunter.nix;
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
        ../modules/home/base.nix
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

    homeModule.imports = [ ../modules/home/base.nix ];
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

    homeModule = {
      imports = [
        ../modules/home/base.nix
        ../modules/home/dev.nix
        ../modules/home/desktop
      ];
    };

    nixosModule = ./aspire/nixos.nix;
  };
}
