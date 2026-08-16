{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Language/toolchain managers
    go
    nodejs_24
    pnpm
    uv

    rustc
    cargo
  ];
}
