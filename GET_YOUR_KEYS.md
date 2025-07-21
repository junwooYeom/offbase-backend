# Where to Get Your Supabase Keys

## 1. Production Keys (dijtowiohxvwdnvgprud)

1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud
2. Click **Settings** → **API**
3. You'll find:
   - **Project URL**: `https://dijtowiohxvwdnvgprud.supabase.co`
   - **anon public**: This is your `PRODUCTION_SUPABASE_ANON_KEY`
   - **service_role**: This is your `PRODUCTION_SUPABASE_SERVICE_ROLE_KEY` (keep secret!)

## 2. Staging Keys (after you create staging project)

1. Create new project at https://app.supabase.com
2. Once created, go to your staging project
3. Click **Settings** → **API**
4. Get the same keys as above for staging

## 3. Local Development Keys

When you run `supabase start`, it shows:
```
API URL: http://localhost:54321
anon key: eyJ...
service_role key: eyJ...
```

## 4. Supabase Access Token (for CLI)

1. Go to: https://app.supabase.com/account/tokens
2. Click **Generate New Token**
3. Give it a name like "GitHub Actions"
4. Copy the token (you won't see it again!)

## Adding to GitHub Secrets

1. Go to your GitHub repo
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets:

### For Deployment (Required)
- `SUPABASE_ACCESS_TOKEN` = (token from step 4 above)
- `PRODUCTION_PROJECT_REF` = `dijtowiohxvwdnvgprud`
- `STAGING_PROJECT_REF` = (your staging project ref)

### For Your Application (If needed in CI/CD)
- `PRODUCTION_SUPABASE_URL` = `https://dijtowiohxvwdnvgprud.supabase.co`
- `PRODUCTION_SUPABASE_ANON_KEY` = (from production API settings)
- `PRODUCTION_SUPABASE_SERVICE_ROLE_KEY` = (from production API settings)
- `STAGING_SUPABASE_URL` = `https://[staging-ref].supabase.co`
- `STAGING_SUPABASE_ANON_KEY` = (from staging API settings)
- `STAGING_SUPABASE_SERVICE_ROLE_KEY` = (from staging API settings)

## Example .env.local file

```bash
# Production
PRODUCTION_PROJECT_REF=dijtowiohxvwdnvgprud
PRODUCTION_SUPABASE_URL=https://dijtowiohxvwdnvgprud.supabase.co
PRODUCTION_SUPABASE_ANON_KEY=eyJ... (copy from dashboard)
PRODUCTION_SUPABASE_SERVICE_ROLE_KEY=eyJ... (copy from dashboard)

# Staging
STAGING_PROJECT_REF=your-staging-ref
STAGING_SUPABASE_URL=https://your-staging-ref.supabase.co
STAGING_SUPABASE_ANON_KEY=eyJ... (copy from dashboard)
STAGING_SUPABASE_SERVICE_ROLE_KEY=eyJ... (copy from dashboard)

# Local (from supabase start)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJ... (from supabase start output)
SUPABASE_SERVICE_ROLE_KEY=eyJ... (from supabase start output)

# CLI Token
SUPABASE_ACCESS_TOKEN=sbp_... (from account tokens page)
```

## Visual Guide

### Getting API Keys:
![Supabase API Settings](https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/api)
1. Project Settings → API
2. Copy the anon key (public, safe for frontend)
3. Copy the service_role key (secret, backend only!)

### Getting Project Reference:
1. It's in the URL: `https://app.supabase.com/project/[THIS-PART]`
2. Or in Settings → General → Reference ID

### Getting Access Token:
1. Go to https://app.supabase.com/account/tokens
2. Generate new token
3. Use this for GitHub Actions

## Security Notes

⚠️ **NEVER commit these to Git:**
- Service role keys
- Access tokens
- Any key that starts with `eyJ` or `sbp_`

✅ **Safe to commit:**
- Project URLs (they're public anyway)
- Project references

## Quick Checklist

- [ ] Get production keys from dashboard
- [ ] Create staging project
- [ ] Get staging keys from dashboard
- [ ] Generate access token
- [ ] Add all secrets to GitHub
- [ ] Create .env.local for local development
- [ ] Test with `./scripts/switch-env.sh`