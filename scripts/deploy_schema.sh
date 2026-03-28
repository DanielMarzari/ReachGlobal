#!/bin/bash
# ============================================================
# ReachGlobal — Deploy Supabase Schema via Management API
# ============================================================
# Usage:
#   bash scripts/deploy_schema.sh [migration_file]
#
# Requires: SUPABASE_PAT and SUPABASE_PROJECT_ID env vars.
# Source them with:
#   source /sessions/nice-busy-cerf/.supabase.env
#
# Runs all migrations in order if no file is specified,
# or a single migration file if provided.
# ============================================================

set -e

PROJECT_ID="${SUPABASE_PROJECT_ID:-sqhpxtfnnupcdgjjhsgc}"
PAT="${SUPABASE_PAT:-}"
API="https://api.supabase.com/v1/projects/${PROJECT_ID}/database/query"
MIGRATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../supabase/migrations" && pwd)"

if [ -z "$PAT" ]; then
  echo "ERROR: SUPABASE_PAT is not set."
  echo "Run: source /sessions/nice-busy-cerf/.supabase.env"
  exit 1
fi

run_migration() {
  local file="$1"
  echo ">>> Running $(basename "$file")..."
  local HTTP
  HTTP=$(curl -s -o /tmp/mig_resp.json -w "%{http_code}" \
    -X POST "$API" \
    -H "Authorization: Bearer $PAT" \
    -H "Content-Type: application/json" \
    -d "$(python3 -c "import json; print(json.dumps({'query': open('$file').read()}))")")

  if [ "$HTTP" = "200" ] || [ "$HTTP" = "201" ]; then
    echo "    OK (HTTP $HTTP)"
  else
    echo "    FAILED (HTTP $HTTP):"
    cat /tmp/mig_resp.json
    exit 1
  fi
}

if [ -n "$1" ]; then
  run_migration "$1"
else
  for f in "$MIGRATION_DIR"/00*.sql; do
    run_migration "$f"
  done
fi

echo ""
echo "All migrations complete."
