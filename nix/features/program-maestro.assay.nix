let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-maestro.nix {};
  on = h.feature ./program-maestro.nix {cursor.features.program-maestro.enable = true;};
  has = name: names: builtins.elem name names;
in
  assay.suite "program-maestro" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "maestro" on.packages) true;
  }
