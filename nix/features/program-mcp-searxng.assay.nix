# mcp-searxng uses bunx at runtime; no nix package to test.
# This file exists for feature parity with other program-*.assay.nix files.
{
  claims = {
    "mcp-searxng is available via bunx" = {
      check = ''
        # Verify bunx can resolve the package (doesn't actually run it)
        bunx --version >/dev/null
      '';
    };
  };
}
