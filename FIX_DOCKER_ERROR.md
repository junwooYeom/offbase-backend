# Fix Docker Error for Supabase

## The Issue
Supabase CLI requires Docker for local development, but Docker isn't running.

## Solution 1: Start Docker Desktop (If Installed)

1. **Check if Docker Desktop is installed**:
   ```bash
   ls /Applications | grep Docker
   ```

2. **Start Docker Desktop**:
   - Open Docker Desktop from Applications
   - Or from terminal: `open -a Docker`
   - Wait for Docker to start (icon in menu bar turns green)

3. **Verify Docker is running**:
   ```bash
   docker ps
   ```

## Solution 2: Install Docker Desktop (If Not Installed)

```bash
# Install via Homebrew
brew install --cask docker

# Or download from: https://www.docker.com/products/docker-desktop
```

## Solution 3: Pull Schema Without Docker (Recommended for Now)

Since we only need to pull the schema (not run local Supabase), we can bypass Docker:

### Method A: Direct from Supabase Dashboard

1. **Go to SQL Editor**: 
   https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor

2. **Run this query to export all tables**:
   ```sql
   -- Export complete schema
   SELECT 
     'CREATE TABLE IF NOT EXISTS ' || schemaname || '.' || tablename || E' (\n' ||
     string_agg(
       '  ' || column_name || ' ' || 
       CASE 
         WHEN data_type = 'character varying' THEN 'VARCHAR(' || character_maximum_length || ')'
         WHEN data_type = 'character' THEN 'CHAR(' || character_maximum_length || ')'
         WHEN data_type = 'numeric' THEN 'NUMERIC(' || numeric_precision || ',' || numeric_scale || ')'
         WHEN data_type = 'timestamp without time zone' THEN 'TIMESTAMP'
         WHEN data_type = 'timestamp with time zone' THEN 'TIMESTAMPTZ'
         WHEN data_type = 'USER-DEFINED' THEN udt_name
         ELSE UPPER(data_type)
       END ||
       CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
       CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END,
       E',\n' ORDER BY ordinal_position
     ) || E'\n);'
   FROM information_schema.columns
   WHERE table_schema = 'public'
   GROUP BY schemaname, tablename
   ORDER BY tablename;
   ```

3. **Create migration file manually**:
   ```bash
   # Create timestamp
   TIMESTAMP=$(date +%Y%m%d%H%M%S)
   
   # Create migration file
   touch supabase/migrations/${TIMESTAMP}_initial_schema.sql
   
   # Open it and paste the exported SQL
   ```

### Method B: Use Supabase CLI Without Local Features

```bash
# This might work without Docker for some commands
supabase db dump --db-url "postgresql://postgres:PASSWORD@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres" -f supabase/migrations/initial.sql
```

## Solution 4: Use GitHub Codespaces or Cloud IDE

If Docker is problematic locally, use a cloud environment:
- GitHub Codespaces
- Gitpod
- Google Cloud Shell

These have Docker pre-installed.

## For Your Current Situation

Since you just need the schema for migrations:

1. **Export from Dashboard** (easiest)
2. **Create migration file manually**
3. **Commit and push**
4. **GitHub Actions will deploy** (doesn't need local Docker)

## Quick Manual Export Steps

1. Create migration file:
   ```bash
   mkdir -p supabase/migrations
   echo "-- Initial schema from staging" > supabase/migrations/$(date +%Y%m%d%H%M%S)_initial_schema.sql
   ```

2. Go to: https://app.supabase.com/project/dijtowiohxvwdnvgprud/editor

3. Click "Export" button in the dashboard

4. Copy the schema and paste into your migration file

5. Commit and push!

This bypasses all Docker and connection issues!