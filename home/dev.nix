{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Language/toolchain managers
    go
    nodejs_24
    pnpm
    rustup
    zig
    uv
    cargo

    # Build tooling
    clang
    lld
    cmake
    ninja
    pkg-config
    gnumake
  ];
}
