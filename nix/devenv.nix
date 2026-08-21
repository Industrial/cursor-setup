# Barrel for devenv.yaml `imports: [ ./.cursor/nix ]` (expects devenv.nix in the dir).
# Also imported via Nix as `./.cursor/nix` → default.nix → this file.
{
  imports = [
    ./features/program-moon.nix
    ./features/program-roam-code.nix
    ./features/program-roam-code-pypi.nix
    ./features/program-lean-ctx.nix
    ./features/program-assay.nix
    ./features/program-maestro.nix
    ./features/program-context7.nix
    ./features/program-omniroute.nix
    ./features/program-hermes.nix
    ./features/program-claude-code.nix
    ./features/program-paperclip.nix

    ./features/dotenv.nix
    ./features/packages-base.nix
    ./features/packages-rust-dev.nix
    ./features/packages-formatters.nix
    ./features/env-python-ld.nix
    ./features/env-bindgen.nix
    ./features/env-nats.nix
    ./features/languages-javascript.nix
    ./features/languages-rust.nix
    ./features/languages-python-uv.nix
    ./features/git-hooks-moon.nix
    ./features/git-hooks-prek.nix
  ];
}
