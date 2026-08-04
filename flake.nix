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
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;

      hosts = lib.mapAttrs (name: host: host // { inherit name; }) (import ./hosts);
      systems = lib.unique (map (host: host.system) (lib.attrValues hosts));

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      mkPkgs = system: pkgsFor.${system};

      mkHome = import ./lib/mkHome.nix {
        inherit inputs home-manager mkPkgs;
      };

      mkNixos = import ./lib/mkNixos.nix {
        inherit inputs nixpkgs home-manager;
      };

      homeHosts = lib.filterAttrs (_: host: host.kind == "home") hosts;
      nixosHosts = lib.filterAttrs (_: host: host.kind == "nixos") hosts;
    in
    {
      formatter = lib.genAttrs systems (system: pkgsFor.${system}.nixfmt-tree);

      homeConfigurations = lib.mapAttrs (_: host: mkHome host) homeHosts;

      nixosConfigurations = lib.mapAttrs (_: host: mkNixos host) nixosHosts;
    };
}
