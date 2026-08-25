let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-paperclip.nix {};
  on = h.feature ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
  };
  onPkgOnly = h.evalModule ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
  };
  onProc = h.evalModule ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
    cursor.features.program-paperclip.processEnable = true;
  };
  onProcExternalDb = h.evalModule ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
    cursor.features.program-paperclip.processEnable = true;
    cursor.features.program-paperclip.databaseUrl = "postgres://u@h:5432/pc";
  };
  has = name: names: builtins.elem name names;
  proc = onProc.config.processes.paperclip or {};
in
  assay.suite "program-paperclip" {
    disabledPackages = assay.eq off.packages [];
    noProcessWhenPackageOnly = assay.eq (onPkgOnly.config.processes or {}) {};
    package = assay.eq (has "paperclipai" on.packages) true;
    # Shadowed with an empty value, not `env -u`: dotenv reads the consumer
    # repo's .env at runtime, and only an already-present key wins over it.
    processExec = assay.eq (proc.exec or "") "env DATABASE_URL='' paperclipai run --instance default --no-repair";
    # escapeShellArg leaves shell-safe values unquoted; the empty default is
    # the case that actually needs the quotes.
    processExternalDatabaseUrl = assay.eq ((onProcExternalDb.config.processes.paperclip or {}).exec or "") "env DATABASE_URL=postgres://u@h:5432/pc paperclipai run --instance default --no-repair";
    processNotAutoStart = assay.eq (proc.start.enable or true) false;
    processReadyPort = assay.eq (proc.ready.http.get.port or 0) 3100;
    processEnvInstance = assay.eq onProc.config.env.PAPERCLIP_INSTANCE_ID "default";
    processEnvManaged = assay.eq onProc.config.env.PAPERCLIP_SERVICE_MANAGED "1";
  }
