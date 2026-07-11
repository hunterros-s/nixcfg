{
  # Also enables GPU support for Nix GUI applications.
  targets.genericLinux.enable = true;

  home.sessionVariables.ROCM_PATH = "/opt/rocm";

  home.sessionPath = [
    "/opt/rocm/bin"
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];
}
