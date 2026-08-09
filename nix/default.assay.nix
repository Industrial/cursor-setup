# Covers ./default.nix (barrel → devenv.nix → all features).
let
  assay = import ./lib/assay.nix;
  h = import ./lib/feature-eval.nix {};
  names = h.optionNames ./default.nix;
  expected = [
    "dotenv"
    "env-bindgen"
    "env-nats"
    "env-python-ld"
    "git-hooks-moon"
    "git-hooks-prek"
    "languages-javascript"
    "languages-python-uv"
    "languages-rust"
    "packages-base"
    "packages-formatters"
    "packages-rust-dev"
    "program-assay"
    "program-lean-ctx"
    "program-moon"
    "program-roam-code"
  ];
  idle = h.feature ./default.nix {};
in
  assay.suite "default" {
    exposesAllFeatures = assay.eq (builtins.sort builtins.lessThan names) expected;
    featureCount = assay.eq (builtins.length names) 16;
    idlePackagesEmpty = assay.eq idle.packages [];
    idleDotenvOff = assay.eq idle.dotenv.enable false;
    idleScriptsEmpty = assay.eq idle.scripts [];
    idleJsOff = assay.eq idle.languages.javascript.enable false;
    idleRustOff = assay.eq idle.languages.rust.enable false;
    idlePythonOff = assay.eq idle.languages.python.enable false;
    idleEnterShellEmpty = assay.eq idle.enterShell "";
    idleEnvEmpty = assay.eq idle.env {};
    idleGitHooksEmpty = assay.eq idle.git-hooks {};
  }
