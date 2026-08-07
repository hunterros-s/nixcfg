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

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkHome =
        host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs host.system;

          extraSpecialArgs = {
            inherit inputs host;
          };

          modules = [ host.homeModule ];
        };

      mkNixos =
        host:
        nixpkgs.lib.nixosSystem {
          inherit (host) system;

          specialArgs = {
            inherit inputs host;
          };

          modules = [
            host.nixosModule

            {
              nixpkgs.pkgs = mkPkgs host.system;
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
        };

      homeHosts = lib.filterAttrs (_: host: host.kind == "home") hosts;
      nixosHosts = lib.filterAttrs (_: host: host.kind == "nixos") hosts;
    in
    {
      formatter = lib.genAttrs systems (system: (mkPkgs system).nixfmt-tree);

      homeConfigurations = lib.mapAttrs (_: host: mkHome host) homeHosts;

      nixosConfigurations = lib.mapAttrs (_: host: mkNixos host) nixosHosts;

      # Repo shell: pinned home-manager CLI + the rebuild/nixfmt tools you
      # actually use via `make`. Enable with `direnv allow` (see .envrc).
      devShells = lib.genAttrs systems (system: {
        default = (mkPkgs system).mkShell {
          packages = [
            home-manager.packages.${system}.default
            (mkPkgs system).nixos-rebuild
            (mkPkgs system).nixfmt-rfc-style
          ];
        };
      });
    };
}
