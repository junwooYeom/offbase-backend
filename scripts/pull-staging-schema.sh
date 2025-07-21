#!/bin/bash

echo "======================================"
echo "Pull Schema from Staging"
echo "======================================"
echo ""
echo "This will pull all tables, functions, and triggers from staging"
echo "Staging: dijtowiohxvwdnvgprud.supabase.co"
echo ""

# Check for access token
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "⚠️  SUPABASE_ACCESS_TOKEN not set!"
    echo "Please set it in your .env.local or export it"
    exit 1
fi

# Remove any existing link
if [ -d ".supabase" ]; then
    rm -rf .supabase
fi

# Create migrations directory if it doesn't exist
mkdir -p supabase/migrations

# Link to staging
echo "Linking to staging project..."
supabase link --project-ref dijtowiohxvwdnvgprud

# Pull the schema
echo ""
echo "Pulling schema from staging..."
supabase db pull

echo ""
echo "✅ Schema pulled successfully!"
echo ""
echo "Migration files created:"
ls -la supabase/migrations/

echo ""
echo "Next steps:"
echo "1. Review the migration files"
echo "2. Commit them to git"
echo "3. Push to trigger deployment"