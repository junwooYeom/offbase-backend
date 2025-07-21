# GitHub Secrets Setup

## Required Secrets for Migration Deployment

Add these secrets to your repository:
**Settings → Secrets and variables → Actions → New repository secret**

### 1. Supabase Access Token
- **Name**: `SUPABASE_ACCESS_TOKEN`
- **Value**: Get from https://app.supabase.com/account/tokens
- **Used for**: CLI authentication

### 2. Staging Configuration
- **Name**: `STAGING_PROJECT_REF`
- **Value**: `dijtowiohxvwdnvgprud`
- **Used for**: Identifying staging project

- **Name**: `STAGING_DATABASE_URL`
- **Value**: `postgresql://postgres:[password]@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres`
- **Get from**: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database
- **Look for**: Connection string → URI

### 3. Production Configuration
- **Name**: `PRODUCTION_PROJECT_REF`
- **Value**: `zutbqmhxvdgvcllobtxo`
- **Used for**: Identifying production project

- **Name**: `PRODUCTION_DATABASE_URL`
- **Value**: `postgresql://postgres:[password]@db.zutbqmhxvdgvcllobtxo.supabase.co:5432/postgres`
- **Get from**: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/settings/database
- **Look for**: Connection string → URI

## Important Notes

1. **Database URLs**: Make sure to copy the FULL connection string including the password
2. **No quotes**: Don't wrap the values in quotes when adding to GitHub Secrets
3. **Test locally first**: You can test these URLs locally with:
   ```bash
   supabase db pull --db-url "your-database-url"
   ```

## Verify Setup

After adding all secrets, your Actions secrets page should show:
- ✅ SUPABASE_ACCESS_TOKEN
- ✅ STAGING_PROJECT_REF
- ✅ STAGING_DATABASE_URL
- ✅ PRODUCTION_PROJECT_REF
- ✅ PRODUCTION_DATABASE_URL

## Why Database URLs?

We use database URLs instead of passwords because:
1. More reliable - avoids SASL authentication issues
2. Works consistently across different Supabase CLI versions
3. Single secret instead of multiple credentials
4. Standard PostgreSQL connection format