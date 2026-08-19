let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-context7.nix {};
  on = h.feature ./program-context7.nix {cursor.features.program-context7.enable = true;};
  has = name: names: builtins.elem name names;
in
  assay.suite "program-context7" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "context7-mcp" on.packages) true;
  }
