#!/bin/bash

echo "======================================"
echo "Migration Rollback Tool"
echo "======================================"
echo ""

# Check if backup directory exists
if [ ! -d "backups" ]; then
    echo "❌ No backups directory found!"
    echo "Backups are created automatically during production deployments"
    exit 1
fi

# List available backups
echo "Available backups:"
echo ""
ls -la backups/*.sql 2>/dev/null | awk '{print NR ". " $9}'

if [ $? -ne 0 ]; then
    echo "❌ No backup files found!"
    exit 1
fi

echo ""
read -p "Select backup number to restore (or 'q' to quit): " choice

if [ "$choice" = "q" ]; then
    echo "Rollback cancelled."
    exit 0
fi

# Get the backup file
BACKUP_FILE=$(ls backups/*.sql 2>/dev/null | sed -n "${choice}p")

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ Invalid selection!"
    exit 1
fi

echo ""
echo "Selected backup: $BACKUP_FILE"
echo ""
echo "⚠️  WARNING: This will restore the database to the backup state!"
echo "⚠️  All changes made after this backup will be lost!"
echo ""
read -p "Are you sure? (type 'yes' to continue): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Rollback cancelled."
    exit 0
fi

# Determine environment
echo ""
echo "Select environment to rollback:"
echo "1. Staging (dijtowiohxvwdnvgprud)"
echo "2. Production (zutbqmhxvdgvcllobtxo)"
read -p "Enter choice [1-2]: " env_choice

case $env_choice in
    1)
        PROJECT_REF="$STAGING_PROJECT_REF"
        DB_PASSWORD="$STAGING_DB_PASSWORD"
        ENV_NAME="Staging"
        ;;
    2)
        PROJECT_REF="$PRODUCTION_PROJECT_REF"
        DB_PASSWORD="$PRODUCTION_DB_PASSWORD"
        ENV_NAME="Production"
        echo ""
        echo "⚠️  CRITICAL: You're about to rollback PRODUCTION!"
        read -p "Type 'ROLLBACK PRODUCTION' to confirm: " prod_confirm
        if [ "$prod_confirm" != "ROLLBACK PRODUCTION" ]; then
            echo "Rollback cancelled."
            exit 0
        fi
        ;;
    *)
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac

echo ""
echo "🔄 Starting rollback for $ENV_NAME..."

# Create a current backup before rollback
echo "📸 Creating safety backup of current state..."
SAFETY_BACKUP="backups/pre-rollback-$(date +%Y%m%d-%H%M%S).sql"
supabase link --project-ref "$PROJECT_REF" --password "$DB_PASSWORD"
supabase db pull --schema public > "$SAFETY_BACKUP"
echo "✅ Safety backup created: $SAFETY_BACKUP"

# Note: Actual rollback would require direct database access
# This is a placeholder for the rollback logic
echo ""
echo "❌ Automated rollback not implemented!"
echo ""
echo "To manually rollback:"
echo "1. Connect to your database using psql or Supabase SQL Editor"
echo "2. Run the backup SQL file: $BACKUP_FILE"
echo "3. Or contact Supabase support for assistance"
echo ""
echo "Your safety backup is saved at: $SAFETY_BACKUP"

# Alternative approach - create a rollback migration
echo ""
echo "Alternative: Create a rollback migration"
echo "1. supabase migration new rollback_$(date +%Y%m%d)"
echo "2. Add the backup SQL to the new migration file"
echo "3. Commit and push to apply"