# Getting Started with Hourglass MVP

Complete step-by-step guide to get the Hourglass app running on your machine.

## ⚡ Quick Start (5 minutes)

```bash
# 1. Run the bootstrap script
chmod +x ops/scripts/bootstrap.sh
./ops/scripts/bootstrap.sh

# 2. Set up Supabase (see detailed instructions below)

# 3. Update environment files
# Edit app/.env and backend/.env with your Supabase credentials

# 4. Run the app
chmod +x ops/scripts/run_dev.sh
./ops/scripts/run_dev.sh
```

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required

- ✅ **Flutter SDK 3.2+**
  - Download: https://docs.flutter.dev/get-started/install
  - Verify: `flutter doctor`

- ✅ **Python 3.10+**
  - Download: https://www.python.org/downloads/
  - Verify: `python3 --version`

- ✅ **Supabase Account**
  - Sign up: https://supabase.com

### Optional (but recommended)

- **Node.js 18+** (for Supabase Edge Functions)
  - Download: https://nodejs.org/

- **Supabase CLI**
  ```bash
  npm install -g supabase
  ```

- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **Visual Studio Code** (recommended IDE)

## 🔧 Step-by-Step Setup

### Step 1: Install Dependencies

#### macOS
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Flutter
brew install --cask flutter

# Install Python
brew install python@3.10

# Install Node.js
brew install node

# Install Supabase CLI
npm install -g supabase
```

#### Windows
```powershell
# Install Flutter: Download from flutter.dev
# Install Python: Download from python.org
# Install Node.js: Download from nodejs.org

# Install Supabase CLI (PowerShell as Administrator)
npm install -g supabase
```

#### Linux
```bash
# Install Flutter (snap)
sudo snap install flutter --classic

# Install Python
sudo apt install python3.10 python3-pip

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# Install Supabase CLI
npm install -g supabase
```

### Step 2: Clone and Bootstrap

```bash
cd Houssglass5

# Run bootstrap script
chmod +x ops/scripts/bootstrap.sh
./ops/scripts/bootstrap.sh
```

This script will:
- ✅ Check prerequisites
- ✅ Install Flutter dependencies
- ✅ Create Python virtual environment
- ✅ Install Python dependencies
- ✅ Create `.env` files from templates

### Step 3: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project

2. Note these values from **Settings → API**:
   - Project URL: `https://xxx.supabase.co`
   - Anon key (public)
   - Service role key (secret)

3. Note these from **Settings → Database**:
   - Connection string

4. Note from **Settings → API → JWT Settings**:
   - JWT Secret

### Step 4: Apply Database Schema

Choose one method:

#### Method A: Supabase CLI (Recommended)
```bash
cd infra/supabase

# Login and link
supabase login
supabase link --project-ref YOUR_PROJECT_REF

# Apply all migrations
supabase db push

# Or manually:
psql "YOUR_DATABASE_URL" < schema.sql
psql "YOUR_DATABASE_URL" < rls_policies.sql
psql "YOUR_DATABASE_URL" < seed.sql
```

#### Method B: SQL Editor (Web)
1. Go to Supabase Dashboard → SQL Editor
2. Copy/paste contents of:
   - `infra/supabase/schema.sql` → Run
   - `infra/supabase/rls_policies.sql` → Run
   - `infra/supabase/seed.sql` → Run

### Step 5: Create Storage Bucket

In Supabase Dashboard:

1. Go to **Storage** → New bucket
2. Name: `proofs`
3. **Public**: OFF (uncheck)
4. File size limit: 10 MB
5. Allowed types: `image/jpeg, image/png`

6. Add policies:
   ```sql
   -- Upload policy
   (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)

   -- Read policy
   (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)
   ```

### Step 6: Deploy Edge Functions

```bash
cd infra/supabase

# Deploy functions
supabase functions deploy cron_08h
supabase functions deploy cron_20h

# Set secrets
supabase secrets set SUPABASE_URL="https://xxx.supabase.co"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="your-key"
```

### Step 7: Configure Environment Files

#### Backend `.env`
```bash
cd backend
nano .env  # or use your favorite editor
```

Update with your values:
```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-service-role-key
SUPABASE_JWT_SECRET=your-jwt-secret
DATABASE_URL=postgresql://postgres:password@db.xxx.supabase.co:5432/postgres
APP_ENV=development
API_HOST=0.0.0.0
API_PORT=8000
```

#### App `.env`
```bash
cd ../app
nano .env
```

Update:
```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:8000
ENVIRONMENT=development
```

### Step 8: Start Development Servers

```bash
# From project root
./ops/scripts/run_dev.sh
```

This will:
1. Start backend API on http://localhost:8000
2. Start Flutter app on selected device

Or start manually:

**Terminal 1 - Backend:**
```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload
```

**Terminal 2 - App:**
```bash
cd app
flutter run
# Or specify device:
flutter run -d chrome
flutter run -d iPhone
flutter run -d android
```

## ✅ Verify Everything Works

### 1. Check Backend API
```bash
curl http://localhost:8000/health
# Expected: {"status":"healthy"}
```

### 2. Check API Documentation
Open in browser: http://localhost:8000/docs

### 3. Test Database Connection
```bash
psql "YOUR_DATABASE_URL" -c "SELECT COUNT(*) FROM users;"
# Expected: count of demo users (3)
```

### 4. Test App
1. Open app on device/simulator
2. Sign up with test email
3. Create morning contract
4. Navigate through screens

## 🐛 Common Issues & Solutions

### Issue: "Flutter not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: "Python venv activation fails"
```bash
# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate
```

### Issue: "Cannot connect to Supabase"
- Verify `.env` files have correct credentials
- Check if project is paused (free tier)
- Ensure anon key (not service role) is in app `.env`

### Issue: "RLS blocks all queries"
- Check if RLS policies are applied
- Verify JWT token is being sent
- Test with service role key temporarily (debug only)

### Issue: "Storage upload fails"
- Verify bucket `proofs` exists
- Check bucket policies are set
- Ensure file size < 10MB

### Issue: "Edge Functions don't deploy"
```bash
# Login again
supabase login

# Re-link project
supabase link --project-ref YOUR_REF

# Try deploy again
supabase functions deploy cron_08h --no-verify-jwt
```

## 🎯 What to Do Next

### Explore the App
1. ✅ Sign up as a new user
2. ✅ Set 3 morning goals
3. ✅ Capture proof photos
4. ✅ View victory feed
5. ✅ Send a boost to demo user
6. ✅ Check your hourglass and ratio

### Test Backend APIs
Visit http://localhost:8000/docs and try:
- `POST /api/goals/evaluate` - Auto-evaluate goals
- `POST /api/social/boost` - Send a boost

### Customize
- Update colors in `app/lib/core/theme.dart`
- Modify grain values in `app/lib/core/constants.dart`
- Add new goal keywords in `backend/app/services/auto_valuation.py`

### Set Up Cron Triggers
Configure Edge Functions to run automatically:
- Go to Supabase Dashboard → Edge Functions
- Add cron schedule:
  - `cron_08h`: `0 8 * * *`
  - `cron_20h`: `0 20 * * *`

## 📚 Additional Resources

- **Main README**: [README.md](README.md)
- **Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Supabase Setup**: [infra/supabase_instructions.md](infra/supabase_instructions.md)
- **App README**: [app/README.md](app/README.md)
- **Backend README**: [backend/README.md](backend/README.md)

## 🆘 Getting Help

1. **Check Documentation**: Review the files above
2. **Search Issues**: Common problems may already be documented
3. **Check Logs**:
   - Backend: Terminal output
   - App: Flutter console
   - Edge Functions: Supabase Dashboard → Functions → Logs
   - Database: Supabase Dashboard → Database → Query logs

## 🎉 Success Checklist

- [ ] Flutter app launches
- [ ] Backend API responds to /health
- [ ] Database connection works
- [ ] Can sign up new user
- [ ] Can create morning contract
- [ ] Storage bucket accepts uploads
- [ ] Victory feed displays items
- [ ] Edge Functions can be triggered

If all checkboxes are complete, you're ready to start developing!

---

**Welcome to Hourglass! Turn your victories into golden grains. 🏆⏳**
