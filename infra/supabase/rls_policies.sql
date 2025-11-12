-- Row Level Security (RLS) Policies for Hourglass
-- Ensures users can only access their own data and appropriate public data

-- ============================================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE grains_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE boosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfusions ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE seasons ENABLE ROW LEVEL SECURITY;
ALTER TABLE phoenix_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE pacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE pact_members ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- USERS TABLE POLICIES
-- ============================================================================

-- Users can read their own data
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id);

-- ============================================================================
-- PROFILES TABLE POLICIES
-- ============================================================================

CREATE POLICY "Users can view own profile data"
    ON profiles FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile data"
    ON profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================================================
-- DAILY CONTRACTS AND GOALS POLICIES
-- ============================================================================

CREATE POLICY "Users can view own contracts"
    ON daily_contracts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own contracts"
    ON daily_contracts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own contracts"
    ON daily_contracts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view own goals"
    ON goals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own goals"
    ON goals FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own daily goals"
    ON daily_goals FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM daily_contracts dc
            WHERE dc.id = daily_goals.contract_id
            AND dc.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create own daily goals"
    ON daily_goals FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM daily_contracts dc
            WHERE dc.id = daily_goals.contract_id
            AND dc.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own daily goals"
    ON daily_goals FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM daily_contracts dc
            WHERE dc.id = daily_goals.contract_id
            AND dc.user_id = auth.uid()
        )
    );

-- ============================================================================
-- GRAINS LEDGER POLICIES
-- ============================================================================

CREATE POLICY "Users can view own grain transactions"
    ON grains_ledger FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own grain transactions"
    ON grains_ledger FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FEED ITEMS POLICIES (PUBLIC READING WITH CONSTRAINTS)
-- ============================================================================

-- Users can view feed items that are currently visible
-- Respects privacy settings
CREATE POLICY "Users can view active feed items"
    ON feed_items FOR SELECT
    USING (
        NOW() >= visible_from
        AND NOW() <= expires_at
        AND NOT EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.user_id = feed_items.user_id
            AND p.privacy_hide_from_feed = true
        )
    );

CREATE POLICY "Users can create own feed items"
    ON feed_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- SOCIAL INTERACTION POLICIES
-- ============================================================================

-- Boosts: users can read all, but only create their own
CREATE POLICY "Users can view boosts"
    ON boosts FOR SELECT
    USING (true);

CREATE POLICY "Users can send boosts"
    ON boosts FOR INSERT
    WITH CHECK (auth.uid() = from_user);

-- Transfusions: similar to boosts
CREATE POLICY "Users can view transfusions"
    ON transfusions FOR SELECT
    USING (auth.uid() = from_user OR auth.uid() = to_user);

CREATE POLICY "Users can send transfusions"
    ON transfusions FOR INSERT
    WITH CHECK (auth.uid() = from_user);

-- Comments: users can read all comments on visible feed items
CREATE POLICY "Users can view comments"
    ON comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM feed_items fi
            WHERE fi.id = comments.feed_item_id
            AND NOW() >= fi.visible_from
            AND NOW() <= fi.expires_at
        )
    );

CREATE POLICY "Users can create comments"
    ON comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- SEASONS AND PHOENIX POLICIES
-- ============================================================================

CREATE POLICY "Users can view own seasons"
    ON seasons FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can manage seasons"
    ON seasons FOR ALL
    USING (true);

CREATE POLICY "Users can view own phoenix state"
    ON phoenix_states FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can manage phoenix states"
    ON phoenix_states FOR ALL
    USING (true);

-- ============================================================================
-- STORAGE POLICIES (for proof photos)
-- ============================================================================

-- Note: These are applied via Supabase Storage dashboard or CLI
-- Bucket name: 'proofs'
-- Policy: Users can upload to their own folder, read their own files
-- TTL: 24 hours (auto-deletion)

-- Example storage policy (applied via Supabase dashboard):
-- INSERT policy: (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)
-- SELECT policy: (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)
