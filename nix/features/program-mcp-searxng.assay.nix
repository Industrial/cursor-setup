# mcp-searxng uses bunx at runtime; no nix package to test.
# This file exists for feature parity with other program-*.assay.nix files.
let
  assay = import ../lib/assay.nix;
in
  assay.suite "program-mcp-searxng" {
    # No nix package to test; mcp-searxng runs via bunx
    placeholder = assay.eq true true;
  }
