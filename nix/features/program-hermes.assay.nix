let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-hermes.nix {};
  on = h.feature ./program-hermes.nix {cursor.features.program-hermes.enable = true;};
  has = name: names: builtins.elem name names;
  tpl = ./hermes-agent/templates/config.yaml;
in
  assay.suite "program-hermes" {
    disabledPackages = assay.eq off.packages [];
    disabledScripts = assay.eq off.scripts [];
    disabledEnv = assay.eq off.env {};
    package = assay.eq (has "hermes-agent" on.packages) true;
    sandboxScript = assay.eq (has "hermes-sandbox" on.scripts) true;
    sandboxExec = assay.eq (builtins.match ".*hermes.*" on.scriptExec.hermes-sandbox != null) true;
    terminalEnv = assay.eq on.env.TERMINAL_ENV "local";
    mountCwd = assay.eq on.env.TERMINAL_DOCKER_MOUNT_CWD_TO_WORKSPACE "true";
    hostUser = assay.eq on.env.TERMINAL_DOCKER_RUN_AS_HOST_USER "true";
    ephemeral = assay.eq on.env.TERMINAL_CONTAINER_PERSISTENT "false";
    templateExists = assay.eq (builtins.pathExists tpl) true;
  }
