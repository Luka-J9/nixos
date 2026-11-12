{ pkgs, ... }:

let
  version = "0.2.6";

  src = pkgs.fetchurl {
    url = "https://github.com/Niko1221/Strata/releases/download/v${version}/Strata-${version}-linux-x86_64.AppImage";
    hash = "sha256-a1Er+rMmFiawpNFJP6QU8FytED9RQP6BfGMJSkpQKFg=";
  };

  # Same arguments wrapType2 passes internally, so this is the one extraction,
  # reused for the desktop entry and icon rather than built a second time.
  contents = pkgs.appimageTools.extract {
    pname = "strata";
    inherit version src;
  };

  # Strata has no Linux package beyond the AppImage: it is a Tauri app that
  # bundles its own GTK/WebKit, and the installer deliberately carries no
  # engine. On first start it downloads the engine for the detected GPU
  # (linux-x86_64-hip-halo, ~170 MB, into ~/.local/share/strata/components)
  # and then a model pack (tens of GB, into a folder you pick). Both live
  # outside the store, managed by the app rather than by Nix.
  #
  # Building the engine from source instead would mean carrying AMD's TheRock
  # ROCm 7.14.1 for gfx1151, which nixpkgs does not have; the packaged engine
  # also brings the gfx1151 hipBLASLt tuning table the prompt path wants.
  strata = pkgs.appimageTools.wrapType2 {
    pname = "strata";
    inherit version src;

    # The session exports GIO modules built against a newer glib than the one
    # inside the AppImage, and every launch logs an "undefined symbol" failure
    # for each. Nothing in the app needs them.
    profile = "unset GIO_EXTRA_MODULES";

    extraInstallCommands = ''
      install -Dm444 ${contents}/Strata.desktop $out/share/applications/strata.desktop
      substituteInPlace $out/share/applications/strata.desktop \
        --replace-fail "Exec=strata-desktop" "Exec=strata" \
        --replace-fail "Icon=strata-desktop" "Icon=strata"
      install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/strata-desktop.png \
        $out/share/icons/hicolor/512x512/apps/strata.png
    '';

    meta = {
      description = "Local inference app for large MoE models (HIP backend on gfx1151)";
      homepage = "https://github.com/Niko1221/Strata";
      mainProgram = "strata";
    };
  };

  # `claude-strata` runs Claude Code against the local Strata server instead of
  # the Anthropic API. Deliberately a wrapper and not ~/.claude/settings.json:
  # `strata connect claude-code` merges this env into the global settings, which
  # would redirect every Claude Code session on this machine.
  #
  # Nothing here is pinned, because the app pins none of it: each instance gets
  # a dynamic port, its own 64-char api_key, and whichever pack you loaded. The
  # app writes a ready-file per instance, which is the authoritative source for
  # the address and the model; the key lives in the instance config the worker
  # was started with, found via the worker pid's own command line.
  #
  # The env block mirrors Strata's own claude-code adapter
  # (strata_cli/launch/harness.py): without the context/output caps Claude Code
  # assumes a 100K window and either never compacts or compacts every turn, and
  # at <=40K its 20-tool prompt (15.6K tokens) crowds out the conversation, so
  # upstream drops it to 3 tools there.
  claude-strata = pkgs.writeShellApplication {
    name = "claude-strata";
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
    text = ''
      runtime="''${XDG_STATE_HOME:-$HOME/.local/state}/strata/runtime"
      base=''${STRATA_URL:-}
      key=''${STRATA_API_KEY:-}
      model=""

      # The app's own instance: newest ready-file that says it is serving.
      if [ -z "$base" ] && [ -d "$runtime" ]; then
        ready=$(find "$runtime" -maxdepth 1 -name '*.ready.json' -printf '%T@ %p\n' 2>/dev/null \
          | sort -rn | head -1 | cut -d' ' -f2-)
        if [ -n "''${ready:-}" ] && [ "$(jq -r '.api_state // ""' "$ready")" = "ready" ]; then
          base=$(jq -r '.api_url // ""' "$ready")
          model=$(jq -r '.model_id // ""' "$ready")
          pid=$(jq -r '.pid // 0' "$ready")
          # The worker's --config holds the key this instance demands. Reading it
          # from the live process avoids picking a stale instance's config.
          if [ -z "$key" ] && [ "$pid" -gt 0 ] && [ -r "/proc/$pid/cmdline" ]; then
            conf=$(tr '\0' '\n' < "/proc/$pid/cmdline" | grep -A1 -x -- --config | tail -1)
            if [ -n "''${conf:-}" ] && [ -r "$conf" ]; then
              key=$(jq -r '.api_key // ""' "$conf")
            fi
          fi
        fi
      fi

      # A server started by hand (strata launch) listens on a fixed port.
      if [ -z "$base" ]; then
        for port in 8095 8080; do
          if curl -fsS --max-time 2 "http://127.0.0.1:$port/v1/status" > /dev/null 2>&1; then
            base="http://127.0.0.1:$port"
            break
          fi
        done
      fi

      if [ -z "$base" ]; then
        echo "claude-strata: found no Strata server." >&2
        echo "Load a model in the Strata app, or set STRATA_URL (and STRATA_API_KEY)." >&2
        exit 1
      fi

      auth=()
      if [ -n "$key" ]; then
        auth=(-H "Authorization: Bearer $key")
      fi
      status=$(curl -fsS --max-time 10 "''${auth[@]}" "$base/v1/status") || {
        echo "claude-strata: $base/v1/status failed (401 means the key was not found)." >&2
        exit 1
      }

      # A bare OpenAI-compatible listener is not Strata -- Ollama on :11434 is a
      # different thing, and the server identifies itself for exactly this.
      if [ "$(jq -r '.service // ""' <<< "$status")" != "strata" ]; then
        echo "claude-strata: $base answered but is not a Strata worker." >&2
        exit 1
      fi
      if ! jq -e '.dialects // [] | index("/v1/messages")' <<< "$status" > /dev/null; then
        echo "claude-strata: $base does not serve /v1/messages." >&2
        exit 1
      fi

      model=$(jq -r --arg m "$model" '.model // $m' <<< "$status")
      context=$(jq -r '.context.native // 0' <<< "$status")
      if [ -z "$model" ] || [ "$context" -eq 0 ]; then
        echo "claude-strata: $base has no model loaded yet." >&2
        exit 1
      fi
      if [ "$(jq -r '.loaded // false' <<< "$status")" != "true" ]; then
        echo "claude-strata: $model is still loading -- a first load takes minutes." >&2
      fi

      echo "claude-strata: $model via $base (context $context)" >&2

      # ANTHROPIC_BASE_URL takes the address *without* /v1: Claude Code appends
      # /v1/messages itself. The token is only checked by your own server; no
      # Anthropic credential is involved, and "[claude-code:unrecognized_model]"
      # on stderr is expected.
      export ANTHROPIC_BASE_URL="$base"
      export ANTHROPIC_AUTH_TOKEN="''${key:-strata-local}"
      export ANTHROPIC_MODEL="$model"
      export ANTHROPIC_SMALL_FAST_MODEL="$model"
      export ANTHROPIC_DEFAULT_SONNET_MODEL="$model"
      export ANTHROPIC_DEFAULT_OPUS_MODEL="$model"
      export ANTHROPIC_DEFAULT_HAIKU_MODEL="$model"
      export CLAUDE_CODE_MAX_CONTEXT_TOKENS="$context"
      export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
      export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
      export DISABLE_AUTOUPDATER=1
      export DISABLE_TELEMETRY=1
      if [ "$context" -le 40960 ]; then
        export CLAUDE_CODE_SIMPLE=1
      fi

      exec claude "$@"
    '';
  };
in
{
  config = {
    home.packages = [
      strata
      claude-strata
    ];
  };
}
