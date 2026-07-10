{
  lib,
  pkgs,
  host,
  ...
}:

let
  desktop = host.desktop or { };
  waybar = desktop.waybar or { };
  gpu = waybar.gpu or { };

  terminalExe = desktop.terminal or (lib.getExe pkgs.alacritty);
  btopExe = lib.getExe pkgs.btop;
  pavucontrolExe = lib.getExe pkgs.pavucontrol;
  overskrideExe = lib.getExe pkgs.overskride;

  hasCpuTemp = waybar ? cpuTemp;
  hasGpuBusy = gpu ? busy;
  hasGpuTemp = gpu ? temp;
  hasGpu = hasGpuBusy || hasGpuTemp;
in
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    btop
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    networkmanager
    overskride
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings.mainBar = {
      layer = "top";
      position = "top";
      spacing = 16;
      height = 24;

      modules-left = [ "clock" ];
      modules-center = [ "niri/window" ];
      modules-right = [
        "pulseaudio"
        "network"
        "bluetooth"
        "group/cpu"
      ]
      ++ lib.optionals hasGpu [ "group/gpu" ]
      ++ [ "memory" ];

      clock = {
        format = "{:%a %b %e %I:%M %p}";
        tooltip = false;
      };

      "niri/window" = {
        format = "{title}";
      };

      network = {
        format = "{icon} {essid} ({signalStrength}%)";
        format-icons = {
          wifi = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          ethernet = [ "󰈀" ];
          disconnected = [ "󰤭" ];
        };
        tooltip = true;
        tooltip-format = "SSID: {essid}\nStrength: {signalStrength}%\nIP: {ipaddr}";
        tooltip-format-disconnected = "Disconnected";
        on-click = "${terminalExe} -e ${pkgs.networkmanager}/bin/nmtui";
      };

      bluetooth = {
        format = " ({num_connections} connected)";
        on-click = overskrideExe;
        tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
        tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
        tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
      };

      pulseaudio = {
        scroll-step = 5;
        format = "{icon}  {volume}%";
        format-bluetooth = " {icon}";
        format-muted = "";
        format-icons = {
          "default" = [
            ""
            ""
            ""
          ];
        };
        tooltip = true;
        tooltip-format = "Volume: {volume}%\nMicrophone: {format_source}";
        on-click = pavucontrolExe;
      };

      memory = {
        format = "RAM {used:0.1f}GB";
        on-click = "${terminalExe} -e ${btopExe}";
      };

      "group/cpu" = {
        orientation = "horizontal";
        modules = [ "cpu" ] ++ lib.optionals hasCpuTemp [ "temperature#cpu" ];
      };

      cpu = {
        format = "CPU {usage}%";
        on-click = "${terminalExe} -e ${btopExe}";
      };

      "temperature#cpu" = lib.mkIf hasCpuTemp {
        hwmon-path = waybar.cpuTemp;
        critical-threshold = 80;
        format = " {temperatureC}°C";
        on-click = "${terminalExe} -e ${btopExe}";
      };

      "group/gpu" = lib.mkIf hasGpu {
        orientation = "horizontal";
        modules =
          lib.optionals hasGpuBusy [ "custom/gpu-util" ] ++ lib.optionals hasGpuTemp [ "temperature#gpu" ];
      };

      "custom/gpu-util" = lib.mkIf hasGpuBusy {
        exec = "cat ${gpu.busy}";
        format = "GPU {}%";
        interval = 1;
        on-click = "${terminalExe} -e ${btopExe}";
      };

      "temperature#gpu" = lib.mkIf hasGpuTemp {
        hwmon-path = gpu.temp;
        critical-threshold = 80;
        format = " {temperatureC}°C";
        on-click = "${terminalExe} -e ${btopExe}";
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", "Symbols Nerd Font", "sans-serif";
        font-size: 14px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0.65);
        color: #ffffff;
      }

      #clock,
      #pulseaudio,
      #network,
      #bluetooth,
      #cpu,
      #memory,
      #temperature {
        margin: 0px 4px;
      }

      .modules-left {
        margin-left: 12px;
      }

      .modules-right {
        margin-right: 12px;
      }
    '';
  };
}
