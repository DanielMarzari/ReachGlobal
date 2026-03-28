#!/bin/bash
# ============================================================
# ReachGlobal — Deploy Supabase Schema
# ============================================================
# Usage:
#   bash scripts/deploy_schema.sh <DB_URL>
#
# Where DB_URL is your Supabase direct connection string, e.g.:
#   postgresql://postgres.[project-id]:[password]@aws-0-us-east-1.pooler.supabase.com:5432/postgres
#
# Find it in: Supabase Dashboard → Project Settings → Database → Connection string
#
# Alternatively, run each migration file manually in:
#   Supabase Dashboard → SQL Editor → New query → paste & run
#
# Order matters: run 001, then 002, then 003.
# ============================================================

set -e

DB_URL="${1:-}"

if [ -z "$DB_URL" ]; then
  echo "Usage: bash scripts/deploy_schema.sh <DB_URL>"
  echo ""
  echo "Or run manually in Supabase SQL Editor:"
  echo "  supabase/migrations/001_initial_schema.sql"
  echo "  supabase/migrations/002_rls_policies.sql"
  echo "  supabase/migrations/003_storage_buckets.sql"
  exit 1
fi

MIGRATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../supabase/migrations" && pwd)"

for f in "$MIGRATION_DIR"/00*.sql; do
  echo ">>> Running $(basename $f)..."
  psql "$DB_URL" -f "$f"
  echo ">>> Done: $(basename $f)"
done

echo ""
echo "Schema deployed successfully."
