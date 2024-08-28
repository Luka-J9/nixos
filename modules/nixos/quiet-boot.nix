{
  lib,
  config,
  pkgs,
  types,
  ...
}:

let
  quiet-boot = config.quiet-boot;
in
{
  options = {
    quiet-boot = {
      enable = lib.mkEnableOption "enable quiet boot";
    };
  };

  config = {
    boot =
      lib.mkIf quiet-boot.enable {
        # Plymouth
        consoleLogLevel = 0;
        initrd.verbose = false;
        plymouth.enable = true;
        kernelParams = [
          "quiet"
          "splash"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
          "boot.shell_on_fail"
        ];

        # Boot Loader settings when quiet is enabled
        loader = {
          timeout = 0;
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
          # Other loader settings can be added here if needed
        };
      }
      // lib.mkIf (!quiet-boot.enable) {
        # Boot Loader settings when quiet is disabled
        loader = {
          #  grub.enable = true;
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
          # Other loader settings can be added here if needed
        };
      };
  };
}
