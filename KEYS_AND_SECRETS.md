# Where to Put Your Keys and Secrets

## For GitHub Actions (Database Migrations Only)

**GitHub Secrets needed:**
```
SUPABASE_ACCESS_TOKEN     # For Supabase CLI authentication
STAGING_PROJECT_REF       # dijtowiohxvwdnvgprud
PRODUCTION_PROJECT_REF    # zutbqmhxvdgvcllobtxo
```

That's it! The GitHub Action only needs these to deploy migrations.

## For Your Application Code

This depends on how your application runs:

### Option 1: If your app runs in GitHub Actions
Add these additional secrets:
```
STAGING_SUPABASE_URL
STAGING_SUPABASE_ANON_KEY
PRODUCTION_SUPABASE_URL  
PRODUCTION_SUPABASE_ANON_KEY
```

### Option 2: If your app runs elsewhere (Vercel, AWS, etc.)
Add the keys to your hosting platform:
- Vercel: Project Settings → Environment Variables
- AWS: Parameter Store or Secrets Manager
- Heroku: Config Vars

## What Each Key Does

### 1. SUPABASE_ACCESS_TOKEN
- **Used by**: Supabase CLI only
- **Purpose**: Authenticates CLI commands
- **Where**: GitHub Secrets (for CI/CD)
- **Get from**: https://app.supabase.com/account/tokens

### 2. PROJECT_REF
- **Used by**: Supabase CLI only
- **Purpose**: Identifies which project to deploy to
- **Where**: GitHub Secrets
- **Example**: `dijtowiohxvwdnvgprud`

### 3. SUPABASE_URL
- **Used by**: Your application code
- **Purpose**: API endpoint for your app
- **Where**: Wherever your app runs
- **Example**: `https://dijtowiohxvwdnvgprud.supabase.co`

### 4. SUPABASE_ANON_KEY
- **Used by**: Your application code
- **Purpose**: Public key for client-side auth
- **Where**: Wherever your app runs
- **Safe to expose**: Yes (has RLS protection)

### 5. SUPABASE_SERVICE_ROLE_KEY
- **Used by**: Backend/server code only
- **Purpose**: Bypasses RLS (admin access)
- **Where**: Server environment only
- **Safe to expose**: NO! Keep secret!

## Quick Reference

### Minimum GitHub Secrets:
```yaml
# For migrations only
SUPABASE_ACCESS_TOKEN: sbp_xxx...
STAGING_PROJECT_REF: dijtowiohxvwdnvgprud
PRODUCTION_PROJECT_REF: zutbqmhxvdgvcllobtxo
```

### For Local Development (.env.local):
```bash
# All keys for testing
STAGING_SUPABASE_URL=https://dijtowiohxvwdnvgprud.supabase.co
STAGING_SUPABASE_ANON_KEY=eyJ...
STAGING_SUPABASE_SERVICE_ROLE_KEY=eyJ...
# ... etc
```

### For Your App (wherever it's hosted):
```bash
# Only what your app needs
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...
```

## Summary

- **GitHub Actions for migrations**: Only needs ACCESS_TOKEN and PROJECT_REFs
- **Your application**: Needs URL and ANON_KEY (add where your app is hosted)
- **Local development**: Put everything in .env.local for testing