# Host registry. Each host is data (system/user/stateVersion) plus a
# minimal homeModule that pulls in the shared base and only its own deltas.
let
  hunter = import ../users/hunter.nix;
in
{
  hunter-arch = {
    hostname = "arch";
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
      ];
    };

    nixosModule = ./aspire/nixos.nix;
  };
}
