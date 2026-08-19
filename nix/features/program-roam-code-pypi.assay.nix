let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-roam-code-pypi.nix {};
  on = h.feature ./program-roam-code-pypi.nix {
    cursor.features.program-roam-code-pypi.enable = true;
  };
  has = name: names: builtins.elem name names;
in
  assay.suite "program-roam-code-pypi" {
    disabled = assay.eq off.packages [];
    package = assay.eq (has "roam-code" on.packages) true;
  }
