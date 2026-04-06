#!/bin/bash
# ── Keylone database backup ───────────────────────────────────────────────────
# Creates a gzip-compressed SQL dump of the Keylone database.
#
# Usage:
#   ./backup.sh                    — saves to ./backups/
#   BACKUP_DIR=/mnt/nas ./backup.sh — saves to custom path
#
# Restore:
#   gunzip -c backups/keylone_20260406_120000.sql.gz \
#     | docker exec -i keylone-postgres psql -U keylone keylone
# ─────────────────────────────────────────────────────────────────────────────
set -e

BACKUP_DIR="${BACKUP_DIR:-$(dirname "$0")/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/keylone_${TIMESTAMP}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "▶ Backing up Keylone database …"
docker exec keylone-postgres pg_dump -U keylone keylone | gzip > "$BACKUP_FILE"

echo "✓ Saved: $BACKUP_FILE"
echo "  Size:  $(du -h "$BACKUP_FILE" | cut -f1)"
echo ""
echo "  Restore command:"
echo "  gunzip -c $BACKUP_FILE | docker exec -i keylone-postgres psql -U keylone keylone"
