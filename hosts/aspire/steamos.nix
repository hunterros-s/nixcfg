{ inputs, pkgs, ... }:
{
  imports = [
    inputs.jovian-nixos.nixosModules.default
  ];

  # Controller-first HTPC: boot straight into the Steam Deck UI. The session is
  # gamescope running Steam with `-steamos3 -gamepadui` (Jovian's patched
  # gamescope-session), which is what makes the Steam UI show its WiFi and
  # Bluetooth panels. `autoStart` wires up SDDM auto-login for `hunter` and
  # relogs if the session dies, so no keyboard is ever needed at boot.
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "hunter";
    # No desktop environment; "Switch to Desktop" just relaunches Gaming Mode.
    desktopSession = "gamescope-wayland";
  };

  # The Deck UI's Bluetooth panel talks to BlueZ (WiFi settings already work
  # through NetworkManager, enabled in ./nixos.nix).
  hardware.bluetooth.enable = true;

  # Audio for the TV / soundbar, plus Bluetooth audio device support.
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
  };
}