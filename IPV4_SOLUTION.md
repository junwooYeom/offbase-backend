# Solution for IPv4/IPv6 Connection Issues

## Best Solution: Use `supabase db remote commit` (No Connection Required!)

This method doesn't need any database connection:

```bash
# 1. Make sure you have your access token
export SUPABASE_ACCESS_TOKEN=your-token

# 2. Link to your project (no password needed)
supabase link --project-ref dijtowiohxvwdnvgprud

# 3. Pull schema without connecting to database
supabase db remote commit

# This creates a migration file with your entire schema!
```

## Alternative Solutions

### Option 1: Use Transaction Mode (Shared Pooler)
In your Supabase dashboard:
1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database
2. Click **"Connection pooling"** tab
3. Change **Pool Mode** from "Session" to **"Transaction"**
4. This uses the shared pooler which supports IPv4
5. Copy the connection string and use it

### Option 2: Direct Connection with SSL Mode
Sometimes adding SSL parameters helps:
```bash
supabase db pull --db-url "postgresql://postgres:YOUR-PASSWORD@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres?sslmode=require"
```

### Option 3: Manual Migration Creation
1. Create migration file manually:
   ```bash
   supabase migration new initial_schema
   ```

2. Go to SQL Editor: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor

3. Run this query to get your schema:
   ```sql
   -- Get all CREATE statements
   WITH table_ddl AS (
     SELECT 
       'CREATE TABLE ' || schemaname || '.' || tablename || ' (' || chr(10) ||
       array_to_string(
         array_agg(
           '  ' || column_name || ' ' || 
           CASE 
             WHEN data_type = 'character varying' THEN 'varchar(' || character_maximum_length || ')'
             WHEN data_type = 'numeric' THEN 'numeric(' || numeric_precision || ',' || numeric_scale || ')'
             WHEN data_type = 'ARRAY' THEN text(udt_name)
             ELSE data_type
           END ||
           CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
           CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END
           ORDER BY ordinal_position
         ), ',' || chr(10)
       ) || chr(10) || ');' as ddl
     FROM information_schema.columns
     WHERE table_schema = 'public'
     GROUP BY schemaname, tablename
   )
   SELECT ddl FROM table_ddl;
   ```

4. Copy the output and paste into your migration file

## For GitHub Actions

Since the GitHub Actions runners might have better network connectivity, you can:

1. Try the direct connection URL first in GitHub Secrets
2. If that fails, use the transaction mode pooler URL
3. Or use `supabase db remote commit` in the workflow

## Recommended Approach

1. **First try**: `supabase db remote commit` (easiest, no connection needed)
2. **If that fails**: Use manual export from SQL Editor
3. **For GitHub Actions**: Test both direct and pooler URLs

The `remote commit` method is the most reliable since it uses Supabase's API instead of direct database connection!