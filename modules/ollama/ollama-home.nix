{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
{
  config = {
    xdg.desktopEntries.openwebui = {
      name = "Open WebUI";
      exec = "chromium --app=http://localhost:8083";
      icon = "${./icons/logo-dark.png}";
      categories = [ "Network" "WebBrowser" ];
      comment = "Open WebUI interface";
      startupNotify = true;
      # This might help with some desktop environments
      terminal = false;
    };
  };
}