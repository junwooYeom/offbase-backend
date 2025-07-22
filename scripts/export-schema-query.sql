-- Complete Schema Export Query
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor

-- 1. First, let's see what tables exist
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. Export CREATE TABLE statements with all columns
WITH table_definitions AS (
    SELECT 
        t.table_name,
        'CREATE TABLE IF NOT EXISTS public.' || t.table_name || ' (' || E'\n' ||
        string_agg(
            '    ' || c.column_name || ' ' || 
            CASE 
                WHEN c.data_type = 'USER-DEFINED' THEN c.udt_name
                WHEN c.data_type = 'ARRAY' THEN 
                    CASE 
                        WHEN c.udt_name = '_text' THEN 'text[]'
                        WHEN c.udt_name = '_int4' THEN 'integer[]'
                        WHEN c.udt_name = '_jsonb' THEN 'jsonb[]'
                        ELSE c.udt_name || '[]'
                    END
                WHEN c.data_type = 'character varying' THEN 
                    'varchar' || CASE WHEN c.character_maximum_length IS NOT NULL 
                    THEN '(' || c.character_maximum_length || ')' ELSE '' END
                WHEN c.data_type = 'numeric' AND c.numeric_precision IS NOT NULL THEN 
                    'numeric(' || c.numeric_precision || ',' || COALESCE(c.numeric_scale, 0) || ')'
                ELSE c.data_type
            END ||
            CASE WHEN c.is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
            CASE WHEN c.column_default IS NOT NULL THEN ' DEFAULT ' || c.column_default ELSE '' END,
            ',' || E'\n' 
            ORDER BY c.ordinal_position
        ) || E'\n);' as create_statement
    FROM information_schema.tables t
    JOIN information_schema.columns c ON t.table_name = c.table_name
    WHERE t.table_schema = 'public' 
    AND t.table_type = 'BASE TABLE'
    GROUP BY t.table_name
    ORDER BY t.table_name
)
SELECT create_statement FROM table_definitions;

-- 3. Export Primary Keys
SELECT 
    'ALTER TABLE public.' || tc.table_name || 
    ' ADD CONSTRAINT ' || tc.constraint_name || 
    ' PRIMARY KEY (' || string_agg(kcu.column_name, ', ' ORDER BY kcu.ordinal_position) || ');'
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.constraint_type = 'PRIMARY KEY'
AND tc.table_schema = 'public'
GROUP BY tc.table_name, tc.constraint_name;

-- 4. Export Foreign Keys
SELECT 
    'ALTER TABLE public.' || tc.table_name || 
    ' ADD CONSTRAINT ' || tc.constraint_name || 
    ' FOREIGN KEY (' || kcu.column_name || ')' ||
    ' REFERENCES public.' || ccu.table_name || '(' || ccu.column_name || ')' ||
    CASE 
        WHEN rc.delete_rule != 'NO ACTION' THEN ' ON DELETE ' || rc.delete_rule 
        ELSE '' 
    END ||
    CASE 
        WHEN rc.update_rule != 'NO ACTION' THEN ' ON UPDATE ' || rc.update_rule 
        ELSE '' 
    END || ';'
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints rc
    ON rc.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public';

-- 5. Export Indexes
SELECT 
    'CREATE ' || 
    CASE WHEN i.indisunique THEN 'UNIQUE ' ELSE '' END ||
    'INDEX IF NOT EXISTS ' || indexname || 
    ' ON public.' || tablename || 
    ' USING ' || 
    CASE am.amname 
        WHEN 'btree' THEN 'btree' 
        WHEN 'hash' THEN 'hash'
        WHEN 'gist' THEN 'gist'
        WHEN 'gin' THEN 'gin'
        ELSE am.amname 
    END ||
    ' (' || 
    replace(replace(indexdef, 'CREATE INDEX ' || indexname || ' ON ' || schemaname || '.' || tablename || ' USING ' || am.amname || ' (', ''), ')', '') ||
    ');'
FROM pg_indexes pi
JOIN pg_class c ON c.relname = pi.indexname
JOIN pg_index i ON i.indexrelid = c.oid
JOIN pg_am am ON am.oid = c.relam
WHERE schemaname = 'public'
AND indexname NOT IN (
    SELECT constraint_name 
    FROM information_schema.table_constraints 
    WHERE constraint_type IN ('PRIMARY KEY', 'UNIQUE')
);

-- 6. Export Functions
SELECT 
    pg_get_functiondef(p.oid) || ';'
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public';

-- 7. Export Triggers
SELECT 
    'CREATE TRIGGER ' || trigger_name || E'\n' ||
    action_timing || ' ' || event_manipulation || E'\n' ||
    'ON public.' || event_object_table || E'\n' ||
    'FOR EACH ' || action_orientation || E'\n' ||
    'EXECUTE FUNCTION ' || action_statement || ';'
FROM information_schema.triggers
WHERE trigger_schema = 'public';

-- 8. Export Views
SELECT 
    'CREATE OR REPLACE VIEW public.' || viewname || ' AS ' || E'\n' || definition
FROM pg_views
WHERE schemaname = 'public';

-- 9. Export RLS Policies
SELECT 
    'ALTER TABLE public.' || tablename || ' ENABLE ROW LEVEL SECURITY;'
FROM pg_tables
WHERE schemaname = 'public'
AND rowsecurity = true;

SELECT 
    'CREATE POLICY "' || policyname || '" ON public.' || tablename || E'\n' ||
    'AS ' || permissive || E'\n' ||
    'FOR ' || cmd || E'\n' ||
    CASE WHEN roles::text != '{public}' THEN 'TO ' || array_to_string(roles, ', ') || E'\n' ELSE '' END ||
    CASE WHEN qual IS NOT NULL THEN 'USING (' || qual || ')' || E'\n' ELSE '' END ||
    CASE WHEN with_check IS NOT NULL THEN 'WITH CHECK (' || with_check || ')' ELSE '' END || ';'
FROM pg_policies
WHERE schemaname = 'public';