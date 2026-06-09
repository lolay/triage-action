#!/usr/bin/env bash
set -euo pipefail
REPO="lolay/triage"

# 1. Resolve version: input > committed VERSION file (deterministic for floating tags).
version="${INPUT_VERSION:-}"
if [[ -z "$version" && -f "${GITHUB_ACTION_PATH}/VERSION" ]]; then
  version="$(tr -d ' \n' < "${GITHUB_ACTION_PATH}/VERSION")"
fi
[[ -n "$version" ]] || {
  echo "::error::no triage CLI version: set the 'version' input or commit a VERSION file"; exit 1
}

# 2. Map runner OS/arch -> goreleaser asset naming.
case "$RUNNER_OS" in
  Linux) os=linux ;; macOS) os=darwin ;; Windows) os=windows ;;
  *) echo "::error::unsupported OS $RUNNER_OS"; exit 1 ;;
esac
case "$RUNNER_ARCH" in
  X64) arch=amd64 ;; ARM64) arch=arm64 ;;
  *) echo "::error::unsupported arch $RUNNER_ARCH"; exit 1 ;;
esac
ext=tar.gz; [[ "$os" == windows ]] && ext=zip

# 3. tool-cache lookup (warm runners skip the re-download). Assets are public — no token.
tool_dir="${RUNNER_TOOL_CACHE}/triage/${version}/${arch}"
if [[ ! -x "${tool_dir}/triage" && ! -x "${tool_dir}/triage.exe" ]]; then
  asset="triage_${version}_${os}_${arch}.${ext}"
  base="https://github.com/${REPO}/releases/download/v${version}"
  tmp="$(mktemp -d)"
  curl --proto '=https' --tlsv1.2 -fsSL -o "${tmp}/${asset}"        "${base}/${asset}"
  curl --proto '=https' --tlsv1.2 -fsSL -o "${tmp}/checksums.txt"   "${base}/checksums.txt"
  # Verify: sha256sum on Linux, shasum -a 256 on macOS.
  ( cd "$tmp" && grep " ${asset}\$" checksums.txt | \
      if command -v sha256sum >/dev/null; then sha256sum -c -; else shasum -a 256 -c -; fi )
  mkdir -p "$tool_dir"
  if [[ "$ext" == zip ]]; then unzip -q "${tmp}/${asset}" -d "$tool_dir";
  else tar -xzf "${tmp}/${asset}" -C "$tool_dir"; fi
fi

# 4. Put it on PATH and export the resolved version.
echo "$tool_dir" >> "$GITHUB_PATH"
echo "version=$version" >> "$GITHUB_OUTPUT"
