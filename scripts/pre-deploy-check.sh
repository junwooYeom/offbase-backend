#!/bin/bash

echo "======================================"
echo "Pre-Deployment Check"
echo "======================================"
echo ""

# Function to check environment
check_environment() {
    local env=$1
    local project_ref=$2
    local db_password=$3
    
    echo "🔍 Checking $env environment..."
    
    # Check if credentials exist
    if [ -z "$project_ref" ]; then
        echo "❌ Missing PROJECT_REF for $env"
        return 1
    fi
    
    if [ -z "$db_password" ]; then
        echo "❌ Missing DB_PASSWORD for $env"
        return 1
    fi
    
    if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
        echo "❌ Missing SUPABASE_ACCESS_TOKEN"
        return 1
    fi
    
    echo "✅ Credentials present for $env"
    return 0
}

# Check which branch we're on
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""

# Check migrations exist
if [ ! -d "supabase/migrations" ] || [ -z "$(ls -A supabase/migrations/*.sql 2>/dev/null)" ]; then
    echo "❌ No migration files found!"
    echo "Run: ./scripts/pull-staging-schema.sh to pull from staging"
    exit 1
fi

MIGRATION_COUNT=$(ls -1 supabase/migrations/*.sql 2>/dev/null | wc -l)
echo "📊 Found $MIGRATION_COUNT migration files"
echo ""

# Validate migrations
echo "🔍 Validating migrations..."
./scripts/validate-migrations.sh
VALIDATION_RESULT=$?

if [ $VALIDATION_RESULT -ne 0 ]; then
    echo ""
    echo "❌ Migration validation failed!"
    exit 1
fi

echo ""

# Check environment based on branch
case $CURRENT_BRANCH in
    "develop")
        echo "🎯 Target: Staging Environment"
        check_environment "staging" "$STAGING_PROJECT_REF" "$STAGING_DB_PASSWORD"
        ;;
    "main")
        echo "🎯 Target: Production Environment"
        echo "⚠️  WARNING: This will deploy to PRODUCTION!"
        check_environment "production" "$PRODUCTION_PROJECT_REF" "$PRODUCTION_DB_PASSWORD"
        ;;
    *)
        echo "ℹ️  Current branch '$CURRENT_BRANCH' is not configured for deployment"
        echo "   Deployments only happen from 'develop' and 'main' branches"
        ;;
esac

echo ""
echo "======================================"
echo "Pre-deployment check complete!"
echo "======================================"

# Show next steps
echo ""
echo "Next steps:"
echo "1. Review the migration files"
echo "2. Commit any changes"
echo "3. Push to trigger deployment:"
echo "   - Push to 'develop' → Deploy to Staging"
echo "   - Push to 'main' → Deploy to Production"