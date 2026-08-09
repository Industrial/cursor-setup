# Re-export Industrial/assay claim DSL (pinned). Suites: `let assay = import ../lib/assay.nix;`
let
  src = builtins.fetchTarball {
    url = "https://github.com/Industrial/assay/archive/refs/tags/v0.1.0.tar.gz";
    sha256 = "0zid7xj89gri3k37fkm4qg9736iggckwbx5a6lb4g259apy2gyjn";
  };
in
  import (src + "/nix/assay/default.nix")
