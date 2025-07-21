# Fix Network Connection Error

## The Issue
The error "no route to host" with IPv6 address means your network can't reach Supabase's database server directly.

## Quick Solutions

### Solution 1: Use Pooler Connection (Recommended)
Instead of direct database connection, use the pooler:

1. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database
2. Click **"Connection pooling"** tab (not "Connection string")
3. Select **"Connection string"** mode
4. Copy the pooler URL that looks like:
   ```
   postgresql://postgres.dijtowiohxvwdnvgprud:[password]@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres
   ```

5. Use it:
   ```bash
   supabase db pull --db-url "postgresql://postgres.dijtowiohxvwdnvgprud:YOUR-PASSWORD@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres"
   ```

### Solution 2: Use Supabase Remote Commit
This method doesn't require direct database connection:

```bash
# Just link the project
supabase link --project-ref dijtowiohxvwdnvgprud

# Create migration from remote without connecting
supabase db remote commit
```

This will create a migration file with your current remote schema!

### Solution 3: Manual Export from Dashboard
If CLI methods fail:

1. Go to SQL Editor: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor
2. Click "New query"
3. Run this to see all tables:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public';
   ```

4. Then export each table definition manually or use the full export query in the alternative script.

### Solution 4: Use a VPN
If your network blocks the connection:
- Try using a VPN
- Or try from a different network
- Or use a cloud-based environment

## For GitHub Actions
Update your secrets to use the pooler URL:
- `STAGING_DATABASE_URL` = Pooler connection string from Connection pooling tab
- `PRODUCTION_DATABASE_URL` = Same for production

The pooler connection is more reliable and works around network restrictions!

## Test Connection
Test if pooler works:
```bash
# Test with pooler URL
psql "postgresql://postgres.dijtowiohxvwdnvgprud:YOUR-PASSWORD@aws-0-ap-northeast-2.pooler.supabase.com:5432/postgres" -c "SELECT 1"
```