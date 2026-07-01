#!/usr/bin/env bash
# Pre-build every unique base image once, locally.
#
# Each task's environment/Dockerfile builds `FROM kotlin-bench/<repo>:<base-tag>` (e.g.
# kotlin-bench/pinterest_ktlint:base or kotlin-bench/pinterest_ktlint:base-JDK-17). A repo may have
# several base variants on different JDKs; each has its own verbatim recipe in
# bases/<repo>/Dockerfile.<base-tag>. These bases are not published to any registry, so they
# must exist in the local Docker daemon before running harbor. This script builds (and tags)
# each unique (repo, base-tag) listed in bases/manifest exactly once; its layers are then
# shared by every task that builds FROM it.
#
# Usage:
#   scripts/build_bases.sh            # build only bases whose tag is missing
#   scripts/build_bases.sh --rebuild  # rebuild all bases (still uses BuildKit cache)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASES_DIR="$REPO_ROOT/bases"
MANIFEST="$BASES_DIR/manifest"

rebuild=0
[[ "${1:-}" == "--rebuild" ]] && rebuild=1

[[ -f "$MANIFEST" ]] || { echo "manifest not found: $MANIFEST" >&2; exit 1; }

built=0 skipped=0
while read -r repo tag dockerfile; do
  [[ -z "${repo:-}" || "$repo" == \#* ]] && continue
  image="kotlin-bench/${repo}:${tag}"
  ctx="$BASES_DIR/$repo"
  if [[ ! -f "$ctx/$dockerfile" ]]; then
    echo "ERROR: missing $ctx/$dockerfile for $image" >&2
    exit 1
  fi
  if [[ "$rebuild" -eq 0 ]] && docker image inspect "$image" >/dev/null 2>&1; then
    echo "==> $image already present, skipping (use --rebuild to force)"
    skipped=$((skipped + 1))
    continue
  fi
  echo "==> building $image"
  docker build -f "$ctx/$dockerfile" -t "$image" "$ctx"
  built=$((built + 1))
done < "$MANIFEST"

echo "done: built $built, skipped $skipped"
