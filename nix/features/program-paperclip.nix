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
# Portability: with `dataDir` and `postgres.enable` set, nothing outside the
# checkout is touched — no ~/.paperclip, no host systemd unit, no unpatched
# embedded-postgres binary (which cannot exec on NixOS without programs.nix-ld).
# Left at their defaults the feature uses ~/.paperclip and the vendored cluster,
# and then it does collide with a host paperclipai.service on :3100 / :54329.
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

  # `run` refuses to bootstrap a fresh instance without a TTY ("No config found
  # and terminal is non-interactive"), which is exactly the state a clone starts
  # in. Onboard once, non-interactively, then hand over to `run`.
  paperclipHome = "\${PAPERCLIP_HOME:-$HOME/.paperclip}";
  bootstrapAndRun =
    "[ -f ${paperclipHome}/instances/${cfg.instanceId}/config.json ] "
    + "|| paperclipai onboard -y --no-install-service; "
    + "exec paperclipai run --instance ${cfg.instanceId} --no-repair";
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
    description = ''
      HTTP port for Paperclip. Exported as PORT on the process, which the
      server prefers over `server.port` in the instance config, and used for
      the readiness probe — so both always agree.
    '';
  };

  options.cursor.features.program-paperclip.instanceId = lib.mkOption {
    type = lib.types.str;
    default = "default";
    description = "PAPERCLIP_INSTANCE_ID / --instance value.";
  };

  options.cursor.features.program-paperclip.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "";
    description = ''
      PAPERCLIP_HOME — the instance state root. Empty (the default) means
      `~/.paperclip`, which is shared with any host paperclipai.service.

      Point it inside the checkout (e.g. `"''${DEVENV_STATE}/paperclip"`) to get
      a self-contained instance: no shared state, no port fight with a host
      unit, and `git clean` is enough to reset it. The value is expanded by the
      process shell, so devenv variables are allowed.
    '';
  };

  options.cursor.features.program-paperclip.postgres = {
    enable =
      lib.mkEnableOption "a devenv-managed Postgres for Paperclip"
      // {
        description = ''
          Provision Postgres through devenv instead of Paperclip's vendored
          embedded-postgres, and point `databaseUrl` at it.

          The vendored cluster ships unpatched generic-linux binaries; on NixOS
          they cannot exec at all without `programs.nix-ld`, which is host
          configuration a checkout cannot provide. nixpkgs' postgresql is
          already patched, so this is the portable option.
        '';
      };

    port = lib.mkOption {
      type = lib.types.port;
      default = 54329;
      description = "Port for the devenv-managed Paperclip Postgres.";
    };

    database = lib.mkOption {
      type = lib.types.str;
      default = "paperclip";
      description = "Database created for Paperclip.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "paperclip";
      description = "Login role created for Paperclip (trust auth on loopback).";
    };
  };

  options.cursor.features.program-paperclip.databaseUrl = lib.mkOption {
    type = lib.types.str;
    default =
      if cfg.postgres.enable
      then "postgres://${cfg.postgres.user}@127.0.0.1:${toString cfg.postgres.port}/${cfg.postgres.database}"
      else "";
    defaultText = lib.literalMD "the devenv Postgres URL when `postgres.enable`, otherwise `\"\"`";
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
      # Shell-wide, not process-only: an interactive `paperclipai whoami` must
      # reach the same instance the process serves, or it silently talks to
      # ~/.paperclip instead. Safe to export — the name is namespaced.
      env = lib.optionalAttrs (cfg.dataDir != "") {
        PAPERCLIP_HOME = cfg.dataDir;
      };
    })
    (lib.mkIf (cfg.enable && cfg.postgres.enable) {
      services.postgres = {
        enable = true;
        port = cfg.postgres.port;
        listen_addresses = "127.0.0.1";
        initialDatabases = [{name = cfg.postgres.database;}];
        # Owned by the role Paperclip connects as, so migrations can create
        # extensions and schemas without a second grant step.
        initialScript = ''
          CREATE ROLE "${cfg.postgres.user}" WITH LOGIN SUPERUSER;
          ALTER DATABASE "${cfg.postgres.database}" OWNER TO "${cfg.postgres.user}";
        '';
      };
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
        # PORT is set here rather than in `env` because it is far too generic a
        # name to export shell-wide. Paperclip prefers it over the instance
        # config's server.port, so this keeps the listener and the ready probe
        # on one option — a `-y` onboard would otherwise pick its own default
        # (3001) and the probe would poll a port nothing serves.
        exec = "env DATABASE_URL=${lib.escapeShellArg cfg.databaseUrl} PORT=${toString cfg.port} sh -c ${lib.escapeShellArg bootstrapAndRun}";
        # Postgres is a separate devenv process; Paperclip exits if it is not up
        # yet, so let the restart policy walk it in rather than hard-ordering.
        process-compose.depends_on = lib.mkIf cfg.postgres.enable {
          postgres.condition = "process_healthy";
        };
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
