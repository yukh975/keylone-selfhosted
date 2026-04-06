#!/bin/bash
# ── Keylone update ────────────────────────────────────────────────────────────
# Pulls the latest image and restarts the container.
# Wrapped in main() so bash reads the full script before executing.
# ─────────────────────────────────────────────────────────────────────────────
set -e

main() {
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

  echo "╔══════════════════════════════════════════╗"
  echo "║         Keylone — Update                 ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""

  if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ .env not found. Run setup.sh first."
    exit 1
  fi

  # Detect docker compose command
  if docker compose version >/dev/null 2>&1; then
    DC="docker compose"
  elif command -v docker-compose >/dev/null 2>&1; then
    DC="docker-compose"
  else
    echo "❌ Neither 'docker compose' nor 'docker-compose' found."
    exit 1
  fi

  cd "$SCRIPT_DIR"

  echo "▶ Updating scripts …"
  git pull

  echo ""
  echo "▶ Pulling latest image …"
  docker pull ghcr.io/yukh975/keylone:latest

  echo ""
  echo "▶ Restarting keylone (postgres untouched) …"
  docker stop keylone 2>/dev/null || true
  docker rm keylone   2>/dev/null || true
  $DC up -d --no-deps keylone

  echo ""
  echo "✓ Done. PostgreSQL data is preserved in volume keylone-postgres-data."
  echo ""
  $DC ps
  echo ""
  echo "  Logs: $DC logs -f"
}

main "$@"
