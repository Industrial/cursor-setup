let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-claude-code.nix {};
  on = h.feature ./program-claude-code.nix {cursor.features.program-claude-code.enable = true;};
  has = name: names: builtins.elem name names;
in
  assay.suite "program-claude-code" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "claude-code" on.packages) true;
  }
