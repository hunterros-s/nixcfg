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
      linuxPkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      macPkgs = import nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    in
    {
      formatter = {
        x86_64-linux = linuxPkgs.nixfmt-tree;
        aarch64-darwin = macPkgs.nixfmt-tree;
      };

      homeConfigurations = {
        hunter-arch = home-manager.lib.homeManagerConfiguration {
          pkgs = linuxPkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              imports = [
                ./home/base.nix
                ./home/dev.nix
              ];

              home.username = "hunter";
              home.homeDirectory = "/home/hunter";

              targets.genericLinux.enable = true;

              home.sessionVariables.ROCM_PATH = "/opt/rocm";

              home.sessionPath = [
                "/opt/rocm/bin"
                "$HOME/.local/bin"
                "$HOME/.npm-global/bin"
              ];
            }
          ];
        };

        hunter-mac = home-manager.lib.homeManagerConfiguration {
          pkgs = macPkgs;
          extraSpecialArgs = { inherit inputs; };
          modules = [
            {
              imports = [ ./home/base.nix ];

              home.username = "hunterross";
              home.homeDirectory = "/Users/hunterross";
            }
          ];
        };
      };

      nixosConfigurations.aspire = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/aspire/nixos.nix
          { nixpkgs.pkgs = linuxPkgs; }
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs; };
              users.hunter = {
                imports = [
                  ./home/base.nix
                  ./home/dev.nix
                ];

                home.username = "hunter";
                home.homeDirectory = "/home/hunter";
              };
            };
          }
        ];
      };
    };
}
