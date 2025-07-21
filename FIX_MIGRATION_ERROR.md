# Fix Migration Error

## The Error
The GitHub Action failed because:
1. Config differences between local and production
2. Missing database password

## Solution

### 1. Config.toml Updated ✅
Changed to match production:
- `site_url` = `"http://localhost:3000"`
- `additional_redirect_urls` = `[]`
- `enable_confirmations` = `true`
- `max_frequency` = `"1m0s"`

### 2. GitHub Secrets to Add

Go to your repo → Settings → Secrets → Actions and add:

```
# Existing secrets you should have:
SUPABASE_ACCESS_TOKEN
STAGING_PROJECT_REF = dijtowiohxvwdnvgprud
PRODUCTION_PROJECT_REF = zutbqmhxvdgvcllobtxo

# NEW secrets needed:
STAGING_DB_PASSWORD = [your staging database password]
PRODUCTION_DB_PASSWORD = [your production database password]
```

### 3. Get Your Database Passwords

#### Option A: From Supabase Dashboard
1. Go to https://app.supabase.com/project/[PROJECT_REF]/settings/database
2. Find "Connection string" section
3. Your password is shown there (click reveal)

#### Option B: Reset Password
1. Go to https://app.supabase.com/project/[PROJECT_REF]/settings/database
2. Click "Reset database password"
3. Save the new password

### 4. Add to GitHub Secrets

For staging (dijtowiohxvwdnvgprud):
- Name: `STAGING_DB_PASSWORD`
- Value: [your staging password]

For production (zutbqmhxvdgvcllobtxo):
- Name: `PRODUCTION_DB_PASSWORD`
- Value: [your production password]

## After Adding Secrets

1. Commit the config.toml changes:
   ```bash
   git add supabase/config.toml .github/workflows/supabase-deploy.yml
   git commit -m "Fix migration config and add password support"
   git push
   ```

2. The GitHub Action should now work!

## Important Notes

- Database passwords are different from API keys
- Each project has its own database password
- Keep these passwords secure
- The password is only needed for migrations, not for app usage