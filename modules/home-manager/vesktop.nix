{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vesktop;
in
{

  options = {
    programs = {
      vesktop = {
        enable = lib.mkEnableOption "Enable Vesktop";

        autostart = {
          enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable autostarting Vesktop";
            default = false;
          };
          background = lib.mkOption {
            type = lib.types.bool;
            description = "Set vesktop to run in background";
            default = false;
          };
        };
      };
    };

  };

  config = {
    home.packages = with pkgs; [ vesktop ];
    home.file = {

      ".config/autostart/${pkgs.vesktop.pname}.desktop" = {
        text = ''
          [Desktop Entry]
          Categories=Network;InstantMessaging;Chat
          Exec=vesktop ${if cfg.autostart.background then "--start-minimized" else ""} %U
          GenericName=Internet Messenger
          Icon=vesktop
          Keywords=discord;vencord;electron;chat
          Name=Vesktop
          StartupWMClass=Vesktop
          Type=Application
        '';
      };
    };
  };

}
