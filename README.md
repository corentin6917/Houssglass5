# HOURGLASS MVP

**Turn your daily victories into golden grains.**

HOURGLASS is a cross-platform mobile app (iOS/Android) that gamifies daily accomplishments. Each morning you get 10 white grains of potential. Set 1-3 goals, complete them with photo proof, and at 20:00 they transform into golden grains that accumulate in your personal hourglass.

## 🎯 Core Mechanics

- **08:00**: Receive 10 white grains (potential). Set 1-3 daily goals with auto-evaluation.
- **Throughout the day**: Complete goals, capture photo proof (ephemeral, 24h).
- **20:00**: Global sync → completed goals become golden grains, incomplete ones evaporate.
- **Victory Feed**: See others' accomplishments for 24h (no public scores, privacy-first).
- **Phoenix Mode**: Auto-activated during difficult periods (3x multiplier on micro-victories).
- **Life Seasons**: Winter/Spring/Summer/Autumn based on 30-day averages.
- **Life Ratio**: `(total_grains / (days × 10)) × 100`

## 🏗️ Project Structure

```
Houssglass5/
├── app/                    # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # Constants, theme, routing, env
│   │   ├── data/          # Models, services, Supabase
│   │   ├── logic/         # Riverpod providers & state
│   │   └── ui/            # Widgets & screens
│   ├── pubspec.yaml
│   ├── .env.example
│   └── README.md
├── backend/               # Python FastAPI server
│   ├── app/
│   │   ├── api/          # Endpoints (goals, social, sync)
│   │   ├── core/         # Config, DB, auth
│   │   ├── models/       # Pydantic models
│   │   └── services/     # Business logic
│   ├── requirements.txt
│   ├── .env.example
│   └── README.md
├── infra/                 # Supabase infrastructure
│   └── supabase/
│       ├── schema.sql          # Database tables
│       ├── rls_policies.sql    # Row-level security
│       ├── seed.sql            # Demo data
│       └── edge_functions/     # Cron jobs (08h, 20h)
├── ops/                   # DevOps scripts
│   ├── Makefile
│   └── scripts/
│       ├── bootstrap.sh        # Setup everything
│       └── run_dev.sh          # Start dev servers
└── README.md              # This file
```

## 🚀 Quick Start

### Prerequisites

- **Flutter**: 3.2+ ([Install](https://docs.flutter.dev/get-started/install))
- **Python**: 3.10+ with pip
- **Supabase CLI**: ([Install](https://supabase.com/docs/guides/cli))
- **Node.js**: 18+ (for Edge Functions)
- **Supabase Account**: [supabase.com](https://supabase.com)

### 1. Clone and Setup

```bash
cd Houssglass5

# Run bootstrap script (installs deps, sets up env)
chmod +x ops/scripts/bootstrap.sh
./ops/scripts/bootstrap.sh
```

### 2. Configure Supabase

```bash
cd infra/supabase

# Initialize Supabase project
supabase init

# Link to your project (get project ID from dashboard)
supabase link --project-ref YOUR_PROJECT_REF

# Apply schema
supabase db push

# Apply RLS policies
psql YOUR_DATABASE_URL < rls_policies.sql

# Seed demo data
psql YOUR_DATABASE_URL < seed.sql

# Deploy Edge Functions
supabase functions deploy cron_08h
supabase functions deploy cron_20h

# Set up cron triggers (Europe/Paris timezone)
# Go to Supabase Dashboard → Edge Functions → Add Cron
# cron_08h: "0 8 * * *" (daily at 08:00)
# cron_20h: "0 20 * * *" (daily at 20:00)
```

### 3. Configure Environment Variables

**Backend** (`backend/.env`):
```bash
cp backend/.env.example backend/.env
# Edit with your Supabase credentials
```

**App** (`app/.env`):
```bash
cp app/.env.example app/.env
# Edit with your Supabase credentials
```

### 4. Run the App

**Option A: Use run script**
```bash
chmod +x ops/scripts/run_dev.sh
./ops/scripts/run_dev.sh
```

**Option B: Manual**

Terminal 1 - Backend:
```bash
cd backend
python -m venv .venv
source .venv/bin/activate  # Or: .venv\Scripts\activate on Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Terminal 2 - Flutter App:
```bash
cd app
flutter pub get
flutter run
# Or for specific device:
# flutter run -d chrome     # Web
# flutter run -d iPhone     # iOS Simulator
# flutter run -d android    # Android Emulator
```

## 📱 App Features Implemented

### Authentication
- Email/password signup & login via Supabase Auth
- Auto-redirect based on auth state

### Morning Contract (08:00)
- Create 1-3 daily goals
- Auto-evaluation with keyword matching
- Devaluation phases (Days 1-30: 100%, 31-90: 80%, 91-180: 60%, 181+: 50%)

### Proof Capture
- Camera integration
- Image compression
- Upload to Supabase Storage with 24h TTL
- Signed URLs for privacy

### Evening Sync (20:00)
- Automatic grain calculation
- Golden descent animation
- Evaporation of incomplete goals
- Feed item creation

### Victory Feed
- 24h visibility window
- No public scores
- Privacy controls (hide from feed, anonymous mode)
- Boosts (Éclats): 0.2 grain cost
- Transfusions: 1 grain from heritage
- Comments: 0.1 grain cost

### Profile & Hourglass
- Visual hourglass widget (white grains top, golden bottom)
- Life Ratio display
- Days on app counter
- Grain history

### Phoenix Mode
- Auto-detection (<3 grains/day ×14d, ratio -10%/month, no victories ×14d)
- 3x multiplier on micro-victories
- Minimum 1 grain/day guarantee
- SOS button (links to resources)

### Life Seasons
- Winter (<4 grains/day avg)
- Spring (4-5)
- Summer (>7)
- Autumn (5-7)
- Seasonal UI colors and messaging

## 🔐 Privacy & Security

- **Row-Level Security (RLS)**: Users can only access their own data
- **No Public Rankings**: Scores are never displayed publicly
- **Feed Privacy**: Users can opt out of feed visibility
- **Proof Expiration**: Photos auto-delete after 24h
- **No Grain Purchases**: Anti-pay-to-win design
- **Signed URLs**: Temporary access to uploaded photos

## 🧪 Testing

```bash
# Backend tests
cd backend
pytest

# Flutter tests
cd app
flutter test
```

## 📊 Database Schema

### Core Tables
- `users`: User accounts (linked to Supabase Auth)
- `profiles`: User stats (ratio, total_grains, days_on_app)
- `daily_contracts`: Daily grain potential (10 white grains)
- `goals`: User's goal library
- `daily_goals`: Goals for specific days
- `grains_ledger`: All grain transactions
- `feed_items`: Victory feed posts (24h visibility)

### Social Tables
- `boosts`: Éclats de Grain (0.2 grain gifts)
- `transfusions`: Heritage transfers (1 grain)
- `comments`: Feed comments (0.1 grain cost)

### Seasonal Tables
- `seasons`: Life season history
- `phoenix_states`: Phoenix mode activations

See [infra/supabase/schema.sql](infra/supabase/schema.sql) for full schema.

## 🎨 Design System

### Colors
- **Golden Grain**: `#FFD700` (primary)
- **White Grain**: `#FFFAFA` (potential)
- **Dark Background**: `#1A1A1A`
- **Phoenix Orange**: `#FF6B35`
- **SOS Red**: `#FF4444`

### Seasons
- **Winter**: `#4A90E2` ❄️
- **Spring**: `#7CB342` 🌱
- **Summer**: `#FFD54F` ☀️
- **Autumn**: `#FF8A65` 🍂

### Typography
- Font: Poppins (Regular, Medium, SemiBold, Bold)

## 🔧 Configuration

### Grain Mechanics
- Daily potential: 10 grains
- Boost cost: 0.2 grains
- Transfusion: 1 grain
- Comment cost: 0.1 grains
- Phoenix multiplier: 3x
- Phoenix minimum: 1 grain/day

### Timings (Europe/Paris)
- Morning reset: 08:00
- Evening sync: 20:00
- Feed visibility: 24 hours
- Proof expiration: 24 hours

### Devaluation Phases
- Phase 1 (Days 1-30): 100%
- Phase 2 (Days 31-90): 80%
- Phase 3 (Days 91-180): 60%
- Phase 4 (Days 181+): 50% (floor)

## 🚧 Roadmap (Post-MVP)

### Near-term
- [ ] Push notifications (08:00, 20:00, boosts)
- [ ] Apple Sign-In / Google Sign-In
- [ ] Pacts (couples, friends, legions)
- [ ] Capsules (100-day video montages)
- [ ] Advanced AI goal evaluation (LLM integration)

### Long-term
- [ ] Apple Watch companion app
- [ ] Widgets (iOS/Android home screen)
- [ ] Siri/Google Assistant shortcuts
- [ ] Web dashboard (read-only)
- [ ] Export data (GDPR compliance)
- [ ] Multi-language support

## 📄 License

Proprietary - All rights reserved.

---

**Built with ❤️ for meaningful daily progress**

*Last updated: 2025-01-12*