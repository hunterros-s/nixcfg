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

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          overlays = [ inputs.llm-agents.overlays.default ];
        };

      mkHome = system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = { inherit inputs; };
          modules = [ module ];
        };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
        ];
      };

      homeConfigurations."hunter-arch" =
        mkHome "x86_64-linux" ./hosts/arch/home.nix;

      homeConfigurations."hunter-mac" =
        mkHome "aarch64-darwin" ./hosts/mac/home.nix;
    };
}
