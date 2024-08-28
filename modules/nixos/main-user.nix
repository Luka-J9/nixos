{
  lib,
  config,
  pkgs,
  types,
  ...
}:

let
  cfg = config.main-user;
in
{
  options = {
    main-user = {
      enable = lib.mkEnableOption "enable user module";

      userName = lib.mkOption {
        default = "mainuser";
        description = ''
          username
        '';
      };

      description = lib.mkOption {
        default = "Main User";
        description = ''
          User's Full Name
        '';
      };

      packages = lib.mkOption {
        type = with lib.types; listOf package;
        default = [ ];
        description = " A list of packages to include in the user's setup";
      };

      hashedPasswordFile = lib.mkOption {
        type = lib.types.str;
        description = "The password of the user using `mkpasswd -m sha-512`";
      };
    };

  };
  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = cfg.description;
      hashedPasswordFile = cfg.hashedPasswordFile;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = cfg.packages;
    };
  };
}
