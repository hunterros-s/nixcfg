let
  commonHome = [
    ../features/core/home.nix
    ../features/git/home.nix
    ../features/zsh/home.nix
    ../features/neovim/home.nix
  ];
in
{
  arch = {
    kind = "home";
    name = "hunter-arch";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = {
      name = "hunter";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/home/hunter";
    };

    homeModules = commonHome ++ [
      ./arch/home.nix
      ../features/dev/home.nix
      ../features/pi/home.nix
    ];
  };

  mac = {
    kind = "home";
    name = "hunter-mac";
    system = "aarch64-darwin";
    stateVersion = "26.05";

    user = {
      name = "hunterross";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/Users/hunterross";
    };

    homeModules = commonHome ++ [
      ./mac/home.nix
      ../features/pi/home.nix
    ];
  };

  nixos = {
    kind = "nixos";
    name = "nixos";
    system = "x86_64-linux";
    stateVersion = "26.05";

    user = {
      name = "hunter";
      fullName = "Hunter Ross";
      email = "hlross@umich.edu";
      home = "/home/hunter";
    };

    nixosModules = [
      ./nixos/default.nix
      ./nixos/hardware-configuration.nix
      ../features/pi/nixos.nix
    ];

    homeModules = commonHome ++ [
      ./nixos/home.nix
      ../features/dev/home.nix
      ../features/pi/home.nix
    ];
  };
}
