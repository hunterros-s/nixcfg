{
  inputs,
  nixpkgs,
  home-manager,
}:

host:

nixpkgs.lib.nixosSystem {
  inherit (host) system;

  specialArgs = {
    inherit inputs host;
  };

  modules = [
    host.nixosModule

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

        users.${host.user.name} = host.homeModule;
      };
    }
  ];
}
