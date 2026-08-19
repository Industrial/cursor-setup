{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-roam-code-pypi;
  roam = pkgs.callPackage ./roam-code/package.nix {};
in {
  options.cursor.features.program-roam-code-pypi.enable =
    lib.mkEnableOption "roam-code MCP CLI from PyPI (Hermes-aligned, v13+)";

  config = lib.mkIf cfg.enable {
    packages = [roam];
  };
}
