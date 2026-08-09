let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./env-bindgen.nix {};
  on = h.feature ./env-bindgen.nix {cursor.features.env-bindgen.enable = true;};
in
  assay.suite "env-bindgen" {
    disabledEnv = assay.eq off.env {};
    enabledKeys = assay.hasAttrs on.env ["BINDGEN_EXTRA_CLANG_ARGS" "LIBCLANG_PATH"];
    libclangNonEmpty = assay.eq (builtins.stringLength on.env.LIBCLANG_PATH > 0) true;
    clangArgsNonEmpty = assay.eq (builtins.stringLength on.env.BINDGEN_EXTRA_CLANG_ARGS > 0) true;
  }
