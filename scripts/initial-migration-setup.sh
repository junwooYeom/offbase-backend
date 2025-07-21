#!/bin/bash

echo "======================================"
echo "Initial Migration Setup"
echo "======================================"
echo ""
echo "This will pull the complete schema from staging"
echo "and create your first migration file."
echo ""

# Staging project details
STAGING_REF="dijtowiohxvwdnvgprud"

# Check for Supabase CLI
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found! Please install it first."
    exit 1
fi

# Check for access token
if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo "❌ SUPABASE_ACCESS_TOKEN not set!"
    echo ""
    echo "Please either:"
    echo "1. Export it: export SUPABASE_ACCESS_TOKEN=your-token"
    echo "2. Add to .env.local and run: export \$(cat .env.local | xargs)"
    echo ""
    echo "Get your token from: https://app.supabase.com/account/tokens"
    exit 1
fi

# Create migrations directory if it doesn't exist
mkdir -p supabase/migrations

# Remove any existing link
if [ -d ".supabase" ]; then
    echo "🔄 Removing existing project link..."
    rm -rf .supabase
fi

# Link to staging
echo "🔗 Linking to staging project..."
supabase link --project-ref $STAGING_REF

if [ $? -ne 0 ]; then
    echo "❌ Failed to link to staging project!"
    echo "Please check your SUPABASE_ACCESS_TOKEN and try again."
    exit 1
fi

# Check if migrations already exist
if [ "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
    echo "⚠️  Migration files already exist!"
    echo ""
    ls -la supabase/migrations/
    echo ""
    read -p "Delete existing migrations and pull fresh? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        rm -f supabase/migrations/*.sql
        echo "✅ Existing migrations removed"
    else
        echo "Keeping existing migrations."
        exit 0
    fi
fi

# Pull the schema
echo ""
echo "📥 Pulling complete schema from staging..."
supabase db pull

if [ $? -ne 0 ]; then
    echo "❌ Failed to pull schema!"
    echo "Please check your database password and try again."
    exit 1
fi

# Check if migration was created
if [ ! "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
    echo "❌ No migration file was created!"
    echo "This might mean the staging database is empty."
    exit 1
fi

# Show what was created
echo ""
echo "✅ Migration file created successfully!"
echo ""
echo "📄 Migration files:"
ls -la supabase/migrations/

# Get the migration filename
MIGRATION_FILE=$(ls -t supabase/migrations/*.sql | head -1)

echo ""
echo "📊 Migration preview (first 20 lines):"
head -20 "$MIGRATION_FILE"
echo ""
echo "... (file continues)"
echo ""

# Create a README for migrations
cat > supabase/migrations/README.md << 'EOF'
# Database Migrations

This directory contains all database migrations for the project.

## Initial Migration

The initial migration was pulled from the staging database and contains:
- All tables with their schemas
- Functions and stored procedures
- Triggers
- RLS (Row Level Security) policies
- Views
- Indexes

## Creating New Migrations

To create a new migration:
```bash
supabase migration new descriptive_name
```

## Applying Migrations

Migrations are automatically applied via GitHub Actions:
- Push to `develop` → Applied to staging
- Push to `main` → Applied to production

## Local Testing

To test migrations locally:
```bash
supabase db reset
```

This will apply all migrations to your local database.
EOF

echo "📝 Created migrations README"
echo ""
echo "======================================"
echo "✅ Initial migration setup complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Review the migration file"
echo "2. Commit the changes:"
echo "   git add supabase/migrations/"
echo "   git commit -m 'Add initial database migration from staging'"
echo "3. Push to deploy:"
echo "   git push origin main  # For production"
echo "   git push origin develop  # For staging"
echo ""
echo "The GitHub Action will now successfully deploy your schema!"