{
  config,
  lib,
  pkgs,
  ...
}:
{

    home.packages = with pkgs; [
      _1password-gui
      _1password
    ];

    config = {
    home.file = {
      ".config/1Password/ssh/agent.toml" = {
        source = ../../dotfiles/1password/agent.toml;
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
          email = "Luka-J9@users.noreply.github.com";
          name = "Luka Jurukovski";
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2WORLWmi4hPbsANjBpP1a9oTHxgG4CeKvwOGwKy+h0";
        };
      };
    };
    };

}
