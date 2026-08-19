{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-serena;
  serena = pkgs.callPackage ./serena/package.nix {};
in {
  options.cursor.features.program-serena.enable =
    lib.mkEnableOption "serena MCP coding agent CLI";

  config = lib.mkIf cfg.enable {
    packages = [serena];
  };
}
