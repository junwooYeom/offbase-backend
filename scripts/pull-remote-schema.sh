#!/bin/bash

# Script to pull remote schema from Supabase

echo "==================================="
echo "Supabase Remote Schema Pull"
echo "==================================="
echo ""

# Check if we have a linked project
if [ ! -d ".supabase" ]; then
    echo "❌ No Supabase project linked!"
    echo ""
    echo "Please link your project first:"
    echo "  supabase link --project-ref your-project-ref"
    echo ""
    echo "You can find your project ref in:"
    echo "  1. Supabase Dashboard → Settings → General"
    echo "  2. Or in your project URL: https://app.supabase.com/project/[PROJECT_REF]"
    exit 1
fi

echo "Current linked project:"
supabase projects list
echo ""

# Confirm before pulling
echo "⚠️  This will create a new migration file with your remote schema"
read -p "Continue? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

# Create backup of existing migrations
if [ -d "supabase/migrations" ]; then
    echo "Backing up existing migrations..."
    cp -r supabase/migrations supabase/migrations.backup.$(date +%Y%m%d_%H%M%S)
fi

# Pull remote schema
echo ""
echo "Pulling remote schema..."
supabase db pull

echo ""
echo "✅ Remote schema pulled successfully!"
echo ""
echo "Next steps:"
echo "1. Check the new migration file in supabase/migrations/"
echo "2. Review the generated SQL"
echo "3. Commit the migration to version control"
echo "4. From now on, make all schema changes through migration files"
echo ""
echo "To see what was pulled:"
echo "  ls -la supabase/migrations/"