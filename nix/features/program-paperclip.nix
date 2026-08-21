# Paperclip AI control plane — https://paperclipai.net/
# Docs: https://docs.paperclip.ing/guides/getting-started/installation/
#
# CLI on PATH when enable=true. processEnable wires a devenv process for
# `devenv up paperclip` (autoStart=false by default).
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
        exec = "paperclipai run --instance ${cfg.instanceId} --no-repair";
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
