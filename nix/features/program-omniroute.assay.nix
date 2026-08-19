let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-omniroute.nix {};
  on = h.feature ./program-omniroute.nix {cursor.features.program-omniroute.enable = true;};
  has = name: names: builtins.elem name names;
in
  assay.suite "program-omniroute" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "omniroute" on.packages) true;
  }
