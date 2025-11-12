# Hourglass Architecture

Technical architecture documentation for the Hourglass MVP.

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                       Mobile App (Flutter)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UI Layer   │  │ Logic Layer  │  │  Data Layer  │      │
│  │  (Screens)   │→│  (Riverpod)  │→│  (Services)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────────┬────────────────────────────────┘
                             │ HTTPS
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Backend                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Auth Service (JWT)                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database (with RLS)                       │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Storage (Proof Photos - 24h TTL)                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Edge Functions (Cron 08h/20h)                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ HTTP
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                  FastAPI Backend (Python)                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  /api/goals/evaluate  - Auto-valuation               │  │
│  │  /api/goals/devaluate - Devaluation logic            │  │
│  │  /api/social/boost    - Boosts                       │  │
│  │  /api/social/transfusion - Transfusions              │  │
│  │  /api/social/comment  - Comments                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### Morning Contract (08:00)

1. **Edge Function**: `cron_08h` creates daily contracts
   - Inserts row into `daily_contracts` table (status: open)
   - Represents 10 white grains potential

2. **User**: Opens app, sees "Set Goals" prompt

3. **App → Backend**: POST `/api/goals/evaluate`
   - Sends 1-3 goal titles
   - Backend returns auto-evaluated grain values (totaling 10)

4. **App → Supabase**: Inserts `daily_goals`
   - Stores goal + assigned value + phase

### Throughout the Day

1. **User**: Completes goal, taps "Capture Proof"

2. **App**:
   - Takes photo with camera
   - Compresses image locally
   - Uploads to Supabase Storage (`proofs` bucket)
   - Updates `daily_goals` with `proof_url` and `completed_at`

### Evening Sync (20:00)

1. **Edge Function**: `cron_20h` orchestrates sync

2. **For each open contract**:
   - Calculate grains earned (completed goals)
   - Calculate grains evaporated (incomplete goals)
   - Insert into `grains_ledger`:
     - Type `earn` for completed
     - Type `evaporate` for incomplete
   - Create `feed_items` for completed goals:
     - visible_from: NOW()
     - expires_at: NOW() + 24h
   - Update `daily_contracts` status to `synced`
   - Update `profiles` with new total_grains and ratio

3. **Purge expired content**:
   - Delete `feed_items` where `expires_at < NOW() - 24h`
   - Delete photos from Storage bucket

### Victory Feed

1. **App → Supabase**: Query `feed_items`
   - WHERE visible_from <= NOW()
   - AND expires_at >= NOW()
   - RLS filters based on privacy settings

2. **Interactions**:
   - **Boost**: Deduct 0.2 from sender daily reserve, credit 0.2 to receiver
   - **Transfusion**: Deduct 1.0 from sender heritage, credit 1.0 to receiver heritage
   - **Comment**: Deduct 0.1 from sender, insert into `comments`

## Security Model

### Authentication

- **Supabase Auth**: Handles user signup/login
- **JWT Tokens**: Issued on successful auth
- **App**: Stores token securely (Flutter Secure Storage)
- **Backend**: Verifies JWT signature using Supabase JWT secret

### Authorization (Row-Level Security)

All database tables have RLS enabled:

```sql
-- Example: Users can only see their own contracts
CREATE POLICY "Users can view own contracts"
    ON daily_contracts FOR SELECT
    USING (auth.uid() = user_id);
```

**Key RLS Policies**:
- Users can read/write their own data
- Feed items visible if not expired + not hidden by privacy settings
- Storage: users can upload/read files in their own folder

### Privacy Features

1. **No Public Scores**: Feed items don't show grain values
2. **Privacy Flags**:
   - `privacy_hide_from_feed`: Opt out of Victory Feed
   - `privacy_anonymous`: Hide display name
3. **Ephemeral Proofs**: Photos auto-delete after 24h
4. **Signed URLs**: Temporary access (1 day) to uploaded photos

## State Management (Flutter)

### Riverpod Architecture

```dart
// Provider for user profile
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final userId = SupabaseService.currentUserId;
  return await SupabaseService.getUserProfile(userId);
});

// Provider for today's contract
final todayContractProvider = FutureProvider<DailyContract?>((ref) async {
  return await SupabaseService.getTodayContract();
});

// Provider for victory feed
final victoryFeedProvider = FutureProvider<List<FeedItem>>((ref) async {
  return await SupabaseService.getVictoryFeed(limit: 50);
});
```

**State Flow**:
1. UI → reads from Provider
2. Provider → calls SupabaseService
3. SupabaseService → makes API call / DB query
4. Provider → caches result
5. UI → rebuilds with new data

## Database Schema Highlights

### Grain Accounting

All grain movements tracked in `grains_ledger`:

```sql
CREATE TABLE grains_ledger (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    type TEXT NOT NULL,  -- earn, evaporate, boost_in, boost_out, etc.
    amount DECIMAL(10,2),
    ref_id UUID,  -- Reference to related entity
    created_at TIMESTAMPTZ
);
```

**Grain Types**:
- `earn`: Completed goal
- `evaporate`: Incomplete goal
- `boost_in`: Received boost
- `boost_out`: Sent boost
- `transfusion_in`: Received transfusion
- `transfusion_out`: Sent transfusion
- `comment_cost`: Posted comment

### Devaluation Tracking

Goals track usage history for devaluation:

```sql
CREATE TABLE goals (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    title TEXT,
    base_value DECIMAL(4,2),
    last_used_at TIMESTAMPTZ,
    repeat_count INTEGER DEFAULT 0
);

CREATE TABLE daily_goals (
    id UUID PRIMARY KEY,
    contract_id UUID NOT NULL,
    goal_id UUID NOT NULL,
    assigned_value DECIMAL(4,2),
    phase INTEGER DEFAULT 1  -- Devaluation phase (1-4)
);
```

**Devaluation Logic**:
1. When goal reused, calculate days since `last_used_at`
2. Determine phase (1-4) based on days
3. Apply multiplier: 1.0, 0.8, 0.6, 0.5
4. Store final value in `daily_goals.assigned_value`

## Performance Optimizations

### Indexes

Key indexes for query performance:

```sql
CREATE INDEX idx_daily_contracts_user_date ON daily_contracts(user_id, date DESC);
CREATE INDEX idx_grains_ledger_user ON grains_ledger(user_id, created_at DESC);
CREATE INDEX idx_feed_items_visible ON feed_items(visible_from, expires_at);
```

### Caching Strategy

1. **App-level**: Riverpod caches provider results
2. **Database-level**: PostgreSQL query cache
3. **Storage**: CDN for frequently accessed images (optional)

### Data Cleanup

Automated cleanup via `cron_20h`:
- Expired feed items (>24h old)
- Expired proof photos (>24h old)
- Old grain ledger entries (archival strategy TBD)

## Scalability Considerations

### Current Architecture (MVP)

- **Users**: Up to 10,000
- **Daily Contracts**: 10,000/day
- **Feed Items**: ~30,000 active (3 goals × 10K users)
- **Database**: Supabase free tier (500MB, 2GB bandwidth)

### Future Scalability

When scaling beyond MVP:

1. **Database**:
   - Upgrade Supabase plan (paid)
   - Partition large tables (grains_ledger, feed_items)
   - Archive old data to cold storage

2. **Storage**:
   - Use CDN for photo delivery
   - Optimize image sizes (WebP format)
   - Implement lazy loading

3. **Backend API**:
   - Deploy FastAPI with multiple workers
   - Use Redis for caching
   - Implement rate limiting

4. **Edge Functions**:
   - Batch processing for large user bases
   - Queue system for async tasks
   - Monitoring and alerting

## Monitoring & Observability

### Key Metrics to Track

1. **User Engagement**:
   - Daily active users (DAU)
   - Morning contract creation rate
   - Evening sync completion rate
   - Victory feed interaction rate

2. **System Health**:
   - API response times
   - Database query performance
   - Edge function execution time
   - Storage bandwidth usage

3. **Business Metrics**:
   - Average grains/user/day
   - Life ratio distribution
   - Phoenix mode activation rate
   - Social interaction rates (boosts, comments)

### Logging

- **Backend**: FastAPI structured logs (JSON)
- **Edge Functions**: Supabase function logs
- **App**: Firebase Crashlytics (optional)

## Deployment

### Development

```bash
# Local development
./ops/scripts/run_dev.sh
```

### Production

1. **Supabase**:
   - Database hosted on Supabase Cloud
   - Edge Functions deployed via Supabase CLI
   - Storage on Supabase Storage

2. **Backend API** (optional):
   - Deploy to Cloud Run / Heroku / Railway
   - Set environment variables
   - Enable HTTPS

3. **Mobile App**:
   - **iOS**: App Store via TestFlight → Production
   - **Android**: Google Play via Internal Testing → Production
   - **CI/CD**: GitHub Actions / Codemagic

## Tech Stack Summary

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | Flutter 3.2+ | Cross-platform UI |
| State | Riverpod | State management |
| Backend | FastAPI (Python) | Business logic API |
| Database | PostgreSQL (Supabase) | Data persistence |
| Auth | Supabase Auth | User management |
| Storage | Supabase Storage | Photo hosting |
| Serverless | Supabase Edge Functions | Cron jobs |
| DevOps | Bash scripts, Makefile | Automation |

## Next Steps (Post-MVP)

1. **Push Notifications**: Firebase Cloud Messaging
2. **Analytics**: Mixpanel / Amplitude
3. **Crash Reporting**: Sentry / Crashlytics
4. **Performance**: New Relic / Datadog
5. **CI/CD**: GitHub Actions
6. **Feature Flags**: LaunchDarkly / PostHog
7. **A/B Testing**: Optimizely / Firebase Remote Config
