{
  config,
  lib,
  pkgs,
  ...
}:

let
  wallpaper = (config.home.gnome or { }).wallpaper;
  faceFile = (config.home.gnome or { }).face;
in
{
  options = {
    home.gnome.wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the wallpaper image file to use for GNOME background.";
    };

    home.gnome.face = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to the face/profile image file.";
    };
  };

  config = {
    home.file = {
      ".face" = {
        source = faceFile;
      };
    };

    # The following was determined by executing `dconf watch /` and manually encoding what was found
    dconf.settings = {
      "org/gnome/shell" = {
        favorite-apps = [
          "chromium-browser.desktop"
          "code.desktop"
          "discord.desktop"
          "steam.desktop"
          "signal.desktop"
          "1password.desktop"
        ];
        enabled-extensions = [
          "dash-to-dock@micxgx.gmail.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "blur-my-shell@aunetx"
          "clipboard-history@alexsaveau.dev"
          "space-bar@luchrioh"
          "unblank@sun.wxg@gmail.com"
          "just-perfection-desktop@just-perfection"
          "pop-shell@system76.com"
          "windowIsReady_Remover@nunofarruca@gmail.com"
          "appindicatorsupport@rgcjonas.gmail.com"
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
      };
      "org/gnome/settings-deamon/plugins/power" = {
        power-button-action = "interactive";
      };
      "org/gnome/desktop/interface" = {
        clock-format = "12h";
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        apply-custom-theme = true;
        custom-theme-shrink = true;
      };

      # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      #   binding = "<Control><Alt>t";
      #   command = "cosmic-term";
      #   name = "Terminal";
      # };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      #Background
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "${wallpaper}";
        picture-uri-dark = "${wallpaper}";
        primary-color = "#000000000000";
        secondary-color = "#000000000000";
      };

    };
  };

}
