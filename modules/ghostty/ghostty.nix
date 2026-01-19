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
  };

}
