{
  inputs,
  home-manager,
  mkPkgs,
}:

host:

home-manager.lib.homeManagerConfiguration {
  pkgs = mkPkgs host.system;

  extraSpecialArgs = {
    inherit inputs host;
  };

  modules = host.homeModules;
}
