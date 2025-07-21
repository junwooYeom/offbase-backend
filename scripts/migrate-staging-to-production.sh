#!/bin/bash

echo "=============================================="
echo "Migrate Staging to Production"
echo "=============================================="
echo ""
echo "This will migrate your schema from:"
echo "Staging: dijtowiohxvwdnvgprud.supabase.co"
echo "To Production: zutbqmhxvdgvcllobtxo.supabase.co"
echo ""

# Safety check
echo "⚠️  WARNING: This will modify your PRODUCTION database!"
echo "Make sure you have:"
echo "1. Backed up any existing production data"
echo "2. Tested everything in staging"
echo ""
read -p "Continue? (type 'yes' to proceed): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

# Step 1: Link to staging and pull schema
echo ""
echo "Step 1: Pulling schema from staging..."
echo "--------------------------------------"

# Remove existing link
if [ -d ".supabase" ]; then
    rm -rf .supabase
fi

# Link to staging
supabase link --project-ref dijtowiohxvwdnvgprud

# Pull the schema
supabase db pull

echo "✅ Schema pulled from staging"
echo ""

# Show what was pulled
echo "Migration files created:"
ls -la supabase/migrations/
echo ""

# Step 2: Link to production and push
echo "Step 2: Pushing schema to production..."
echo "---------------------------------------"

# Remove staging link
rm -rf .supabase

# Link to production
supabase link --project-ref zutbqmhxvdgvcllobtxo

# Show what will be pushed
echo ""
echo "Preview of changes to be applied:"
supabase db diff

echo ""
echo "⚠️  Last chance to cancel!"
read -p "Push these changes to PRODUCTION? (type 'yes' to proceed): " final_confirm

if [ "$final_confirm" != "yes" ]; then
    echo "Migration cancelled."
    exit 0
fi

# Push to production
echo ""
echo "Pushing to production..."
supabase db push

echo ""
echo "✅ Migration complete!"
echo ""
echo "Next steps:"
echo "1. Verify everything works in production"
echo "2. Update your .env files with the correct project references"
echo "3. Commit the migration files to git"
echo ""
echo "Your environments are now:"
echo "- Staging (develop): dijtowiohxvwdnvgprud.supabase.co"
echo "- Production (main): zutbqmhxvdgvcllobtxo.supabase.co"