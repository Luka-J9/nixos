{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    home.packages = with pkgs; [ signal-desktop ];

    xdg.desktopEntries = {
      "signal" = {
        name = "Signal";
        exec = "signal-desktop --password-store=\"gnome-libsecret\" %U";
        terminal = false;
        icon = "signal-desktop";
        type = "Application";
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
        mimeType = [ "x-scheme-handler/sgnl" ];
      };
    };
  };
}
