#!/bin/bash

echo "======================================"
echo "Get Staging Schema"
echo "======================================"
echo ""

MIGRATION_FILE="supabase/migrations/20250721093053_remote_commit.sql"

echo "📄 Found empty migration file: $MIGRATION_FILE"
echo ""
echo "Let's fill it with your actual schema!"
echo ""
echo "Opening Supabase SQL Editor..."
echo "Please follow these steps:"
echo ""
echo "1. The SQL Editor will open in your browser"
echo "2. Copy the export query from: scripts/export-schema-query.sql"
echo "3. Run each section of the query"
echo "4. Copy all the results"
echo "5. Come back here and paste them"
echo ""

# Open the SQL editor
open "https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"

# Also open the query file
echo "Opening the export query file..."
if command -v code &> /dev/null; then
    code scripts/export-schema-query.sql
elif command -v open &> /dev/null; then
    open scripts/export-schema-query.sql
else
    echo "Query saved in: scripts/export-schema-query.sql"
fi

echo ""
echo "Press Enter when you're ready to paste the schema..."
read

# Create a temporary file for the schema
TEMP_FILE=$(mktemp)

echo ""
echo "Paste your schema here (press Ctrl+D when done):"
echo "================================================"

# Read the pasted schema
cat > "$TEMP_FILE"

# Check if anything was pasted
if [ ! -s "$TEMP_FILE" ]; then
    echo ""
    echo "❌ No schema was pasted!"
    rm -f "$TEMP_FILE"
    exit 1
fi

# Add header to migration file
cat > "$MIGRATION_FILE" << EOF
-- Migration: Initial schema from staging
-- Generated: $(date)
-- Project: dijtowiohxvwdnvgprud

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

EOF

# Append the pasted schema
cat "$TEMP_FILE" >> "$MIGRATION_FILE"

# Clean up
rm -f "$TEMP_FILE"

echo ""
echo "✅ Migration file updated!"
echo ""
echo "📊 Migration file size: $(wc -c < "$MIGRATION_FILE") bytes"
echo "📊 Line count: $(wc -l < "$MIGRATION_FILE") lines"
echo ""
echo "Next steps:"
echo "1. Review the migration file: $MIGRATION_FILE"
echo "2. Commit it:"
echo "   git add supabase/migrations/"
echo "   git commit -m 'Add database schema migration'"
echo "3. Push to deploy:"
echo "   git push origin main"