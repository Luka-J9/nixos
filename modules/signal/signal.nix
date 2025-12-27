{
  config,
  lib,
  pkgs,
  ...
}:

let
  defaults = {
    autostart = { enable = true; background = true; };
  };

  cfg = defaults // (if config ? programs && config.programs ? signal then config.programs.signal else {});
in

{
  config = {
    home.packages = with pkgs; [ signal-desktop ];
    home.file = {

      ".config/autostart/${pkgs.signal-desktop.pname}.desktop" = {
        text = ''
          [Desktop Entry]
          Name=Signal
          Exec=${pkgs.signal-desktop.outPath}/bin/signal-desktop --no-sandbox ${
            if cfg.autostart.background then "--start-in-tray" else ""
          } %U
          Terminal=false
          Type=Application
          Icon=signal-desktop
          StartupWMClass=signal
          Comment=Private messaging from your desktop
          MimeType=x-scheme-handler/sgnl;x-scheme-handler/signalcaptcha;
          Categories=Network;InstantMessaging;Chat;    
        '';
      };
    };
  };

}