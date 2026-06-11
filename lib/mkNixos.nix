{
  inputs,
  nixpkgs,
  home-manager,
}:

host:

nixpkgs.lib.nixosSystem {
  system = host.system;

  specialArgs = {
    inherit inputs host;
  };

  modules = host.nixosModules ++ [
    {
      nixpkgs.config.allowUnfree = true;
    }

    home-manager.nixosModules.home-manager

    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        extraSpecialArgs = {
          inherit inputs host;
        };

        users.${host.user.name}.imports = host.homeModules;
      };
    }
  ];
}
