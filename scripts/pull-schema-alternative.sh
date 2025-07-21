#!/bin/bash

echo "======================================"
echo "Alternative Schema Pull Methods"
echo "======================================"
echo ""

# Method 1: Try with IPv4 forcing
echo "Method 1: Force IPv4 connection"
echo "--------------------------------"
echo "Trying to pull with IPv4 only..."

# Get the IPv4 address
IPV4_ADDR=$(dig +short db.dijtowiohxvwdnvgprud.supabase.co A | head -1)
if [ ! -z "$IPV4_ADDR" ]; then
    echo "Found IPv4: $IPV4_ADDR"
    echo "Try this command:"
    echo "supabase db pull --db-url \"postgresql://postgres:YOUR-PASSWORD@$IPV4_ADDR:5432/postgres?sslmode=require\""
fi

echo ""
echo "Method 2: Use Pooler Connection"
echo "--------------------------------"
echo "If direct connection fails, try the pooler URL:"
echo ""
echo "1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database"
echo "2. Click 'Connection pooling' tab"
echo "3. Copy the connection string"
echo "4. It should look like:"
echo "   postgresql://postgres.dijtowiohxvwdnvgprud:[password]@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
echo ""

echo "Method 3: Manual Export via Dashboard"
echo "--------------------------------------"
echo "1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
echo "2. Click 'New Query'"
echo "3. Run this query to export schema:"
echo ""
cat << 'EOF'
-- Export all tables
SELECT 
    'CREATE TABLE IF NOT EXISTS ' || table_schema || '.' || table_name || ' (' || 
    string_agg(
        column_name || ' ' || 
        CASE 
            WHEN data_type = 'character varying' THEN 'varchar(' || character_maximum_length || ')'
            WHEN data_type = 'numeric' THEN 'numeric(' || numeric_precision || ',' || numeric_scale || ')'
            ELSE data_type
        END ||
        CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
        CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END,
        ', '
    ) || ');'
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY table_schema, table_name;
EOF

echo ""
echo "Method 4: Use Supabase CLI without Password"
echo "--------------------------------------------"
echo "Try linking without database connection:"
echo ""
echo "supabase link --project-ref dijtowiohxvwdnvgprud"
echo "supabase db remote commit"
echo ""
echo "This creates a migration from the remote database without direct connection."

echo ""
echo "Method 5: Export via pg_dump (if you have psql)"
echo "------------------------------------------------"
echo "If you have PostgreSQL client installed:"
echo ""
echo "PGPASSWORD=your-password pg_dump \\"
echo "  -h db.dijtowiohxvwdnvgprud.supabase.co \\"
echo "  -U postgres \\"
echo "  -d postgres \\"
echo "  --schema-only \\"
echo "  --no-owner \\"
echo "  --no-privileges \\"
echo "  > schema.sql"