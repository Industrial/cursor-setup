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
  onPortable = h.evalModule ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
    cursor.features.program-paperclip.processEnable = true;
    cursor.features.program-paperclip.dataDir = "/tmp/pc-state";
    cursor.features.program-paperclip.postgres.enable = true;
  };
  onCliOnlyPortable = h.evalModule ./program-paperclip.nix {
    cursor.features.program-paperclip.enable = true;
    cursor.features.program-paperclip.dataDir = "/tmp/pc-state";
  };
  has = name: names: builtins.elem name names;
  proc = onProc.config.processes.paperclip or {};
  portablePg = onPortable.config.services.postgres or {};
in
  assay.suite "program-paperclip" {
    disabledPackages = assay.eq off.packages [];
    noProcessWhenPackageOnly = assay.eq (onPkgOnly.config.processes or {}) {};
    package = assay.eq (has "paperclipai" on.packages) true;
    # Shadowed with an empty value, not `env -u`: dotenv reads the consumer
    # repo's .env at runtime, and only an already-present key wins over it.
    processExec = assay.eq (builtins.match "env DATABASE_URL='' PORT=3100 sh -c .*" (proc.exec or "") != null) true;
    # A clone has no instance config, and `run` will not bootstrap one without a
    # TTY — so onboard non-interactively first, exactly once.
    processBootstrapsInstance = assay.eq (builtins.match ".*paperclipai onboard -y --no-install-service.*" (proc.exec or "") != null) true;
    processRunsInstance = assay.eq (builtins.match ".*exec paperclipai run --instance default --no-repair.*" (proc.exec or "") != null) true;
    # escapeShellArg leaves shell-safe values unquoted; the empty default is
    # the case that actually needs the quotes.
    processExternalDatabaseUrl = assay.eq (builtins.match "env DATABASE_URL=postgres://u@h:5432/pc PORT=3100 sh -c .*" ((onProcExternalDb.config.processes.paperclip or {}).exec or "") != null) true;
    processNotAutoStart = assay.eq (proc.start.enable or true) false;
    processReadyPort = assay.eq (proc.ready.http.get.port or 0) 3100;
    # Portable mode: state in the checkout, devenv Postgres instead of the
    # vendored embedded cluster, and databaseUrl derived from it.
    noPostgresByDefault = assay.eq (onProc.config.services.postgres.enable or false) false;
    noDataDirByDefault = assay.eq (onProc.config.env ? PAPERCLIP_HOME) false;
    portableDataDir = assay.eq onPortable.config.env.PAPERCLIP_HOME "/tmp/pc-state";
    # Shell-wide so an interactive CLI call reaches the same instance the
    # process serves, even with no process registered at all.
    portableDataDirWithoutProcess = assay.eq onCliOnlyPortable.config.env.PAPERCLIP_HOME "/tmp/pc-state";
    portablePostgresEnabled = assay.eq (portablePg.enable or false) true;
    portablePostgresPort = assay.eq (portablePg.port or 0) 54329;
    portablePostgresLoopback = assay.eq (portablePg.listen_addresses or "") "127.0.0.1";
    portablePostgresDatabase = assay.eq (map (d: d.name) (portablePg.initialDatabases or [])) ["paperclip"];
    portableDatabaseUrl = assay.eq (builtins.match "env DATABASE_URL=postgres://paperclip@127.0.0.1:54329/paperclip PORT=3100 sh -c .*" ((onPortable.config.processes.paperclip or {}).exec or "") != null) true;
    # The listener and the readiness probe must come from one option, or a `-y`
    # onboard picks its own port (3001) and the probe polls nothing.
    processPortMatchesProbe = assay.eq (builtins.match ".*PORT=${toString (proc.ready.http.get.port or 0)} .*" (proc.exec or "") != null) true;
    processEnvInstance = assay.eq onProc.config.env.PAPERCLIP_INSTANCE_ID "default";
    processEnvManaged = assay.eq onProc.config.env.PAPERCLIP_SERVICE_MANAGED "1";
  }
