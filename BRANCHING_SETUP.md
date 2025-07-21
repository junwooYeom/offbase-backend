# Database Branching Setup

## Overview

- **Production Database** (`main` branch): `dijtowiohxvwdnvgprud.supabase.co`
- **Staging Database** (`develop` branch): To be created

## Step 1: Create Staging Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Name it: `offbase-backend-staging` (or similar)
4. Choose the same region as production for consistency
5. Save the staging project reference (it will look like `xxxxxxxxxxxxx`)

## Step 2: Pull Production Schema

First, let's get your production schema into migration files:

```bash
# Link to your production project
supabase link --project-ref dijtowiohxvwdnvgprud

# Pull the existing schema
supabase db pull

# This creates a migration file with all your current tables, functions, triggers
```

## Step 3: Setup Staging Database

Once you have your staging project created:

```bash
# Switch to staging project
supabase link --project-ref your-staging-project-ref

# Push the production schema to staging
supabase db push

# Now both databases have the same schema
```

## Step 4: Environment Configuration

Update your `.env.local`:

```bash
# Production (main branch)
PRODUCTION_SUPABASE_URL=https://dijtowiohxvwdnvgprud.supabase.co
PRODUCTION_SUPABASE_ANON_KEY=your-prod-anon-key
PRODUCTION_SUPABASE_SERVICE_ROLE_KEY=your-prod-service-key
PRODUCTION_PROJECT_REF=dijtowiohxvwdnvgprud

# Staging (develop branch)
STAGING_SUPABASE_URL=https://your-staging-ref.supabase.co
STAGING_SUPABASE_ANON_KEY=your-staging-anon-key
STAGING_SUPABASE_SERVICE_ROLE_KEY=your-staging-service-key
STAGING_PROJECT_REF=your-staging-project-ref

# For Supabase CLI
SUPABASE_ACCESS_TOKEN=your-access-token
```

## Step 5: GitHub Secrets

Add these secrets to your GitHub repository:
(Settings → Secrets and variables → Actions)

- `SUPABASE_ACCESS_TOKEN`
- `PRODUCTION_PROJECT_REF` = `dijtowiohxvwdnvgprud`
- `STAGING_PROJECT_REF` = `your-staging-project-ref`
- `PRODUCTION_SUPABASE_URL` = `https://dijtowiohxvwdnvgprud.supabase.co`
- `PRODUCTION_SUPABASE_ANON_KEY`
- `STAGING_SUPABASE_URL`
- `STAGING_SUPABASE_ANON_KEY`

## Workflow

### For New Features:

1. **Create feature branch from develop**
   ```bash
   git checkout develop
   git checkout -b feature/new-feature
   ```

2. **Create migration**
   ```bash
   supabase migration new feature_name
   ```

3. **Test locally**
   ```bash
   supabase db reset
   ```

4. **Push to develop branch**
   - Automatically deploys to staging

5. **After testing, merge to main**
   - Automatically deploys to production

### Branch Protection Rules

Set up on GitHub:

1. **main branch**:
   - Require pull request reviews
   - Require status checks to pass
   - Include administrators

2. **develop branch**:
   - Require status checks to pass

## Quick Commands

```bash
# Switch to production
supabase link --project-ref dijtowiohxvwdnvgprud

# Switch to staging  
supabase link --project-ref your-staging-ref

# Check current project
supabase projects list

# See schema differences
supabase db diff
```