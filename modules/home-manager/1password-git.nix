{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config._1password-git;
  isKeySet = lib.hasAttr "key" cfg.signing && cfg.signing.key != "";
in
{

  options = {
    _1password-git = {
      enable = lib.mkEnableOption "enable git with 1password settings";

      agent-conf = lib.mkOption {
        type = lib.types.path;
        description = "the path to the `agent.toml` configuration see `https://developer.1password.com/docs/ssh/agent/config/`";
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "The email used for git configuration. See `https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup`";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "The name used for git configuration. See `https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup`";
      };

      signing.key = lib.mkOption {
        type = lib.types.str;
        description = "The public key of what was used to sign the commit";
      };

      autostart = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Enable autostarting 1password";
          default = false;
        };
        background = lib.mkOption {
          type = lib.types.bool;
          description = "Set 1password to autostart in the background";
          default = false;
        };
      };

    };
  };

  config = {

    home.packages = with pkgs; [
      _1password-gui
      _1password
    ];

    home.file = {
      ".config/1Password/ssh/agent.toml" = {
        source = cfg.agent-conf;
      };

      ".config/autostart/${pkgs._1password-gui.pname}.desktop" = lib.mkIf cfg.autostart.enable {
        text = ''
          [Desktop Entry]
          Name=1Password
          Exec=1password %U ${if cfg.autostart.background then "--silent" else ""}
          Terminal=false
          Type=Application
          Icon=1password
          StartupWMClass=1Password
          Comment=Password manager and secure wallet
          MimeType=x-scheme-handler/onepassword;
          Categories=Office;
        '';
      };
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentityAgent ${config.home.homeDirectory}/.1password/agent.sock
      '';
    };

    programs.git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        safe.directory = "/etc/nixos";
        branch.autoSetupRebase = "always";
        push.autoSetupRemote = true;
        gpg = {
          format = "ssh";
        };
        "gpg \"ssh\"" = {
          program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
        };
        commit = {
          gpgsign = true;
        };

        user = {
          email = cfg.email;
          name = cfg.email;
          signingKey = if isKeySet then cfg.signing.key else null;
        };
      };
    };
  };

}
