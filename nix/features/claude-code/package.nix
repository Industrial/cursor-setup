# Claude Code CLI — Anthropic terminal agent
# https://github.com/anthropics/claude-code
#
# Pinned native release from Anthropic's CDN (same source as nixpkgs claude-code).
# Version policy: bump manifest.json checksums together.
{
  lib,
  stdenvNoCC,
  fetchurl,
  installShellFiles,
  makeBinaryWrapper,
  autoPatchelfHook,
  alsa-lib,
  procps,
  ripgrep,
  bubblewrap,
  socat,
  manifest ? lib.importJSON ./manifest.json,
}: let
  stdenv = stdenvNoCC;
  baseUrl = "https://downloads.claude.ai/claude-code-releases";
  platformKey = "${stdenv.hostPlatform.node.platform}-${stdenv.hostPlatform.node.arch}";
  platformManifestEntry = manifest.platforms.${platformKey};
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "claude-code";
    inherit (manifest) version;

    src = fetchurl {
      url = "${baseUrl}/${finalAttrs.version}/${platformKey}/claude";
      hash = "sha256:${platformManifestEntry.checksum}";
    };

    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;

    nativeBuildInputs =
      [
        installShellFiles
        makeBinaryWrapper
      ]
      ++ lib.optionals stdenv.hostPlatform.isElf [autoPatchelfHook];

    strictDeps = true;

    installPhase = ''
      runHook preInstall

      installBin $src

      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        ${lib.optionalString stdenv.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [alsa-lib]} \
      ''}--prefix PATH : ${
        lib.makeBinPath (
          [
            procps
            ripgrep
          ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [
            bubblewrap
            socat
          ]
        )
      }

      runHook postInstall
    '';

    meta = {
      description = "Anthropic Claude Code CLI (terminal agent)";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      mainProgram = "claude";
    };
  })
