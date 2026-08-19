{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-maestro;
  maestro = pkgs.callPackage ./maestro/package.nix {};
in {
  options.cursor.features.program-maestro.enable =
    lib.mkEnableOption "Maestro local-first agent harness CLI (spec-to-ship loop)";

  config = lib.mkIf cfg.enable {
    packages = [maestro];
  };
}
