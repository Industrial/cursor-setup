let
  assay = import ../lib/assay.nix;
  h = import ../lib/feature-eval.nix {};
  off = h.feature ./program-lean-ctx.nix {};
  on = h.feature ./program-lean-ctx.nix {cursor.features.program-lean-ctx.enable = true;};
in
  assay.suite "program-lean-ctx" {
    disabled = assay.eq off.packages [];
    package = assay.eq (builtins.elem "lean-ctx" on.packages) true;
    env = assay.eq on.env.LEAN_CTX_COMPRESS "1";
  }
