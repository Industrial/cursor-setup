{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.cursor.features.program-lean-ctx;
  # https://github.com/yvgude/lean-ctx
  # Named lean-ctx-pkg so `with pkgs` does not pick nixpkgs' `lean-ctx`.
  lean-ctx-pkg = pkgs.rustPlatform.buildRustPackage rec {
    pname = "lean-ctx";
    version = "3.1.5";
    src = pkgs.fetchCrate {
      inherit pname version;
      hash = "sha256-WrLKCd6YzN5fxmBlyv9XSvAKXEtMbhuskyeDeLNFG2w=";
    };
    cargoHash = "sha256-n/xrYp8OLkmjbm3hjS9Mzx18VHs8Oh4Op767NM6rmI0=";
    # Upstream tests assume a full dev shell; skip in the Nix build.
    doCheck = false;
  };
in {
  options.cursor.features.program-lean-ctx.enable = lib.mkEnableOption "lean-ctx MCP + CLI";

  config = lib.mkIf cfg.enable {
    packages = [lean-ctx-pkg];
    env.LEAN_CTX_COMPRESS = lib.mkDefault "1";
  };
}
