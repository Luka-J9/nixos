{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  toggle-mic = pkgs.writeShellApplication {
    name = "toggle-mic";
    runtimeInputs = [ pkgs.pamixer ];
    text = builtins.readFile ./scripts/toggle-mic.sh;
  };

  power-menu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [ pkgs.rofi ];
    text = ''
      entries="󰌾\n󰤄\n󰑓\n⏻"
      chosen=$(printf '%b' "$entries" | rofi -dmenu -p "" -no-custom \
        -theme "${./rofi/power-menu.rasi}")
      case "$chosen" in
        "󰌾") hyprlock ;;
        "󰤄") systemctl suspend ;;
        "󰑓") systemctl reboot ;;
        "⏻") systemctl poweroff ;;
      esac
    '';
  };

  keybind-hint = pkgs.writeShellApplication {
    name = "keybind-hint";
    runtimeInputs = [ pkgs.jq pkgs.hyprland ];
    text = ''
      hyprctl binds -j | jq -r '
        def bit(m; n): (m / n | floor) % 2;
        def dsp(d): d | ltrimstr("HL.Dispatcher(") | rtrimstr(")");
        .[] | select(.submap == "" and .has_description == true) |
        . as $bind |
        [
          if bit($bind.modmask; 64) == 1 then "SUPER" else empty end,
          if bit($bind.modmask;  1) == 1 then "SHIFT" else empty end,
          if bit($bind.modmask;  4) == 1 then "CTRL"  else empty end,
          if bit($bind.modmask;  8) == 1 then "ALT"   else empty end,
          $bind.key
        ] | join("+") as $binding |
        "\($binding)\t\($bind.description)"
      ' | awk -F'\t' '{printf "%-28s %s\n", $1, $2}' \
        | rofi -dmenu -i -p " Keybinds" -no-custom \
               -theme-str 'window { width: 55%; } listview { lines: 30; }'
    '';
  };

  # Hyprland >=0.56 dropped the "id" field from the `workspaces` IPC reply, which
  # Waybar 0.15.0's hyprland/workspaces module still relies on to recognize a
  # newly created workspace (see Alexays/Waybar#5316): the id always parses as 0,
  # so a workspace created after Waybar starts never matches and never gets a
  # button. This backports the relevant bit of the (as-yet unmerged) upstream fix
  # in Alexays/Waybar#5324 - fall back to matching by name, same as Waybar's own
  # workspace-dedup logic already does elsewhere in that file.
  waybar-fixed = pkgs.waybar.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./patches/waybar-workspace-created-name-fallback.patch ];
  });
in
{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    image = ./wallpapers/artii-rise.jpg;
    polarity = "dark";

    targets.vscode = {
      enable = false;
    };
    targets.obsidian = {
      enable = false;
    };
    targets.zed = {
      enable = false;
    };
    targets.ghostty = {
      enable = false;
    };

    opacity = {
      desktop = 0.6;
      terminal = 0.9;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      sizes = {
        applications = 11;
        terminal = 14;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    targets.hyprland.enable = true;
    targets.hyprland.hyprpaper.enable = true;
    targets.waybar.enable = true;
    targets.rofi.enable = false;
  };

  programs.rofi = {
    enable = true;
    theme = ./rofi/theme.rasi;
    font = "JetBrainsMono Nerd Font Mono 12";
    terminal = "ghostty";
  };
  programs.waybar = {
    enable = true;
    package = waybar-fixed;
    # Run waybar as a systemd user service so it gets restarted (not left
    # running as a stale, desynced process) on every home-manager switch,
    # instead of only ever being launched once via exec-once at login.
    systemd.enable = true;
  };
  services.mako = {
    enable = true;
    settings = {
      # Appearance
      font = lib.mkForce "JetBrainsMono Nerd Font 10";
      # background-color = "#1e1e2ecc";
      # text-color = "#cdd6f4";
      # border-color = "#89b4fa";
      border-size = 0;
      border-radius = 12;
      padding = "12";
      margin = "10,20";
      width = 320;
      height = 100;
      max-icon-size = 48;
      markup = true;
      actions = true;

      # Behavior
      default-timeout = 4000;
      ignore-timeout = false;
      group-by = "app-name";
      max-visible = 4;
      layer = "overlay";
      anchor = "top-right";
    };
  };

  services.hyprpaper.enable = true;
  services.blueman-applet.enable = true;

  home.file = {
    ".config/waybar" = {
      source = ./waybar;
      recursive = true;
    };

  };

  home.packages = with pkgs; [
    pamixer
    toggle-mic
    keybind-hint
    pavucontrol # audiocontrol
    material-symbols
    font-awesome # For the Font Awesome glyphs
    nerd-fonts.symbols-only # The "Master" icon font for 2026
    nerd-fonts.jetbrains-mono
    blueman
    libappindicator-gtk3 # Required for modern tray icon support
    nautilus
    nautilus-open-any-terminal
    power-menu
    grimblast
    satty
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;
    extraConfig = ''
      local mainMod = "SUPER"
      local terminal = "ghostty"
      local filemanager = "nautilus"
      local browser = "chromium"
      local code = "code"
      local menu = "rofi -show drun"

      hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "default" })
      hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "default" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default" })

      hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

      hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = "1" })

      hl.on("hyprland.start", function()
          hl.exec_cmd("uwsm finalize SSH_AUTH_SOCK")
          hl.exec_cmd("hyprlock && uwsm app -- signal-desktop --start-in-tray --password-store=\"gnome-libsecret\"")
          hl.exec_cmd("uwsm app -- 1password --silent")
          hl.exec_cmd("uwsm app -- discord --start-minimized")
          hl.exec_cmd("wpctl status > /dev/null && wpctl inspect @DEFAULT_SOURCE@ > /dev/null")
      end)

      -- Apps
      hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal),    { description = "Launch terminal" })
      hl.bind(mainMod .. " + e",      hl.dsp.exec_cmd(filemanager), { description = "Open file manager" })
      hl.bind(mainMod .. " + b",      hl.dsp.exec_cmd(browser),     { description = "Open browser" })
      hl.bind(mainMod .. " + v",      hl.dsp.exec_cmd(code),        { description = "Open VS Code" })
      hl.bind(mainMod .. " + o",      hl.dsp.exec_cmd(menu),        { description = "App launcher" })

      -- Window management
      hl.bind(mainMod .. " + q",   hl.dsp.window.close(),                                         { description = "Close window" })
      hl.bind(mainMod .. " + f",   hl.dsp.window.float({ action = "toggle" }),                    { description = "Toggle float" })
      hl.bind(mainMod .. " + s",   hl.dsp.window.float({ action = "toggle" }),                    { description = "Toggle float" })
      hl.bind(mainMod .. " + m",   hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),  { description = "Toggle maximize" })
      hl.bind(mainMod .. " + t",   hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Toggle fullscreen" })
      hl.bind(mainMod .. " + J",   hl.dsp.layout("togglesplit"),                                  { description = "Toggle split direction" })
      hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next({ next = true }),                     { description = "Cycle next window" })

      -- Focus
      hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  { description = "Focus left" })
      hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
      hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    { description = "Focus up" })
      hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  { description = "Focus down" })

      -- Move windows
      hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
      hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
      hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
      hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })

      -- Layout swap
      hl.bind(mainMod .. " + CTRL + down", hl.dsp.exec_cmd("hyprctl dispatch layoutmsg togglesplit ; hyprctl dispatch swapwindow d"), { description = "Swap split down" })
      hl.bind(mainMod .. " + CTRL + up",   hl.dsp.exec_cmd("hyprctl dispatch layoutmsg togglesplit ; hyprctl dispatch swapwindow u"), { description = "Swap split up" })

      -- Workspaces
      hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }), { description = "Go to workspace 1" })
      hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }), { description = "Go to workspace 2" })
      hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }), { description = "Go to workspace 3" })
      hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }), { description = "Go to workspace 4" })
      hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }), { description = "Go to workspace 5" })
      hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }), { description = "Go to workspace 6" })
      hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }), { description = "Go to workspace 7" })
      hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }), { description = "Go to workspace 8" })
      hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }), { description = "Go to workspace 9" })

      hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }), { description = "Move window to workspace 1" })
      hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }), { description = "Move window to workspace 2" })
      hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }), { description = "Move window to workspace 3" })
      hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }), { description = "Move window to workspace 4" })
      hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }), { description = "Move window to workspace 5" })
      hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }), { description = "Move window to workspace 6" })
      hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }), { description = "Move window to workspace 7" })
      hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }), { description = "Move window to workspace 8" })
      hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }), { description = "Move window to workspace 9" })

      -- Screenshots
      hl.bind(mainMod .. " + p",         hl.dsp.exec_cmd("grimblast --notify copy area"),        { description = "Screenshot region → clipboard" })
      hl.bind(mainMod .. " + SHIFT + p", hl.dsp.exec_cmd("grimblast save area - | satty -f -"), { description = "Screenshot region → annotate" })

      -- System
      hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd("hyprlock"),                              { description = "Lock screen" })
      hl.bind(mainMod .. " + SHIFT + q",  hl.dsp.exec_cmd("${power-menu}/bin/power-menu"),                          { description = "Power menu", locked = true })
      hl.bind(mainMod .. " + Delete",     hl.dsp.exec_cmd("${toggle-mic}/bin/toggle-mic"),           { description = "Toggle microphone mute" })
      hl.bind(mainMod .. " + slash",      hl.dsp.exec_cmd("${keybind-hint}/bin/keybind-hint"),       { description = "Show keybind hints" })
      hl.bind("XF86AudioMute",            hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { description = "Toggle audio mute" })

      -- Volume (repeat)
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, description = "Volume up" })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, description = "Volume down" })

      -- Mouse
      hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
      hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

      -- Game window rules
      hl.window_rule({ match = { initial_class = "^(steam_app_\\d+)$" }, tag = "+game" })
      hl.window_rule({ match = { tag = "game" }, fullscreen = 1, immediate = true, workspace = "9" })

      hl.config({
          animations = { enabled = true },
          decoration = {
              rounding = 10,
              blur = { enabled = true, size = 5, passes = 3 },
          },
          dwindle = { force_split = 2, preserve_split = true },
          layout  = { single_window_aspect_ratio = "6 4" },
          misc    = { focus_on_activate = true },
      })
    '';
  };

  programs.hyprlock = {
    enable = true;

    settings = {
      # BACKGROUND
      background = {
        monitor = "";
        # path = ./wallpapers/shorewallpaper-ultrawide.png;
        blur_passes = 3;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      general = {
        hide_cursor = false;
      };

      # Profile-Photo
      image = [
        {
          monitor = "";
          path = "${./icons/profile-2.png}";
          border_size = 2;
          border_color = "rgba(255, 255, 255, 0)";
          size = 200;
          rounding = -1;
          rotate = 0;
          reload_time = -1;
          reload_cmd = "";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
      ];

      # LABELS (Date, Time, User, Song)
      label = [
        # Day-Month-Date
        {
          monitor = "";
          text = "cmd[update:1000] echo -e \"$(date +\"%A, %B %d\")\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 25;
          font_family = "SF Pro Display Bold";
          position = "0, 350";
          halign = "center";
          valign = "center";
        }
        # Time
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<span>$(date +\"%I:%M\")</span>\"";
          color = "rgba(216, 222, 233, 0.70)";
          font_size = 120;
          font_family = "SF Pro Display Bold";
          position = "0, 250";
          halign = "center";
          valign = "center";
        }
        # USER
        {
          monitor = "";
          text = "Luka Jurukovski";
          color = "rgba(216, 222, 233, 0.80)";
          # outline_thickness = 2;
          font_size = 18;
          font_family = "SF Pro Display Bold";
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
        # Power icons — bottom-right corner, clickable
        {
          monitor = "";
          text = "⏻";
          color = "rgba(255, 85, 85, 0.80)";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "-20, 30";
          halign = "right";
          valign = "bottom";
          onclick = "systemctl poweroff";
        }
        {
          monitor = "";
          text = "󰑓";
          color = "rgba(255, 184, 108, 0.80)";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "-65, 30";
          halign = "right";
          valign = "bottom";
          onclick = "systemctl reboot";
        }
        {
          monitor = "";
          text = "󰤄";
          color = "rgba(139, 233, 253, 0.80)";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font Mono";
          position = "-110, 30";
          halign = "right";
          valign = "bottom";
          onclick = "systemctl suspend";
        }
      ];

      # INPUT FIELD
      "input-field" = {
        monitor = "";
        size = "300, 45";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.2;
        dots_center = true;
        rounding = 25;
        inner_color = lib.mkForce "rgba(255, 255, 255, 0.05)";
        font_family = "SF Pro Display Bold";
        placeholder_text = "<i><span foreground=\"##ffffff99\">Enter Password...</span></i>";
        hide_input = false;
        fade_on_empty = false;
        position = "0, -175";
        halign = "center";
        valign = "center";
      };
    };
  };
}
