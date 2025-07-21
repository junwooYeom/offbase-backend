# How to Get the Correct Database URL

## ❌ Wrong URL Format
```
https://dijtowiohxvwdnvgprud.supabase.co  # This is the API URL, NOT the database URL!
```

## ✅ Correct Database URL Format
```
postgresql://postgres:[password]@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres
```

## Step-by-Step Guide

### 1. Go to Supabase Dashboard
- Staging: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database
- Production: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/settings/database

### 2. Find Connection String Section
Look for "Connection string" (not "Connection pooling")

### 3. Select "URI" Tab
You'll see something like:
```
postgresql://postgres:[YOUR-PASSWORD]@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres
```

### 4. Copy the ENTIRE String
- Click the "Copy" button
- Or reveal the password first, then copy

## Visual Guide

In the Supabase Dashboard:
```
Settings → Database → Connection string

[Pooler] [Transaction] [Session] [URI] ← Click URI tab!
                                   ^^^

postgresql://postgres:your-actual-password@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Copy this entire string!
```

## Test Your URL

```bash
# Test with the correct format
supabase db pull --db-url "postgresql://postgres:YOUR-PASSWORD@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres"
```

## Common Mistakes

❌ Using the project URL: `https://dijtowiohxvwdnvgprud.supabase.co`
❌ Using the pooler URL: `postgresql://postgres.dijtowiohxvwdnvgprud@aws-0-ap-northeast-2.pooler.supabase.com`
❌ Missing the password: `postgresql://postgres@db.dijtowiohxvwdnvgprud.supabase.co`

✅ Use the direct connection URI with password included!

## For GitHub Secrets

When you add to GitHub Secrets:
- Name: `STAGING_DATABASE_URL`
- Value: `postgresql://postgres:your-password@db.dijtowiohxvwdnvgprud.supabase.co:5432/postgres`

Make sure:
- No quotes around the value
- Password is included
- Starts with `postgresql://` not `https://`