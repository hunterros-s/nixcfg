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

      # nixpkgs with unfree software enabled, one instance per system.
      archPkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      macPkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };

      # Args every module receives: the flake inputs (pi.nix and minecraft.nix
      # need them) plus this host's metadata from hosts/default.nix.
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

      # Home-manager-only machines (non-NixOS).
      homeConfigurations = {
        hunter-arch = home-manager.lib.homeManagerConfiguration {
          pkgs = archPkgs;
          extraSpecialArgs = args hosts.hunter-arch;
          modules = [ hosts.hunter-arch.homeModule ];
        };

        # AMD GPU setup for hunter-arch (run once per driver change):
        #   nix build .#homeConfigurations.hunter-arch.config.targets.genericLinux.gpu.setupPackage
        # then run the resulting bin/non-nixos-gpu-setup with sudo.

        hunter-mac = home-manager.lib.homeManagerConfiguration {
          pkgs = macPkgs;
          extraSpecialArgs = args hosts.hunter-mac;
          modules = [ hosts.hunter-mac.homeModule ];
        };
      };

      # NixOS machine. aspire's home-manager config lives inside the system
      # (see the home-manager NixOS module below), so there is deliberately no
      # standalone homeConfigurations.aspire. Always build it with
      # `nixos-rebuild`, not `home-manager`.
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