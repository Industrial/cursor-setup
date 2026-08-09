let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./languages-javascript.nix {};
  on = h.feature ./languages-javascript.nix {cursor.features.languages-javascript.enable = true;};
in
  assay.suite "languages-javascript" {
    disabled = assay.eq off.languages.javascript.enable false;
    enabled = assay.eq on.languages.javascript.enable true;
    bunEnabled = assay.eq on.languages.javascript.bunEnable true;
    typescriptEnabled = assay.eq on.languages.typescriptEnable true;
  }
