#!/bin/bash

echo "======================================"
echo "Supabase Setup Checker"
echo "======================================"
echo ""

# Check Supabase CLI
echo "1. Checking Supabase CLI..."
if command -v supabase &> /dev/null; then
    echo "✅ Supabase CLI installed ($(supabase --version))"
else
    echo "❌ Supabase CLI not installed"
fi
echo ""

# Check .env.local
echo "2. Checking .env.local..."
if [ -f ".env.local" ]; then
    echo "✅ .env.local exists"
    
    # Check for required variables
    source .env.local
    
    echo ""
    echo "Checking environment variables:"
    
    if [ ! -z "$PRODUCTION_PROJECT_REF" ]; then
        echo "✅ PRODUCTION_PROJECT_REF is set: $PRODUCTION_PROJECT_REF"
    else
        echo "❌ PRODUCTION_PROJECT_REF is missing"
    fi
    
    if [ ! -z "$STAGING_PROJECT_REF" ]; then
        echo "✅ STAGING_PROJECT_REF is set: $STAGING_PROJECT_REF"
    else
        echo "❌ STAGING_PROJECT_REF is missing"
    fi
    
    if [ ! -z "$SUPABASE_ACCESS_TOKEN" ]; then
        echo "✅ SUPABASE_ACCESS_TOKEN is set"
    else
        echo "❌ SUPABASE_ACCESS_TOKEN is missing"
        echo "   Get it from: https://app.supabase.com/account/tokens"
    fi
else
    echo "❌ .env.local not found"
    echo "   Copy .env.example to .env.local and fill in your values"
fi
echo ""

# Check GitHub secrets reminder
echo "3. GitHub Secrets Reminder"
echo "--------------------------"
echo "Make sure you've added these secrets to GitHub:"
echo "(Settings → Secrets and variables → Actions)"
echo ""
echo "Required secrets:"
echo "- SUPABASE_ACCESS_TOKEN"
echo "- PRODUCTION_PROJECT_REF (should be: dijtowiohxvwdnvgprud)"
echo "- STAGING_PROJECT_REF"
echo ""

# Check current linked project
echo "4. Current Supabase Project"
echo "---------------------------"
if [ -d ".supabase" ]; then
    echo "Currently linked to:"
    supabase projects list 2>/dev/null || echo "Unable to check project status"
else
    echo "No project currently linked"
fi
echo ""

# Show next steps
echo "======================================"
echo "Next Steps:"
echo "======================================"
echo ""
echo "1. If you haven't created a staging project:"
echo "   - Go to https://app.supabase.com"
echo "   - Create a new project"
echo "   - Run: ./scripts/initial-setup.sh"
echo ""
echo "2. To get your API keys:"
echo "   - Production: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/api"
echo "   - Staging: https://app.supabase.com/project/[your-staging-ref]/settings/api"
echo ""
echo "3. To switch between environments:"
echo "   ./scripts/switch-env.sh"
echo ""