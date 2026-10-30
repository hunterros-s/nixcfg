{ pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  home.packages = with pkgs; [
    # Language/toolchain managers
    go
    nodejs_24
    pnpm
    uv
  ] ++ (with unstable; [
    rustc
    cargo
    clippy
    rustfmt
  ]);
}
