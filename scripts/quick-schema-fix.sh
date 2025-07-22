#!/bin/bash

echo "======================================"
echo "Quick Schema Fix"
echo "======================================"
echo ""

MIGRATION_FILE="supabase/migrations/20250721093053_remote_commit.sql"

echo "Attempting to get schema using different methods..."
echo ""

# Method 1: Try with supabase db dump
echo "Method 1: Using supabase db dump..."
if [ ! -z "$STAGING_DATABASE_URL" ]; then
    supabase db dump --db-url "$STAGING_DATABASE_URL" > "$MIGRATION_FILE.tmp" 2>/dev/null
    if [ -s "$MIGRATION_FILE.tmp" ]; then
        mv "$MIGRATION_FILE.tmp" "$MIGRATION_FILE"
        echo "✅ Schema exported successfully!"
    else
        echo "❌ Method 1 failed"
        rm -f "$MIGRATION_FILE.tmp"
    fi
fi

# Check if migration file is still empty
if [ ! -s "$MIGRATION_FILE" ]; then
    echo ""
    echo "Method 2: Manual schema template"
    echo "Creating a basic migration template..."
    
    cat > "$MIGRATION_FILE" << 'EOF'
-- Initial schema migration
-- Project: dijtowiohxvwdnvgprud (staging)
-- 
-- IMPORTANT: Replace this with your actual schema!
-- 
-- To get your schema:
-- 1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor
-- 2. Run this query:

/*
SELECT 
    'CREATE TABLE IF NOT EXISTS public.' || tablename || ' (id uuid PRIMARY KEY DEFAULT uuid_generate_v4());' 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;
*/

-- Then run these queries to get full details:
-- For each table: \d public.table_name

-- Common Supabase tables (add your actual schema):

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Example user table (replace with your actual schema)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add your other tables here...

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Add your RLS policies here...

EOF
    
    echo "✅ Created template migration file"
    echo ""
    echo "⚠️  IMPORTANT: This is just a template!"
    echo "   You need to replace it with your actual schema"
fi

echo ""
echo "Current migration file status:"
echo "📄 File: $MIGRATION_FILE"
echo "📊 Size: $(wc -c < "$MIGRATION_FILE") bytes"
echo "📊 Lines: $(wc -l < "$MIGRATION_FILE") lines"
echo ""
echo "Next steps:"
echo "1. Edit the migration file with your actual schema"
echo "2. Or run: ./scripts/get-staging-schema.sh"
echo "3. Then commit and push"