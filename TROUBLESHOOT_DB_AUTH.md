# Troubleshoot Database Authentication Error

## The SASL Auth Error

This error happens when:
1. Database password is incorrect
2. Password contains special characters that need escaping
3. Using pooler connection instead of direct connection

## Solutions to Try

### 1. Verify Your Database Password

Go to your Supabase dashboard:
- Production: https://app.supabase.com/project/zutbqmhxvdgvcllobtxo/settings/database
- Staging: https://app.supabase.com/project/dijtowiohxvwdnvgprud/settings/database

Look for the "Connection string" section and verify your password.

### 2. Reset Your Database Password

If unsure about the password:
1. Go to Settings → Database
2. Click "Reset database password"
3. Copy the new password IMMEDIATELY (you won't see it again)
4. Update GitHub secret

### 3. Check Password Format

If your password contains special characters like `@`, `$`, `!`, etc.:
- Make sure it's properly escaped in GitHub Secrets
- Try resetting to a simpler password temporarily

### 4. Alternative: Use Database URL

Instead of password, you can use the full database URL:

1. Get the database URL from Supabase dashboard
2. Add as GitHub secret: `PRODUCTION_DATABASE_URL`
3. Update workflow:

```yaml
- name: Deploy to Production
  if: github.ref == 'refs/heads/main'
  run: |
    echo "🚀 Deploying to Production Environment"
    supabase link --project-ref ${{ secrets.PRODUCTION_PROJECT_REF }}
    supabase db push
  env:
    SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
    DATABASE_URL: ${{ secrets.PRODUCTION_DATABASE_URL }}
```

### 5. Manual Test

Test locally first:
```bash
# Try linking manually
supabase link --project-ref zutbqmhxvdgvcllobtxo

# When prompted for password, enter it manually
# If this works, the issue is with how the secret is stored
```

### 6. Debug Mode

Add debug flag to see more details:
```yaml
supabase link --project-ref ${{ secrets.PRODUCTION_PROJECT_REF }} --password "${{ secrets.PRODUCTION_DB_PASSWORD }}" --debug
```

## Common Issues

1. **Wrong password**: Most common issue
2. **Special characters**: Characters like `$` might need escaping
3. **Copy/paste errors**: Extra spaces or newlines
4. **Old password**: Password was changed but secret not updated

## Quick Checklist

- [ ] Reset database password in Supabase
- [ ] Copy password without any extra spaces
- [ ] Update GitHub secret immediately
- [ ] Test locally with `supabase link` first
- [ ] Commit and push to trigger workflow