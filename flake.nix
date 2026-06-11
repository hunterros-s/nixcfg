{
  description = "hunter's nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      hmSpecialArgs = {
        inherit inputs;
      };

      mkPkgs = system: nixpkgs.legacyPackages.${system};

      mkHome =
        system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = hmSpecialArgs;
          modules = [ module ];
        };
    in
    {
      formatter = nixpkgs.lib.genAttrs systems (system: (mkPkgs system).nixfmt-tree);

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = hmSpecialArgs;
          }
        ];
      };

      homeConfigurations."hunter-arch" = mkHome "x86_64-linux" ./hosts/arch/home.nix;

      homeConfigurations."hunter-mac" = mkHome "aarch64-darwin" ./hosts/mac/home.nix;
    };
}
