#!/bin/bash

echo "======================================"
echo "Pull Schema Using Remote Commit"
echo "======================================"
echo ""
echo "This method doesn't require database connection!"
echo ""

# Check for access token
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "❌ SUPABASE_ACCESS_TOKEN not set!"
    echo ""
    echo "Get your token from:"
    echo "https://app.supabase.com/account/tokens"
    echo ""
    echo "Then run:"
    echo "export SUPABASE_ACCESS_TOKEN=your-token-here"
    exit 1
fi

# Check if migrations directory exists
mkdir -p supabase/migrations

# Remove any existing link
if [ -d ".supabase" ]; then
    echo "🔄 Removing existing project link..."
    rm -rf .supabase
fi

# Link to staging project
echo "🔗 Linking to staging project..."
supabase link --project-ref dijtowiohxvwdnvgprud

if [ $? -ne 0 ]; then
    echo "❌ Failed to link project!"
    echo "Check your SUPABASE_ACCESS_TOKEN"
    exit 1
fi

echo ""
echo "📥 Creating migration from remote schema..."
echo "This doesn't require database connection!"
echo ""

# Use remote commit to create migration
supabase db remote commit

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migration created successfully!"
    echo ""
    echo "📄 New migration files:"
    ls -la supabase/migrations/*.sql 2>/dev/null || echo "Check supabase/migrations/ directory"
    
    echo ""
    echo "Next steps:"
    echo "1. Review the migration file"
    echo "2. Commit it:"
    echo "   git add supabase/migrations/"
    echo "   git commit -m 'Add initial database migration'"
    echo "3. Push to deploy:"
    echo "   git push origin main"
else
    echo ""
    echo "❌ Failed to create migration"
    echo ""
    echo "Alternative: Manual export"
    echo "1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor"
    echo "2. Export your schema manually"
    echo "3. Create migration file: supabase migration new initial_schema"
    echo "4. Paste the schema into the file"
fi