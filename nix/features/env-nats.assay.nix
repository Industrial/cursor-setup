let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./env-nats.nix {};
  on = h.feature ./env-nats.nix {cursor.features.env-nats.enable = true;};
in
  assay.suite "env-nats" {
    disabledPackages = assay.eq off.packages [];
    enabledPname = assay.eq on.packages ["natscli"];
    doesNotSetEnv = assay.eq on.env {};
  }
