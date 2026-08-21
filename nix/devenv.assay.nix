# Covers ./devenv.nix import list (same feature surface as default.nix).
let
  assay = import ./lib/assay.nix;
  h = import ./lib/feature-eval.nix {};
  viaDefault = builtins.sort builtins.lessThan (h.optionNames ./default.nix);
  viaDevenv = builtins.sort builtins.lessThan (h.optionNames ./devenv.nix);
in
  assay.suite "devenv" {
    sameFeaturesAsDefault = assay.eq viaDevenv viaDefault;
    featureCount = assay.eq (builtins.length viaDevenv) 23;
  }
