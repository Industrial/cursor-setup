{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-context7;
  context7 = pkgs.callPackage ./context7/package.nix {};
in {
  options.cursor.features.program-context7.enable =
    lib.mkEnableOption "context7-mcp documentation MCP server";

  config = lib.mkIf cfg.enable {
    packages = [context7];
  };
}
