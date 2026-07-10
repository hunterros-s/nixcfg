{
  home =
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

        # Build tooling
        clang
        lld
        cmake
        ninja
        pkg-config
        gnumake

        # Useful development CLIs
        jq
        yq
        just
        shellcheck
      ];
    };
}
