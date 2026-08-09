let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-roam-code.nix {};
  on = h.feature ./program-roam-code.nix {cursor.features.program-roam-code.enable = true;};
in
  assay.suite "program-roam-code" {
    disabled = assay.eq off.packages [];
    package = assay.eq (builtins.elem "roam-code" on.packages) true;
  }
