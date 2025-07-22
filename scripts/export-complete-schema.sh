#!/bin/bash

echo "======================================"
echo "Export Complete Schema from Staging"
echo "======================================"
echo ""
echo "This will capture EVERYTHING from your staging database:"
echo "- Tables with all columns and constraints"
echo "- Functions"
echo "- Triggers" 
echo "- Indexes"
echo "- Views"
echo "- RLS Policies"
echo ""

# Check if migration file exists
MIGRATION_FILE="supabase/migrations/20250721093053_remote_commit.sql"
if [ ! -f "$MIGRATION_FILE" ]; then
    echo "Creating new migration file..."
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    MIGRATION_FILE="supabase/migrations/${TIMESTAMP}_complete_schema.sql"
fi

echo "📄 Target migration file: $MIGRATION_FILE"
echo ""

# Create the complete export query
cat > /tmp/export_query.sql << 'EOF'
-- COMPLETE SCHEMA EXPORT
-- Run each section and copy the results

-- 1. EXTENSIONS
SELECT 'CREATE EXTENSION IF NOT EXISTS "' || extname || '";'
FROM pg_extension
WHERE extname NOT IN ('plpgsql', 'pg_stat_statements');

-- 2. TYPES
SELECT pg_catalog.format_type(t.oid, NULL) AS type_name,
       pg_get_userbyid(t.typowner) AS owner,
       obj_description(t.oid, 'pg_type') AS description
FROM pg_type t
JOIN pg_namespace n ON t.typnamespace = n.oid
WHERE n.nspname = 'public'
AND t.typtype = 'e';

-- 3. TABLES WITH COLUMNS
WITH table_ddl AS (
  SELECT 
    'CREATE TABLE IF NOT EXISTS public.' || c.relname || ' (' || E'\n' ||
    string_agg(
      '  ' || a.attname || ' ' || 
      pg_catalog.format_type(a.atttypid, a.atttypmod) ||
      CASE WHEN a.attnotnull THEN ' NOT NULL' ELSE '' END ||
      CASE WHEN ad.adsrc IS NOT NULL THEN ' DEFAULT ' || ad.adsrc ELSE '' END,
      ',' || E'\n' ORDER BY a.attnum
    ) || E'\n);' as ddl
  FROM pg_class c
  JOIN pg_namespace n ON c.relnamespace = n.oid
  JOIN pg_attribute a ON a.attrelid = c.oid
  LEFT JOIN pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
  WHERE n.nspname = 'public'
  AND c.relkind = 'r'
  AND a.attnum > 0
  AND NOT a.attisdropped
  GROUP BY c.relname
)
SELECT ddl FROM table_ddl ORDER BY ddl;

-- 4. PRIMARY KEYS
SELECT 
  'ALTER TABLE public.' || conrelid::regclass || 
  ' ADD CONSTRAINT ' || conname || 
  ' PRIMARY KEY (' || 
  string_agg(a.attname, ', ' ORDER BY u.ord) || 
  ');'
FROM pg_constraint
JOIN LATERAL unnest(conkey) WITH ORDINALITY u(attnum, ord) ON TRUE
JOIN pg_attribute a ON a.attnum = u.attnum AND a.attrelid = conrelid
WHERE contype = 'p'
AND connamespace = 'public'::regnamespace
GROUP BY conrelid, conname;

-- 5. FOREIGN KEYS
SELECT
  'ALTER TABLE public.' || conrelid::regclass || 
  ' ADD CONSTRAINT ' || conname || 
  ' FOREIGN KEY (' || 
  string_agg(a.attname, ', ' ORDER BY u.ord) || 
  ') REFERENCES public.' || confrelid::regclass || '(' || 
  string_agg(af.attname, ', ' ORDER BY uf.ord) || ')' ||
  CASE confupdtype
    WHEN 'c' THEN ' ON UPDATE CASCADE'
    WHEN 'n' THEN ' ON UPDATE SET NULL'
    WHEN 'd' THEN ' ON UPDATE SET DEFAULT'
    ELSE ''
  END ||
  CASE confdeltype
    WHEN 'c' THEN ' ON DELETE CASCADE'
    WHEN 'n' THEN ' ON DELETE SET NULL'
    WHEN 'd' THEN ' ON DELETE SET DEFAULT'
    ELSE ''
  END || ';'
FROM pg_constraint
JOIN LATERAL unnest(conkey) WITH ORDINALITY u(attnum, ord) ON TRUE
JOIN LATERAL unnest(confkey) WITH ORDINALITY uf(attnum, ord) ON u.ord = uf.ord
JOIN pg_attribute a ON a.attnum = u.attnum AND a.attrelid = conrelid
JOIN pg_attribute af ON af.attnum = uf.attnum AND af.attrelid = confrelid
WHERE contype = 'f'
AND connamespace = 'public'::regnamespace
GROUP BY conrelid, conname, confrelid, confupdtype, confdeltype;

-- 6. INDEXES
SELECT pg_get_indexdef(indexrelid) || ';'
FROM pg_index
WHERE indrelid IN (
  SELECT oid FROM pg_class 
  WHERE relnamespace = 'public'::regnamespace
)
AND NOT indisprimary;

-- 7. FUNCTIONS
SELECT pg_get_functiondef(oid) || ';'
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace;

-- 8. TRIGGERS
SELECT 
  'CREATE TRIGGER ' || t.tgname || E'\n' ||
  CASE 
    WHEN t.tgtype & 2 = 2 THEN '  BEFORE'
    ELSE '  AFTER'
  END ||
  CASE 
    WHEN t.tgtype & 4 = 4 THEN ' INSERT'
    WHEN t.tgtype & 8 = 8 THEN ' DELETE'
    WHEN t.tgtype & 16 = 16 THEN ' UPDATE'
  END ||
  CASE
    WHEN t.tgtype & 64 = 64 THEN ' OR TRUNCATE'
    ELSE ''
  END || E'\n' ||
  '  ON public.' || c.relname || E'\n' ||
  '  FOR EACH ' ||
  CASE
    WHEN t.tgtype & 1 = 1 THEN 'ROW'
    ELSE 'STATEMENT'
  END || E'\n' ||
  '  EXECUTE FUNCTION ' || p.proname || '(' ||
  array_to_string(
    array(
      SELECT quote_literal(unnest(string_to_array(encode(t.tgargs, 'escape'), E'\\000')))
    ), ', '
  ) || ');'
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE NOT t.tgisinternal
AND c.relnamespace = 'public'::regnamespace;

-- 9. VIEWS
SELECT 
  'CREATE OR REPLACE VIEW public.' || viewname || ' AS' || E'\n' || 
  definition
FROM pg_views
WHERE schemaname = 'public';

-- 10. RLS POLICIES
-- First enable RLS
SELECT 'ALTER TABLE public.' || tablename || ' ENABLE ROW LEVEL SECURITY;'
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;

-- Then create policies
SELECT 
  'CREATE POLICY "' || policyname || '"' || E'\n' ||
  '  ON public.' || tablename || E'\n' ||
  '  AS ' || permissive || E'\n' ||
  '  FOR ' || cmd || E'\n' ||
  CASE 
    WHEN roles::text != '{public}' 
    THEN '  TO ' || array_to_string(roles, ', ') || E'\n' 
    ELSE '' 
  END ||
  CASE 
    WHEN qual IS NOT NULL 
    THEN '  USING (' || qual || ')' || E'\n' 
    ELSE '' 
  END ||
  CASE 
    WHEN with_check IS NOT NULL 
    THEN '  WITH CHECK (' || with_check || ')' 
    ELSE '' 
  END || ';'
FROM pg_policies
WHERE schemaname = 'public';

-- 11. COMMENTS
SELECT 
  'COMMENT ON TABLE public.' || tablename || ' IS ' || 
  quote_literal(obj_description(c.oid)) || ';'
FROM pg_tables t
JOIN pg_class c ON c.relname = t.tablename
WHERE t.schemaname = 'public'
AND obj_description(c.oid) IS NOT NULL;

-- 12. SEQUENCES
SELECT 
  'CREATE SEQUENCE IF NOT EXISTS public.' || sequence_name || 
  ' START WITH ' || start_value ||
  ' INCREMENT BY ' || increment ||
  CASE WHEN max_value IS NOT NULL THEN ' MAXVALUE ' || max_value ELSE ' NO MAXVALUE' END ||
  CASE WHEN min_value IS NOT NULL THEN ' MINVALUE ' || min_value ELSE ' NO MINVALUE' END ||
  CASE WHEN cycle_option = 'YES' THEN ' CYCLE' ELSE ' NO CYCLE' END || ';'
FROM information_schema.sequences
WHERE sequence_schema = 'public';
EOF

echo "📋 Export query created at: /tmp/export_query.sql"
echo ""
echo "Now opening Supabase SQL Editor..."
echo "Please:"
echo "1. Copy the queries from /tmp/export_query.sql"
echo "2. Run each section in SQL Editor"
echo "3. Copy ALL results"
echo "4. Come back here to paste"
echo ""

# Open SQL editor
open "https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"

# Also show the query file
if command -v code &> /dev/null; then
    code /tmp/export_query.sql
else
    cat /tmp/export_query.sql | less
fi

echo ""
echo "Press Enter when ready to paste the complete schema..."
read

# Create the migration file with proper header
cat > "$MIGRATION_FILE" << EOF
-- Complete Database Schema Export
-- Source: Staging (dijtowiohxvwdnvgprud)
-- Target: Production (zutbqmhxvdgvcllobtxo)
-- Generated: $(date)
--
-- This migration contains the complete schema including:
-- - Extensions
-- - Tables with all columns
-- - Primary and Foreign Keys
-- - Indexes
-- - Functions
-- - Triggers
-- - Views
-- - RLS Policies
-- - Comments
-- - Sequences

-- Start transaction to ensure atomic deployment
BEGIN;

-- Enable required extensions first
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

EOF

# Read pasted schema
echo "Paste your complete schema below (press Ctrl+D when done):"
echo "========================================================"
TEMP_FILE=$(mktemp)
cat > "$TEMP_FILE"

# Append to migration file
cat "$TEMP_FILE" >> "$MIGRATION_FILE"

# Add transaction end
echo -e "\n-- End transaction\nCOMMIT;" >> "$MIGRATION_FILE"

# Clean up
rm -f "$TEMP_FILE" /tmp/export_query.sql

echo ""
echo "✅ Complete schema exported!"
echo ""
echo "📄 Migration file: $MIGRATION_FILE"
echo "📊 Size: $(wc -c < "$MIGRATION_FILE") bytes"
echo "📊 Lines: $(wc -l < "$MIGRATION_FILE") lines"
echo ""
echo "Next steps:"
echo "1. Review the migration file"
echo "2. Commit it:"
echo "   git add supabase/migrations/"
echo "   git commit -m 'Add complete database schema from staging'"
echo "3. Push to deploy:"
echo "   git push origin main  # This will sync to production"
echo ""
echo "This will make production EXACTLY match staging!"