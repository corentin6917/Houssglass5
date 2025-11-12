# Supabase Setup Instructions

Complete guide to setting up Supabase infrastructure for Hourglass.

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in:
   - **Name**: Hourglass
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to Europe/Paris (e.g., eu-west-1)
4. Wait for project to initialize (~2 minutes)

## 2. Get Your Credentials

From the Supabase Dashboard:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://xxx.supabase.co`)
   - **Anon/Public Key** (for app)
   - **Service Role Key** (for backend - keep secret!)

3. Go to **Settings** → **Database**
4. Copy:
   - **Connection String** (use Transaction mode)

5. For JWT Secret:
   - Go to **Settings** → **API** → **JWT Settings**
   - Copy **JWT Secret**

## 3. Apply Database Schema

### Option A: Using Supabase CLI (Recommended)

```bash
cd infra/supabase

# Initialize (only first time)
supabase init

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Apply migrations
supabase db push
```

### Option B: Using SQL Editor

1. Go to **SQL Editor** in Supabase Dashboard
2. Create a new query
3. Copy contents of `schema.sql` and run
4. Copy contents of `rls_policies.sql` and run
5. Copy contents of `seed.sql` and run

### Option C: Using psql

```bash
# Get connection string from Supabase Dashboard
export DATABASE_URL="postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co:5432/postgres"

psql $DATABASE_URL < schema.sql
psql $DATABASE_URL < rls_policies.sql
psql $DATABASE_URL < seed.sql
```

## 4. Create Storage Bucket

1. Go to **Storage** in Supabase Dashboard
2. Click "New bucket"
3. Settings:
   - **Name**: `proofs`
   - **Public**: OFF (unchecked)
   - **File size limit**: 10 MB
   - **Allowed MIME types**: `image/jpeg, image/png, image/jpg`

4. Set up bucket policies:

**INSERT Policy (Allow users to upload to their folder)**:
```sql
(bucket_id = 'proofs'::text) AND
((storage.foldername(name))[1] = (auth.uid())::text)
```

**SELECT Policy (Allow users to read their own files)**:
```sql
(bucket_id = 'proofs'::text) AND
((storage.foldername(name))[1] = (auth.uid())::text)
```

**DELETE Policy (Allow system to delete expired files)**:
```sql
(bucket_id = 'proofs'::text)
```

## 5. Deploy Edge Functions

### Install Supabase CLI

```bash
npm install -g supabase
```

### Deploy Functions

```bash
cd infra/supabase

# Login to Supabase
supabase login

# Link project (if not already done)
supabase link --project-ref YOUR_PROJECT_REF

# Deploy morning cron (08:00)
supabase functions deploy cron_08h

# Deploy evening cron (20:00)
supabase functions deploy cron_20h
```

### Set Environment Variables for Edge Functions

```bash
# Set Supabase credentials for Edge Functions
supabase secrets set SUPABASE_URL=https://xxx.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## 6. Set Up Cron Triggers

Edge Functions can be triggered by HTTP requests or cron schedules.

### Option A: Using Supabase Dashboard

1. Go to **Edge Functions** in Dashboard
2. For each function (`cron_08h`, `cron_20h`):
   - Click on the function
   - Go to **Settings** tab
   - Under **Cron Jobs**, add:
     - **cron_08h**: `0 8 * * *` (daily at 08:00 Europe/Paris)
     - **cron_20h**: `0 20 * * *` (daily at 20:00 Europe/Paris)

### Option B: Using External Cron Service

Use services like:
- **Cron-job.org**
- **EasyCron.com**
- **GitHub Actions** (workflows with schedule)

Example GitHub Actions workflow (`.github/workflows/cron.yml`):

```yaml
name: Hourglass Cron Jobs

on:
  schedule:
    - cron: '0 8 * * *'  # 08:00 UTC (adjust for your timezone)
    - cron: '0 20 * * *' # 20:00 UTC

jobs:
  trigger_crons:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Morning Cron
        if: github.event.schedule == '0 8 * * *'
        run: |
          curl -X POST https://xxx.supabase.co/functions/v1/cron_08h \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}"

      - name: Trigger Evening Cron
        if: github.event.schedule == '0 20 * * *'
        run: |
          curl -X POST https://xxx.supabase.co/functions/v1/cron_20h \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_ANON_KEY }}"
```

## 7. Configure Authentication

1. Go to **Authentication** → **Providers** in Supabase Dashboard

2. Enable **Email** provider:
   - Toggle ON
   - Configure email templates (optional):
     - Confirmation email
     - Magic link
     - Password reset

3. (Optional) Enable **OAuth Providers**:
   - **Google**: Add OAuth credentials
   - **Apple**: Add OAuth credentials

4. Configure **Auth Settings**:
   - **Site URL**: Your app URL (e.g., `https://yourdomain.com`)
   - **Redirect URLs**: Add authorized redirect URLs

## 8. Update Environment Files

### Backend (.env)

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[REF].supabase.co:5432/postgres
APP_ENV=development
API_HOST=0.0.0.0
API_PORT=8000
```

### App (.env)

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:8000
ENVIRONMENT=development
```

## 9. Verify Setup

### Test Database Connection

```bash
psql $DATABASE_URL -c "SELECT COUNT(*) FROM users;"
```

### Test Edge Functions

```bash
# Test morning cron
curl -X POST https://xxx.supabase.co/functions/v1/cron_08h \
  -H "Authorization: Bearer YOUR_ANON_KEY"

# Test evening cron
curl -X POST https://xxx.supabase.co/functions/v1/cron_20h \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Test Storage

```bash
# Upload test file
curl -X POST https://xxx.supabase.co/storage/v1/object/proofs/test.jpg \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: image/jpeg" \
  --data-binary "@test.jpg"
```

## 10. Production Checklist

Before going to production:

- [ ] Change database password
- [ ] Rotate service role key
- [ ] Enable RLS on all tables
- [ ] Configure backup schedule
- [ ] Set up monitoring/alerts
- [ ] Enable database replication (paid plan)
- [ ] Configure CDN for storage (optional)
- [ ] Set up custom domain (optional)
- [ ] Enable 2FA on Supabase account
- [ ] Review and test all RLS policies

## Troubleshooting

### Cannot connect to database
- Verify connection string is correct
- Check if IP is whitelisted (Supabase allows all by default)
- Ensure database is not paused (free tier limitation)

### Edge Functions not triggering
- Check function logs in Dashboard → Edge Functions → Logs
- Verify cron syntax
- Ensure secrets are set correctly

### RLS blocking queries
- Check RLS policies in Table Editor → Policy tab
- Test queries as authenticated user in SQL Editor
- Verify JWT token is valid

### Storage uploads failing
- Check bucket permissions
- Verify file size < 10MB
- Ensure MIME type is allowed
- Check if user is authenticated

## Support

- **Supabase Docs**: https://supabase.com/docs
- **Supabase Discord**: https://discord.supabase.com
- **GitHub Issues**: https://github.com/supabase/supabase/issues
