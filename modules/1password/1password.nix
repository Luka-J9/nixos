{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.onepassword;
in {
  options.my.onepassword = {
    enable = mkEnableOption "Enable 1Password CLI and GUI with Polkit";
    
    username = mkOption {
      type = types.str;
      description = "The username to grant Polkit access for 1Password";
      default = "luka"; # Fallback default
    };
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ cfg.username ];
    };
  };
}
