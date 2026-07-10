{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # language/toolchain managers
    go
    nodejs_24
    pnpm
    rustup
    zig
    uv

    # build tooling
    clang
    lld
    cmake
    ninja
    pkg-config
    gnumake

    # useful dev CLIs
    jq
    yq
    just
    shellcheck
  ];
}
