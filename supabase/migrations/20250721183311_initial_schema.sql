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

