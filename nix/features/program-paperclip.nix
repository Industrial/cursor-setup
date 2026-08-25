# Paperclip AI control plane — https://paperclipai.net/
# Docs: https://docs.paperclip.ing/guides/getting-started/installation/
#
# CLI on PATH when enable=true. processEnable registers a devenv process
# (autoStart=false by default).
#
# Starting it: `devenv up` brings the process manager up but leaves this one
# `not_started` because start.enable is false — naming it (`devenv up paperclip`)
# does NOT override that. Use `devenv processes start paperclip`.
#
# Conflicts with a host systemd --user paperclipai.service on the same ports
# (~/.paperclip, :3100, embedded Postgres :54329) — stop the host unit first.
#
# Ported from ~/.dotfiles/features/ai/paperclip (NixOS systemd --user → devenv process).
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-paperclip;
  paperclipai = pkgs.callPackage ./paperclip/package.nix {};
in {
  options.cursor.features.program-paperclip.enable =
    lib.mkEnableOption "Paperclip AI control plane CLI (paperclipai via npx pin)";

  options.cursor.features.program-paperclip.processEnable =
    lib.mkEnableOption "devenv process for paperclip (paperclipai run)"
    // {
      default = false;
    };

  options.cursor.features.program-paperclip.autoStart =
    lib.mkEnableOption "start paperclip on bare `devenv up` (start.enable)"
    // {
      default = false;
    };

  options.cursor.features.program-paperclip.port = lib.mkOption {
    type = lib.types.port;
    default = 3100;
    description = "HTTP port for Paperclip ready probe (server.port in instance config).";
  };

  options.cursor.features.program-paperclip.instanceId = lib.mkOption {
    type = lib.types.str;
    default = "default";
    description = "PAPERCLIP_INSTANCE_ID / --instance value.";
  };

  options.cursor.features.program-paperclip.databaseUrl = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      DATABASE_URL for the Paperclip process. Empty (the default) forces
      embedded Postgres by shadowing any consumer-repo DATABASE_URL.

      paperclipai bundles dotenv and loads `.env` from its working directory,
      which for a devenv process is the consumer repo root. A repo that sets
      DATABASE_URL for its own app therefore flips Paperclip out of
      embedded-postgres mode without asking, and the server dies with
      `database "<their db>" does not exist` — after `doctor` has already
      reported every check green. dotenv will not overwrite a key that is
      already present, so exporting an empty value wins over the file.

      Set this to a real Postgres URL when the host cannot run the embedded
      cluster (NixOS without `programs.nix-ld`).
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      packages = [paperclipai pkgs.bashInteractive pkgs.coreutils];
    })
    (lib.mkIf (cfg.enable && cfg.processEnable) {
      env = {
        PAPERCLIP_INSTANCE_ID = cfg.instanceId;
        PAPERCLIP_SERVICE_MANAGED = "1";
      };

      processes.paperclip = {
        # DATABASE_URL is shadowed, not unset: `env -u` does not help because
        # dotenv reads the consumer repo's `.env` file at runtime. See the
        # databaseUrl option for the full story.
        exec = "env DATABASE_URL=${lib.escapeShellArg cfg.databaseUrl} paperclipai run --instance ${cfg.instanceId} --no-repair";
        start.enable = cfg.autoStart;
        restart = {
          on = "on_failure";
        };
        ready = {
          http.get = {
            port = cfg.port;
            path = "/";
          };
          initial_delay = 3;
          period = 5;
          failure_threshold = 12;
        };
      };
    })
  ];
}
