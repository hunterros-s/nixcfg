{
  description = "hunter's nix config";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      llm-agents,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
        };

      mkHome =
        system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {
            llmAgents = llm-agents;
          };
          modules = [ module ];
        };
    in
    {
      formatter = nixpkgs.lib.genAttrs systems (system: (mkPkgs system).nixfmt-tree);

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = {
              llmAgents = llm-agents;
            };
          }
        ];
      };

      homeConfigurations."hunter-arch" = mkHome "x86_64-linux" ./hosts/arch/home.nix;

      homeConfigurations."hunter-mac" = mkHome "aarch64-darwin" ./hosts/mac/home.nix;
    };
}
