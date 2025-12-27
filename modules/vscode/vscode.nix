{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {

    home.packages = with pkgs; [
      git
      nixd
      kitty
      scala
      scalafmt
      scalafix
      scala-cli
      sbt
      mill
      graalvmPackages.graalvm-ce
      metals
      bloop

      direnv
      devenv

      nixfmt-rfc-style

      gleam

      jq
    ];
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
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
      profiles.default.userSettings =
          {
            "files.autoSave" = "off";
            "files.watcherExclude" = {
              "**/.bloop" = true;
              "**/.metals" = true;
              "**/.ammonite" = true;
            };
            "github.copilot.nextEditSuggestions.enabled"= true;
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
            exec = "code --new-window /home/nix";
            icon = "vscode";
            name = "Open Nix Configuration";
          };
        };
      };
    };
  };
}
