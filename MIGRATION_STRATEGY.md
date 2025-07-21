# Database Migration Strategy

## Important: Always Use Migration Files

**Never create tables, functions, or triggers directly in the Supabase dashboard!**

### Why Use Migration Files?

1. **Version Control**: Track all database changes in Git
2. **Team Collaboration**: Everyone can see and review schema changes
3. **Reproducibility**: Recreate the exact database structure anywhere
4. **Rollback Capability**: Undo changes if needed
5. **CI/CD Integration**: Automated deployments across environments

### If You Already Have Remote Schema

If you've already created tables/functions in your remote Supabase project, you need to:

1. **Pull the existing schema**:
   ```bash
   # Link to your remote project
   supabase link --project-ref your-project-ref
   
   # Pull remote schema into a migration file
   supabase db pull
   ```

2. **This creates a migration file** with all your existing schema

3. **Commit this migration** to version control

### Going Forward: The Correct Workflow

1. **Never use Supabase Dashboard SQL Editor for schema changes**
2. **Always create migrations locally**:
   ```bash
   supabase migration new your_feature_name
   ```

3. **Write your SQL in the migration file**
4. **Test locally**:
   ```bash
   supabase db reset
   ```

5. **Push to remote**:
   ```bash
   supabase db push
   ```

### Example Workflow

```bash
# 1. Create a new migration
supabase migration new add_posts_table

# 2. Edit the migration file
# supabase/migrations/[timestamp]_add_posts_table.sql

# 3. Test locally
supabase db reset

# 4. Push to remote
supabase db push
```

### What Should Be in Migration Files?

✅ **Everything**:
- Tables
- Indexes
- Functions
- Triggers
- RLS Policies
- Views
- Types
- Extensions

❌ **What NOT to put in migrations**:
- Data (use seed files for test data)
- Secrets or API keys
- Environment-specific configurations

### Best Practices

1. **One feature per migration**: Don't mix unrelated changes
2. **Descriptive names**: `add_user_avatar_column` not `update1`
3. **Include down migrations**: Add DROP statements when possible
4. **Test before pushing**: Always run locally first
5. **Review before merging**: Treat migrations like code

### Fixing Out-of-Sync Issues

If your remote is ahead of local:
```bash
# Pull remote changes
supabase db pull

# This creates a new migration with the differences
# Commit this migration to sync your codebase
```

If local is ahead of remote:
```bash
# See what will change
supabase db diff

# Push local changes
supabase db push
```

### Remember

- **Remote Supabase Dashboard**: For viewing data and testing queries only
- **Migration Files**: For ALL schema changes
- **Version Control**: Your source of truth for database structure