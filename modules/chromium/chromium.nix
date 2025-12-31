{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
      ];
    };
  };

}
