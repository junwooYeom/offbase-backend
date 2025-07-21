# Supabase Database Branching Strategy

This document outlines the database branching strategy for this project.

## Overview

Supabase supports database branching through migrations and environment separation. Here's how we manage different database states:

## Branch Types

### 1. Development Branch (Local)
- Uses local Supabase instance
- Migrations are tested here first
- Run with: `supabase start`

### 2. Staging Branch
- Separate Supabase project for staging
- Mirrors production schema
- Used for pre-production testing

### 3. Production Branch
- Main Supabase project
- Only tested migrations are applied

## Workflow

### Creating a New Feature Branch

1. **Start local Supabase**:
   ```bash
   supabase start
   ```

2. **Create a new migration**:
   ```bash
   supabase migration new feature_name
   ```

3. **Edit the migration file** in `supabase/migrations/`

4. **Apply the migration locally**:
   ```bash
   supabase db reset
   ```

### Testing Migrations

1. **Run migration locally**:
   ```bash
   supabase migration up
   ```

2. **Verify changes**:
   ```bash
   supabase db diff
   ```

3. **Create seed data** if needed in `supabase/seed.sql`

### Deploying to Different Environments

#### To Staging:
```bash
supabase link --project-ref your-staging-project-id
supabase db push
```

#### To Production:
```bash
supabase link --project-ref your-production-project-id
supabase db push
```

## Environment Variables

Create `.env.local` for local development:
```
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-key
```

## Best Practices

1. **Always test migrations locally first**
2. **Use descriptive migration names**
3. **Include rollback statements in migrations**
4. **Never edit existing migrations that have been deployed**
5. **Use `supabase db diff` to verify changes before pushing**

## Migration Naming Convention

Format: `YYYYMMDDHHMMSS_descriptive_name.sql`

Examples:
- `20240721120000_create_users_table.sql`
- `20240721130000_add_email_to_users.sql`

## Branching Commands Reference

### Local Development
```bash
# Start local Supabase
supabase start

# Stop local Supabase
supabase stop

# Reset database (reapply all migrations)
supabase db reset

# Create new migration
supabase migration new <name>

# Apply migrations
supabase migration up

# Check migration status
supabase migration list
```

### Remote Management
```bash
# Link to remote project
supabase link --project-ref <project-id>

# Push local migrations to remote
supabase db push

# Pull remote schema changes
supabase db pull

# Show diff between local and remote
supabase db diff
```