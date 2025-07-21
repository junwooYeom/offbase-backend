#!/bin/bash

echo "======================================"
echo "Offbase Backend - Initial Setup"
echo "======================================"
echo ""
echo "This script will help you set up your database branching"
echo ""

# Production is already known
PROD_REF="dijtowiohxvwdnvgprud"

echo "✅ Production Project: $PROD_REF"
echo ""

# Step 1: Link to production and pull schema
echo "Step 1: Pulling existing schema from production..."
echo "------------------------------------------------"

supabase link --project-ref $PROD_REF

echo ""
echo "Pulling schema..."
supabase db pull

echo ""
echo "✅ Production schema pulled successfully!"
echo ""

# Step 2: Instructions for staging
echo "Step 2: Create Staging Project"
echo "------------------------------"
echo ""
echo "Please do the following:"
echo "1. Go to https://app.supabase.com"
echo "2. Create a new project named 'offbase-backend-staging'"
echo "3. Choose the same region as production"
echo "4. Once created, copy the project reference from:"
echo "   Settings → General → Reference ID"
echo ""
read -p "Enter your staging project reference: " STAGING_REF

if [ -z "$STAGING_REF" ]; then
    echo "Error: Staging reference cannot be empty"
    exit 1
fi

# Step 3: Push schema to staging
echo ""
echo "Step 3: Setting up staging database..."
echo "--------------------------------------"

supabase link --project-ref $STAGING_REF
supabase db push

echo ""
echo "✅ Staging database configured!"
echo ""

# Step 4: Create .env.local
echo "Step 4: Creating .env.local file..."
echo "-----------------------------------"

cat > .env.local << EOF
# Project References
PRODUCTION_PROJECT_REF=$PROD_REF
STAGING_PROJECT_REF=$STAGING_REF

# Supabase CLI Access Token
# Get from: https://app.supabase.com/account/tokens
SUPABASE_ACCESS_TOKEN=your-access-token-here

# Production Environment
PRODUCTION_SUPABASE_URL=https://$PROD_REF.supabase.co
PRODUCTION_SUPABASE_ANON_KEY=your-prod-anon-key
PRODUCTION_SUPABASE_SERVICE_ROLE_KEY=your-prod-service-key

# Staging Environment
STAGING_SUPABASE_URL=https://$STAGING_REF.supabase.co
STAGING_SUPABASE_ANON_KEY=your-staging-anon-key
STAGING_SUPABASE_SERVICE_ROLE_KEY=your-staging-service-key
EOF

echo "✅ Created .env.local"
echo ""

# Step 5: Final instructions
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Get your Supabase Access Token from:"
echo "   https://app.supabase.com/account/tokens"
echo ""
echo "2. Get API keys for both projects from:"
echo "   Project Dashboard → Settings → API"
echo ""
echo "3. Update .env.local with all the keys"
echo ""
echo "4. Add GitHub Secrets:"
echo "   - SUPABASE_ACCESS_TOKEN"
echo "   - PRODUCTION_PROJECT_REF = $PROD_REF"
echo "   - STAGING_PROJECT_REF = $STAGING_REF"
echo ""
echo "5. Commit and push:"
echo "   git add ."
echo "   git commit -m 'Setup database branching'"
echo "   git push"
echo ""
echo "Your environments:"
echo "- Production: main branch → $PROD_REF"
echo "- Staging: develop branch → $STAGING_REF"