{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    home.packages = with pkgs; [

      nixd

      cosmic-term
      bazel

      bash

      scala
      scalafmt
      scalafix
      scala-cli
      sbt
      mill
      graalvm-ce
      metals
      bloop

      rustc
      rustup

      direnv
      devenv

      nixfmt-rfc-style

      gleam

      jq

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
      userSettings =
          {
            "files.autoSave" = "off";
            "files.watcherExclude" = {
              "**/.bloop" = true;
              "**/.metals" = true;
              "**/.ammonite" = true;
            };
          };
    };

    xdg.desktopEntries = {
      code = {
        name = "Visual Studio Code";
        exec = "code --reuse-window %F";
        icon = "vscode";
        categories = [
          "Utility"
          "TextEditor"
          "Development"
          "IDE"
        ];
        comment = "Code Editing. Redefined";
        genericName = "Text Editor";
        startupNotify = true;
        type = "Application";
        actions = {
          "new-empty-window" = {
            exec = "code --new-window %F";
            icon = "vscode";
            name = "New Empty Window";
          };
          "nix-os-env" = {
            exec = "code --new-window /etc/nixos";
            icon = "vscode";
            name = "Open Nix Configuration";
          };
        };
      };
    };
  };
}
