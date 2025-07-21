# Fix Database Password Authentication Issue

## The Problem
The SASL authentication error occurs even with correct passwords. This is a known issue with Supabase CLI and pooled connections.

## Solution 1: Use Database URL Instead (Recommended)

### Get your Database URLs:

1. **Staging Database URL**:
   - Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database
   - Find "Connection string" → "URI"
   - Copy the FULL URL (starts with `postgresql://`)

2. **Production Database URL**:
   - Go to: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/settings/database
   - Find "Connection string" → "URI"
   - Copy the FULL URL

### Add to GitHub Secrets:
- `STAGING_DATABASE_URL` = `postgresql://postgres:[password]@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres`
- `PRODUCTION_DATABASE_URL` = `postgresql://postgres:[password]@db.zutbqmhxvdgvcllobtxo.supabase.co:5432/postgres`

### Use the Simple Workflow:
```bash
# Replace the current workflow
mv .github/workflows/supabase-deploy-simple.yml .github/workflows/supabase-deploy.yml
```

## Solution 2: Pull Schema Locally and Commit

### Step 1: Pull using Database URL
```bash
export SUPABASE_ACCESS_TOKEN=your-token

# Link without password
supabase link --project-ref dijtowiohxvwdnvgprud <<< ""

# Pull using database URL
supabase db pull --db-url "postgresql://postgres:[password]@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres"
```

### Step 2: Commit and Push
```bash
git add supabase/migrations/
git commit -m "Add database migrations"
git push origin main
```

## Solution 3: Manual Schema Export

If automated methods fail:

1. Go to SQL Editor: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor

2. Run this query to get all table definitions:
```sql
-- Get CREATE TABLE statements
SELECT 
    'CREATE TABLE IF NOT EXISTS ' || 
    schemaname || '.' || tablename || ' (' || 
    array_to_string(
        array_agg(
            column_name || ' ' || data_type || 
            CASE 
                WHEN character_maximum_length IS NOT NULL 
                THEN '(' || character_maximum_length || ')' 
                ELSE '' 
            END ||
            CASE 
                WHEN is_nullable = 'NO' 
                THEN ' NOT NULL' 
                ELSE '' 
            END
        ), ', '
    ) || ');'
FROM information_schema.columns
WHERE table_schema = 'public'
GROUP BY schemaname, tablename;
```

3. Export functions and triggers:
```sql
-- Get all functions
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE pronamespace = 'public'::regnamespace;
```

4. Create a migration file manually:
```bash
# Create migration
supabase migration new initial_schema

# Add the exported SQL to the file
# supabase/migrations/[timestamp]_initial_schema.sql
```

## Why This Happens

1. Supabase uses connection pooling (PgBouncer)
2. The pooled connection URL uses different authentication
3. The CLI sometimes has issues with SCRAM authentication

## Quick Fix for GitHub Actions

Use the simple workflow that uses database URLs:
- It skips the password prompt issue
- Uses `--db-url` flag which is more reliable
- Works with both staging and production

## Verification

After deployment, check:
- Tables: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/editor/table-editor
- Functions: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/database/functions
- The deployment should show all your tables and functions from staging