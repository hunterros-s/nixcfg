{
  inputs,
  nixpkgs,
  home-manager,
}:

host:

let
  components = map (path: import path) host.modules;
  homeModules = builtins.catAttrs "home" components;
  nixosModules = builtins.catAttrs "nixos" components;
in
nixpkgs.lib.nixosSystem {
  system = host.system;

  specialArgs = {
    inherit inputs host;
  };

  modules = nixosModules ++ [
    {
      nixpkgs.config.allowUnfree = true;
    }

    home-manager.nixosModules.home-manager

    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";

        extraSpecialArgs = {
          inherit inputs host;
        };

        users.${host.user.name}.imports = [ ./homeBase.nix ] ++ homeModules;
      };
    }
  ];
}
