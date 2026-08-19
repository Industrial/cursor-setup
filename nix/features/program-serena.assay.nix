let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-serena.nix {};
  on = h.feature ./program-serena.nix {cursor.features.program-serena.enable = true;};
  has = name: names: builtins.elem name names;
in
  assay.suite "program-serena" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "serena-agent" on.packages) true;
  }
