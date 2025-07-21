# Environment Setup Guide

## Overview

This project uses separate Supabase projects for different environments:
- **Development**: Branch `develop` → Development Supabase Project
- **Production**: Branch `main` → Production Supabase Project

## Setting Up Multiple Supabase Projects

### 1. Create Supabase Projects

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Create two projects:
   - `your-app-dev` (for development)
   - `your-app-prod` (for production)

### 2. Get Project Credentials

For each project, get:
- **Project URL**: Found in Settings → API
- **Anon Key**: Found in Settings → API
- **Service Role Key**: Found in Settings → API
- **Project Ref**: Found in Settings → General (or in the URL)

### 3. GitHub Secrets Setup

Add these secrets to your GitHub repository (Settings → Secrets → Actions):

```
# For Supabase CLI deployments
SUPABASE_ACCESS_TOKEN          # Your personal access token from https://app.supabase.com/account/tokens
DEVELOP_SUPABASE_PROJECT_REF   # Project ref for development
PRODUCTION_SUPABASE_PROJECT_REF # Project ref for production

# For application usage (if needed in CI/CD)
DEVELOP_SUPABASE_URL
DEVELOP_SUPABASE_ANON_KEY
DEVELOP_SUPABASE_SERVICE_ROLE_KEY

PRODUCTION_SUPABASE_URL
PRODUCTION_SUPABASE_ANON_KEY
PRODUCTION_SUPABASE_SERVICE_ROLE_KEY
```

### 4. Local Development Setup

Create `.env.local` (git-ignored):

```bash
# For local development with Docker
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<get-from-supabase-start-output>
SUPABASE_SERVICE_ROLE_KEY=<get-from-supabase-start-output>

# For connecting to development project
DEVELOP_SUPABASE_URL=https://your-dev-project.supabase.co
DEVELOP_SUPABASE_ANON_KEY=your-dev-anon-key
DEVELOP_SUPABASE_SERVICE_ROLE_KEY=your-dev-service-key
```

## Working with Different Environments

### Local Development

```bash
# Start local Supabase
supabase start

# Get local credentials
supabase status

# Reset database with migrations
supabase db reset
```

### Deploying to Development

```bash
# Link to development project
supabase link --project-ref your-dev-project-ref

# Push migrations
supabase db push

# Pull any remote changes
supabase db pull
```

### Deploying to Production

```bash
# Link to production project
supabase link --project-ref your-prod-project-ref

# Push migrations (be careful!)
supabase db push

# Always diff first
supabase db diff
```

## Environment Variables in Your Application

### Using Environment-Specific Variables

```javascript
// config.js
const config = {
  development: {
    supabaseUrl: process.env.DEVELOP_SUPABASE_URL,
    supabaseAnonKey: process.env.DEVELOP_SUPABASE_ANON_KEY,
  },
  production: {
    supabaseUrl: process.env.PRODUCTION_SUPABASE_URL,
    supabaseAnonKey: process.env.PRODUCTION_SUPABASE_ANON_KEY,
  },
  local: {
    supabaseUrl: process.env.SUPABASE_URL || 'http://localhost:54321',
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
  }
};

const environment = process.env.NODE_ENV || 'local';
export default config[environment];
```

### For Next.js Projects

```javascript
// .env.development
NEXT_PUBLIC_SUPABASE_URL=https://your-dev-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-dev-anon-key

// .env.production
NEXT_PUBLIC_SUPABASE_URL=https://your-prod-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-prod-anon-key

// .env.local (for local development)
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-local-anon-key
```

## Best Practices

1. **Never commit secrets**: All `.env` files should be git-ignored
2. **Use GitHub Secrets**: For CI/CD, always use GitHub Secrets
3. **Separate projects**: Always use separate Supabase projects for dev/prod
4. **Test migrations**: Always test on development before production
5. **Backup before deploy**: Consider backing up production before major changes

## Switching Between Projects Locally

```bash
# Check current linked project
supabase projects list

# Switch to development
supabase link --project-ref your-dev-project-ref

# Switch to production
supabase link --project-ref your-prod-project-ref

# Always verify before pushing
supabase db diff
```

## Troubleshooting

### Issue: Wrong project linked
```bash
# Unlink current project
rm -rf .supabase

# Re-link correct project
supabase link --project-ref correct-project-ref
```

### Issue: Migrations out of sync
```bash
# Pull remote schema
supabase db pull

# Compare with local
supabase db diff

# Reset local to match remote
supabase db reset
```