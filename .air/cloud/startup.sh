#!/usr/bin/env bash
# Air environment startup script for air-env-setup-e2e-sample (primary repository).
# Sets up this repo, runs each additional repository's own startup script, and in
# WARMUP mode blocks on healthcheck before exiting.
set -euo pipefail

if [ "${AIR_STARTUP_MODE:-}" = warmup ]; then WARMUP=1; else WARMUP=; fi
log() { echo "[startup:e2e-sample] $*"; }

# --- Locate the primary checkout (the launch may run a materialized copy of this file) ---
is_repo_root() { [ -f "$1/package.json" ] && grep -q '"name": "air-env-setup-e2e-sample"' "$1/package.json"; }
REPO_DIR=""
for cand in "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." 2>/dev/null && pwd || true)" \
            "$(git rev-parse --show-toplevel 2>/dev/null || true)" "$PWD" \
            "/workspaces/air-env-setup-e2e-sample"; do
  if [ -n "$cand" ] && is_repo_root "$cand"; then REPO_DIR="$cand"; break; fi
done
[ -n "$REPO_DIR" ] || { log "ERROR: cannot locate air-env-setup-e2e-sample checkout (PWD=$PWD)"; exit 1; }
PARENT_DIR="$(dirname "$REPO_DIR")"
log "repo dir: $REPO_DIR (mode: ${AIR_STARTUP_MODE:-unset})"

# --- Toolchain: Node >= 18 (zero-dependency app, nothing to npm install) ---
if ! command -v node >/dev/null 2>&1 || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 18 ]; then
  log "installing Node.js 20 via apt (NodeSource)"
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo -E apt-get install -y nodejs
fi
log "node $(node -v), npm $(npm -v)"

# --- Start the app in the background on port 3000 ---
export PORT=3000
APP_LOG=/tmp/air-env-setup-e2e-sample.log
if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
  log "app already answering on :${PORT}"
else
  log "starting app (npm start) on 0.0.0.0:${PORT}, log: $APP_LOG"
  (cd "$REPO_DIR" && nohup npm start >"$APP_LOG" 2>&1 &)
fi

healthcheck() {
  log "healthcheck: waiting for GET http://127.0.0.1:${PORT}/health"
  local n=0
  until (cd "$REPO_DIR" && PORT=$PORT npm run --silent healthcheck); do
    n=$((n + 1))
    if [ $((n % 10)) -eq 0 ]; then log "still waiting for app (attempt $n); recent log:"; tail -n 5 "$APP_LOG" || true; fi
    sleep 1
  done
  log "healthcheck passed"
}

# --- Additional repositories: run each one's own startup script ---
ADDITIONAL_REPOS=(air-env-setup-test)
for r in "${ADDITIONAL_REPOS[@]}"; do
  script="$PARENT_DIR/$r/.air/cloud/startup.sh"
  if [ -f "$script" ]; then
    log "running startup script of $r"
    (cd "$PARENT_DIR/$r" && bash "$script") || { log "ERROR: startup script of $r failed"; exit 1; }
  else
    log "WARNING: $r has no .air/cloud/startup.sh at $script; skipping"
  fi
done

if [ -n "$WARMUP" ]; then healthcheck; fi
log "done"
