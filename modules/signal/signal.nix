{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Added the flag to a variable for consistency
  signalFlags = "--password-store=\"gnome-libsecret\"";

  defaults = {
    autostart = {
      enable = true;
      background = true;
    };
  };

  cfg =
    defaults // (if config ? programs && config.programs ? signal then config.programs.signal else { });
in

{
  config = {
    home.packages = with pkgs; [ signal-desktop ];

    home.sessionVariables = {
      SIGNAL_PASSWORD_STORE = "gnome-libsecret";
    };

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
