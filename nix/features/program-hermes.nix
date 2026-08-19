{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-hermes;
  cursor-acp = pkgs.callPackage ./hermes-agent/plugins/cursor-acp/package.nix {};
  hermes = pkgs.callPackage ./hermes-agent/package.nix {
    extraPlugins = [cursor-acp];
  };
in {
  options.cursor.features.program-hermes.enable =
    lib.mkEnableOption "Hermes Agent CLI with local terminal (Docker sandbox optional via hermes-sandbox)";

  config = lib.mkIf cfg.enable {
    packages = [hermes];

    # Hermes TERMINAL_* env map (overrides ~/.hermes/config.yaml terminal.backend).
    # Default: local (host shell via devenv). Use `hermes-sandbox` for Docker.
    env = {
      TERMINAL_ENV = "local";
      TERMINAL_DOCKER_IMAGE = "nikolaik/python-nodejs:python3.11-nodejs20";
      TERMINAL_DOCKER_MOUNT_CWD_TO_WORKSPACE = "true";
      TERMINAL_DOCKER_RUN_AS_HOST_USER = "true";
      TERMINAL_CONTAINER_CPU = "2";
      TERMINAL_CONTAINER_MEMORY = "4096";
      TERMINAL_CONTAINER_PERSISTENT = "false";
    };

    scripts.hermes-sandbox = {
      exec = ''
        echo "Hermes terminal backend: docker (HERMES_HOME=''${HERMES_HOME:-})"
        TERMINAL_ENV=docker exec hermes "$@"
      '';
    };
  };
}
