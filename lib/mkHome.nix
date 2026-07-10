{
  inputs,
  home-manager,
  mkPkgs,
}:

host:

let
  components = map (path: import path) host.modules;
in
home-manager.lib.homeManagerConfiguration {
  pkgs = mkPkgs host.system;

  extraSpecialArgs = {
    inherit inputs host;
  };

  modules = [ ./homeBase.nix ] ++ builtins.catAttrs "home" components;
}
