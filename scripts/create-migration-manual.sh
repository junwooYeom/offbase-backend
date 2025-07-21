#!/bin/bash

echo "======================================"
echo "Manual Migration File Creator"
echo "======================================"
echo ""
echo "This creates a migration file without Docker"
echo ""

# Create migrations directory
mkdir -p supabase/migrations

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)
FILENAME="supabase/migrations/${TIMESTAMP}_initial_schema.sql"

# Create the migration file with a template
cat > "$FILENAME" << 'EOF'
-- Initial schema migration from staging
-- Created: $(date)
-- 
-- INSTRUCTIONS:
-- 1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor
-- 2. Run the export query below
-- 3. Replace this content with the exported schema
--
-- EXPORT QUERY TO RUN IN SUPABASE SQL EDITOR:
/*
SELECT 
  'CREATE TABLE IF NOT EXISTS ' || schemaname || '.' || tablename || E' (\n' ||
  string_agg(
    '  ' || column_name || ' ' || 
    CASE 
      WHEN data_type = 'character varying' THEN 'VARCHAR(' || character_maximum_length || ')'
      WHEN data_type = 'character' THEN 'CHAR(' || character_maximum_length || ')'
      WHEN data_type = 'numeric' THEN 'NUMERIC(' || numeric_precision || ',' || numeric_scale || ')'
      WHEN data_type = 'timestamp without time zone' THEN 'TIMESTAMP'
      WHEN data_type = 'timestamp with time zone' THEN 'TIMESTAMPTZ'
      WHEN data_type = 'USER-DEFINED' THEN udt_name
      ELSE UPPER(data_type)
    END ||
    CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
    CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END,
    E',\n' ORDER BY ordinal_position
  ) || E'\n);'
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY schemaname, tablename
ORDER BY tablename;
*/

-- PASTE YOUR EXPORTED SCHEMA BELOW THIS LINE:
-- ==========================================

EOF

echo "✅ Created migration file: $FILENAME"
echo ""
echo "Next steps:"
echo "1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
echo "2. Copy the query from the migration file"
echo "3. Run it in SQL Editor"
echo "4. Copy the results"
echo "5. Replace the content in: $FILENAME"
echo "6. Commit and push:"
echo "   git add supabase/migrations/"
echo "   git commit -m 'Add initial database migration'"
echo "   git push origin main"
echo ""
echo "Opening the Supabase SQL Editor..."
open "https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"