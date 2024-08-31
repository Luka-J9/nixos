{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.signal;
in
{

  options = {
    programs = {
      signal = {
        enable = lib.mkEnableOption "Enable Signal";

        autostart = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable autostarting Signal";
            default = false;
          };
          background = lib.mkOption {
            type = lib.types.bool;
            description = "Set signal to run in background";
            default = false;
          };
        };
      };
    };

  };

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
