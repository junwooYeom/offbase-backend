# Environment Configuration

## Current Setup

### Staging (develop branch)
- **URL**: https://dijtowiohxvwdnvgprud.supabase.co
- **Project Ref**: dijtowiohxvwdnvgprud
- **Status**: Currently has all implementations

### Production (main branch)
- **URL**: https://zutbqmhxvdgvcllobtxo.supabase.co
- **Project Ref**: zutbqmhxvdgvcllobtxo
- **Status**: Needs schema migration from staging

## Migration Steps

1. **Run the migration script**:
   ```bash
   ./scripts/migrate-staging-to-production.sh
   ```
   This will:
   - Pull schema from staging (dijtowiohxvwdnvgprud)
   - Push schema to production (zutbqmhxvdgvcllobtxo)

2. **Update GitHub Secrets**:
   Go to Settings → Secrets → Actions and add:
   - `SUPABASE_ACCESS_TOKEN` (from https://app.supabase.com/account/tokens)
   - `STAGING_PROJECT_REF` = `dijtowiohxvwdnvgprud`
   - `PRODUCTION_PROJECT_REF` = `zutbqmhxvdgvcllobtxo`

3. **Create .env.local**:
   ```bash
   # Staging
   STAGING_PROJECT_REF=dijtowiohxvwdnvgprud
   STAGING_SUPABASE_URL=https://dijtowiohxvwdnvgprud.supabase.co
   STAGING_SUPABASE_ANON_KEY=<get from staging dashboard>
   STAGING_SUPABASE_SERVICE_ROLE_KEY=<get from staging dashboard>

   # Production
   PRODUCTION_PROJECT_REF=zutbqmhxvdgvcllobtxo
   PRODUCTION_SUPABASE_URL=https://zutbqmhxvdgvcllobtxo.supabase.co
   PRODUCTION_SUPABASE_ANON_KEY=<get from production dashboard>
   PRODUCTION_SUPABASE_SERVICE_ROLE_KEY=<get from production dashboard>

   # CLI Token
   SUPABASE_ACCESS_TOKEN=<get from account/tokens>
   ```

## Getting API Keys

### Staging Keys:
- Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/api
- Copy: anon key and service_role key

### Production Keys:
- Go to: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/settings/api
- Copy: anon key and service_role key

## Workflow After Migration

1. **Feature Development**:
   - Work on `develop` branch
   - Pushes deploy to staging automatically

2. **Production Release**:
   - Merge `develop` → `main`
   - Pushes deploy to production automatically

## Quick Commands

```bash
# Switch to staging
supabase link --project-ref dijtowiohxvwdnvgprud

# Switch to production
supabase link --project-ref zutbqmhxvdgvcllobtxo

# Use the helper script
./scripts/switch-env.sh
```