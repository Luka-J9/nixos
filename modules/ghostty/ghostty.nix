{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Dracula";
      };
    };

    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Control><Alt>t";
        command = "ghostty";
        name = "Terminal";
      };
    };
  };

}
