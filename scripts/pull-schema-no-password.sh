#!/bin/bash

echo "======================================"
echo "Pull Schema Without Password Prompt"
echo "======================================"
echo ""

# Check for access token
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "❌ SUPABASE_ACCESS_TOKEN not set!"
    echo "Get it from: https://app.supabase.com/account/tokens"
    exit 1
fi

# Create migrations directory
mkdir -p supabase/migrations

# Remove existing link
rm -rf .supabase

echo "🔗 Linking to staging project..."
# Use empty input to skip password prompt
echo "" | supabase link --project-ref dijtowiohxvwdnvgprud

echo ""
echo "📥 Pulling schema..."
echo ""
echo "If this fails with password error, use the database URL method:"
echo ""

# Try to pull without password
supabase db pull 2>&1 | tee pull.log

# Check if it failed due to password
if grep -q "password" pull.log || grep -q "SASL auth" pull.log; then
    echo ""
    echo "❌ Password authentication failed!"
    echo ""
    echo "Alternative method:"
    echo "1. Get your database URL from Supabase dashboard"
    echo "2. Run: supabase db pull --db-url 'your-database-url'"
    echo ""
    echo "Or use the direct SQL export:"
    echo "1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
    echo "2. Run this query:"
    echo "   SELECT 'CREATE TABLE ' || schemaname || '.' || tablename || ' AS SELECT * FROM ' || schemaname || '.' || tablename || ';'"
    echo "   FROM pg_tables WHERE schemaname = 'public';"
    echo "3. Export the schema manually"
    rm -f pull.log
    exit 1
fi

rm -f pull.log

# Check if migrations were created
if [ "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
    echo ""
    echo "✅ Schema pulled successfully!"
    ls -la supabase/migrations/
else
    echo ""
    echo "❌ No migrations created. The database might be empty."
fi