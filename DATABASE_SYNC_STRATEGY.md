# Database Sync Strategy

## Goal
Keep staging (dijtowiohxvwdnvgprud) and production (zutbqmhxvdgvcllobtxo) databases with identical:
- Tables & Columns
- Functions
- Triggers
- Indexes
- RLS Policies
- Views

## Strategy

### 1. Single Source of Truth
- All schema changes go through migration files
- Never modify databases directly
- Migration files are version controlled

### 2. Deployment Flow
```
Local Development → Migration Files → Staging → Production
```

### 3. Automated Sync Process

#### Step 1: Initial Setup (One Time)
1. Export complete schema from staging
2. Create initial migration file
3. Apply to production

#### Step 2: Ongoing Changes
1. Create new migration files for changes
2. Deploy to staging first (develop branch)
3. Test thoroughly
4. Deploy to production (main branch)

## Implementation

### Initial Sync (Do This First)

1. **Export Staging Schema**
   ```bash
   # This gets EVERYTHING from staging
   ./scripts/export-complete-schema.sh
   ```

2. **Apply to Production**
   ```bash
   # Push to main branch
   git push origin main
   ```

### Future Changes

1. **Create Migration**
   ```bash
   supabase migration new feature_name
   ```

2. **Deploy via Git**
   - Push to `develop` → Deploys to staging
   - Push to `main` → Deploys to production

## Verification

### Check Schema Match
```sql
-- Run on both databases and compare
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;
```

### Check Functions Match
```sql
-- Run on both databases
SELECT 
    proname as function_name,
    prosrc as function_source
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public';
```

### Check Triggers Match
```sql
-- Run on both databases
SELECT 
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

## CI/CD Workflow

### GitHub Actions Flow
1. **Validate** - Check migration files exist
2. **Test** - Apply to staging first
3. **Compare** - Verify staging matches expected
4. **Deploy** - Apply to production
5. **Verify** - Confirm production matches staging

### Safety Measures
- Staging deployment on develop branch
- Production deployment on main branch
- Automatic backups before production deploy
- Schema comparison after deploy

## Best Practices

1. **Always use migrations**
   - Never use SQL Editor for schema changes
   - All changes through migration files

2. **Test on staging first**
   - Deploy to develop branch
   - Verify everything works
   - Then merge to main

3. **Keep migrations small**
   - One feature per migration
   - Easier to debug
   - Easier to rollback

4. **Document changes**
   - Comment your migrations
   - Explain why changes are made
   - Include rollback instructions