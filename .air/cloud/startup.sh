#!/usr/bin/env bash
# Air E2E fixture: the multi-repository environment setup scenario checks out this branch's commit on its setup
# branch. The script lives only in this (primary) repository and sets up every other repository cloned beside it
# by leaving a marker file in it.
set -euo pipefail
primary="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
root="$(dirname "$primary")"
while IFS= read -r git_dir; do
  repo="$(dirname "$git_dir")"
  if [ "$repo" = "$primary" ] || [ "$repo" = "$root" ] || ! git -C "$repo" remote get-url origin >/dev/null 2>&1; then
    continue
  fi
  printf '%s\n' 'set-up-by-primary-startup-script' > "$repo/.air-e2e-multi-repo-setup"
  echo "Set up additional repository at $repo"
done < <(find "$root" -maxdepth 4 -name node_modules -prune -o -type d -name .git -print 2>/dev/null)
echo "Primary repository at $primary is ready"
