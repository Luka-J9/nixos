{
  lib,
  config,
  pkgs,
  types,
  ...
}:

#Following module inspired by: https://discourse.nixos.org/t/setting-the-user-profile-image-under-gnome/36233
let
  profile = config.profile;
in
{
  options = {
    profile = {
      enable = lib.mkEnableOption "enable profile picture module";

      userName = lib.mkOption {
        type = lib.types.str;
        description = "The username that will be modified, this should match with the file path";
      };

    };
  };

  config = lib.mkIf profile.enable {
    system.activationScripts.script.text = ''
      mkdir -p /var/lib/AccountsService/{icons,users}
      cp /home/${profile.userName}/.face /var/lib/AccountsService/icons/${profile.userName}
      echo -e "[User]\nIcon=/var/lib/AccountsService/icons/${profile.userName}\n" > /var/lib/AccountsService/users/${profile.userName}

      chown root:root /var/lib/AccountsService/users/${profile.userName}
      chmod 0600 /var/lib/AccountsService/users/${profile.userName}

      chown root:root /var/lib/AccountsService/icons/${profile.userName}
      chmod 0444 /var/lib/AccountsService/icons/${profile.userName}
    '';
  };
}
