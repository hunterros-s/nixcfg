{
  description = "hunter's nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      hosts = import ./hosts;

      archPkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      macPkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };

      # args every module receives
      args = host: {
        inherit inputs;
        inherit host;
      };
    in
    {
      formatter = {
        x86_64-linux = archPkgs.nixfmt-tree;
        aarch64-darwin = macPkgs.nixfmt-tree;
      };

      homeConfigurations = {
        hunter-arch = home-manager.lib.homeManagerConfiguration {
          pkgs = archPkgs;
          extraSpecialArgs = args hosts.hunter-arch;
          modules = [ hosts.hunter-arch.homeModule ];
        };

        hunter-mac = home-manager.lib.homeManagerConfiguration {
          pkgs = macPkgs;
          extraSpecialArgs = args hosts.hunter-mac;
          modules = [ hosts.hunter-mac.homeModule ];
        };
      };

      nixosConfigurations.aspire = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = args hosts.aspire;
        modules = [
          hosts.aspire.nixosModule
          { nixpkgs.pkgs = archPkgs; }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = args hosts.aspire;
              users.${hosts.aspire.user.name} = hosts.aspire.homeModule;
            };
          }
        ];
      };
    };
}
