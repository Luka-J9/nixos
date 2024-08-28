{
  config,
  lib,
  pkgs,
  ...
}:
{
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

    home.packages = with pkgs; [
      _1password-gui
      _1password

      bazel

      scala
      scalafmt
      scalafix
      scala-cli
      sbt
      mill
      graalvm-ce

      rustc
      rustup

      direnv
      devenv

      nixfmt-rfc-style

      gleam

    ];
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bazelbuild.vscode-bazel
        vadimcn.vscode-lldb
        fill-labs.dependi
        mkhl.direnv
        bierner.docs-view
        usernamehw.errorlens
        tamasfe.even-better-toml
        oderwat.indent-rainbow
        xyz.local-history
        pkief.material-icon-theme
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        scalameta.metals
        scala-lang.scala
        baccata.scaladex-search
        gleam.gleam
      ];
      userSettings = lib.literalExpression ''
        {
        "files.autoSave" = "off";
        }
      '';
    };
  };
}
