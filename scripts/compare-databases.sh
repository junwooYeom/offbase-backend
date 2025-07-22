#!/bin/bash

echo "======================================"
echo "Database Schema Comparison Tool"
echo "======================================"
echo ""
echo "This compares staging vs production schemas"
echo ""

# SQL queries for comparison
COMPARE_TABLES='
SELECT 
    COALESCE(s.table_name, p.table_name) as table_name,
    CASE 
        WHEN s.table_name IS NULL THEN ''MISSING IN STAGING''
        WHEN p.table_name IS NULL THEN ''MISSING IN PRODUCTION''
        ELSE ''EXISTS IN BOTH''
    END as status
FROM 
    (SELECT table_name FROM information_schema.tables WHERE table_schema = ''public'') s
FULL OUTER JOIN 
    (SELECT table_name FROM information_schema.tables WHERE table_schema = ''public'') p
ON s.table_name = p.table_name
WHERE s.table_name IS NULL OR p.table_name IS NULL
ORDER BY table_name;'

COMPARE_COLUMNS='
SELECT 
    COALESCE(s.table_name, p.table_name) as table_name,
    COALESCE(s.column_name, p.column_name) as column_name,
    CASE 
        WHEN s.column_name IS NULL THEN ''MISSING IN STAGING''
        WHEN p.column_name IS NULL THEN ''MISSING IN PRODUCTION''
        WHEN s.data_type != p.data_type THEN ''TYPE MISMATCH: '' || s.data_type || '' vs '' || p.data_type
        ELSE ''MATCH''
    END as status
FROM 
    (SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = ''public'') s
FULL OUTER JOIN 
    (SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = ''public'') p
ON s.table_name = p.table_name AND s.column_name = p.column_name
WHERE s.column_name IS NULL OR p.column_name IS NULL OR s.data_type != p.data_type
ORDER BY table_name, column_name;'

COMPARE_FUNCTIONS='
SELECT 
    COALESCE(s.routine_name, p.routine_name) as function_name,
    CASE 
        WHEN s.routine_name IS NULL THEN ''MISSING IN STAGING''
        WHEN p.routine_name IS NULL THEN ''MISSING IN PRODUCTION''
        ELSE ''EXISTS IN BOTH''
    END as status
FROM 
    (SELECT routine_name FROM information_schema.routines WHERE routine_schema = ''public'') s
FULL OUTER JOIN 
    (SELECT routine_name FROM information_schema.routines WHERE routine_schema = ''public'') p
ON s.routine_name = p.routine_name
WHERE s.routine_name IS NULL OR p.routine_name IS NULL
ORDER BY function_name;'

COMPARE_TRIGGERS='
SELECT 
    COALESCE(s.trigger_name, p.trigger_name) as trigger_name,
    COALESCE(s.event_object_table, p.event_object_table) as table_name,
    CASE 
        WHEN s.trigger_name IS NULL THEN ''MISSING IN STAGING''
        WHEN p.trigger_name IS NULL THEN ''MISSING IN PRODUCTION''
        ELSE ''EXISTS IN BOTH''
    END as status
FROM 
    (SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_schema = ''public'') s
FULL OUTER JOIN 
    (SELECT trigger_name, event_object_table FROM information_schema.triggers WHERE trigger_schema = ''public'') p
ON s.trigger_name = p.trigger_name
WHERE s.trigger_name IS NULL OR p.trigger_name IS NULL
ORDER BY trigger_name;'

# Save queries to file
cat > /tmp/compare_queries.sql << EOF
-- 1. Compare Tables
$COMPARE_TABLES

-- 2. Compare Columns
$COMPARE_COLUMNS

-- 3. Compare Functions
$COMPARE_FUNCTIONS

-- 4. Compare Triggers
$COMPARE_TRIGGERS

-- 5. Summary counts
SELECT 
    'Tables in Staging' as metric,
    COUNT(*) as count
FROM information_schema.tables 
WHERE table_schema = 'public'
UNION ALL
SELECT 
    'Functions in Staging' as metric,
    COUNT(*) as count
FROM information_schema.routines 
WHERE routine_schema = 'public'
UNION ALL
SELECT 
    'Triggers in Staging' as metric,
    COUNT(*) as count
FROM information_schema.triggers 
WHERE trigger_schema = 'public';
EOF

echo "Comparison queries saved to: /tmp/compare_queries.sql"
echo ""
echo "To compare databases:"
echo ""
echo "1. Run these queries on STAGING:"
echo "   https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
echo ""
echo "2. Run the same queries on PRODUCTION:"
echo "   https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/editor"
echo ""
echo "3. Compare the results"
echo ""
echo "Opening both SQL editors..."
open "https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
sleep 2
open "https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/editor"

if command -v code &> /dev/null; then
    code /tmp/compare_queries.sql
else
    echo ""
    echo "Queries available at: /tmp/compare_queries.sql"
fi