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
  has = name: names: builtins.elem name names;
  proc = onProc.config.processes.paperclip or {};
in
  assay.suite "program-paperclip" {
    disabledPackages = assay.eq off.packages [];
    noProcessWhenPackageOnly = assay.eq (onPkgOnly.config.processes or {}) {};
    package = assay.eq (has "paperclipai" on.packages) true;
    processExec = assay.eq (proc.exec or "") "paperclipai run --instance default --no-repair";
    processNotAutoStart = assay.eq (proc.start.enable or true) false;
    processReadyPort = assay.eq (proc.ready.http.get.port or 0) 3100;
    processEnvInstance = assay.eq onProc.config.env.PAPERCLIP_INSTANCE_ID "default";
    processEnvManaged = assay.eq onProc.config.env.PAPERCLIP_SERVICE_MANAGED "1";
  }
