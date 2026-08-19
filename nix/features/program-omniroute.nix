{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-omniroute;
  omniroute = pkgs.callPackage ./omniroute/package.nix {};
in {
  options.cursor.features.program-omniroute.enable =
    lib.mkEnableOption "OmniRoute local OpenAI-compatible AI gateway";

  config = lib.mkIf cfg.enable {
    packages = [omniroute];
  };
}
