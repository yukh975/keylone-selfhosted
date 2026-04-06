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

  cd "$SCRIPT_DIR"

  echo "▶ Pulling latest image …"
  docker compose pull keylone

  echo ""
  echo "▶ Restarting …"
  docker compose up -d --remove-orphans --force-recreate keylone

  echo ""
  echo "✓ Done. PostgreSQL data is preserved in volume keylone-postgres-data."
  echo ""
  docker compose ps
  echo ""
  echo "  Logs: docker compose logs -f"
}

main "$@"
