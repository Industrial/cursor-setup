{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-claude-code;
  claude-code = pkgs.callPackage ./claude-code/package.nix {};
in {
  options.cursor.features.program-claude-code.enable =
    lib.mkEnableOption "Anthropic Claude Code CLI (terminal agent)";

  config = lib.mkIf cfg.enable {
    packages = [claude-code];
  };
}
