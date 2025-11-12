-- Hourglass Database Schema
-- PostgreSQL + Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS AND PROFILES
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT DEFAULT '',
    avatar_url TEXT,
    tz TEXT DEFAULT 'Europe/Paris',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    privacy_hide_from_feed BOOLEAN DEFAULT false,
    privacy_anonymous BOOLEAN DEFAULT false,
    ratio DECIMAL(5,2) DEFAULT 0.0,
    total_grains DECIMAL(10,2) DEFAULT 0.0,
    days_on_app INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- DAILY CONTRACTS AND GOALS
-- ============================================================================

CREATE TABLE IF NOT EXISTS daily_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'synced')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    base_value DECIMAL(4,2) DEFAULT 1.5,
    last_used_at TIMESTAMPTZ,
    repeat_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS daily_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID NOT NULL REFERENCES daily_contracts(id) ON DELETE CASCADE,
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    assigned_value DECIMAL(4,2) NOT NULL,
    phase INTEGER DEFAULT 1 CHECK (phase BETWEEN 1 AND 4),
    proof_url TEXT,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- GRAINS LEDGER
-- ============================================================================

CREATE TABLE IF NOT EXISTS grains_ledger (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'earn', 'evaporate', 'boost_in', 'boost_out',
        'transfusion_in', 'transfusion_out', 'comment_cost'
    )),
    amount DECIMAL(10,2) NOT NULL,
    ref_id UUID,  -- Reference to related entity (feed_item, goal, etc.)
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- FEED AND SOCIAL
-- ============================================================================

CREATE TABLE IF NOT EXISTS feed_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    daily_goal_id UUID NOT NULL REFERENCES daily_goals(id) ON DELETE CASCADE,
    goal_title TEXT NOT NULL,
    proof_url TEXT,
    grains_earned DECIMAL(4,2),
    visible_from TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    boosts_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS boosts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(4,2) DEFAULT 0.2,
    feed_item_id UUID NOT NULL REFERENCES feed_items(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transfusions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(4,2) DEFAULT 1.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    feed_item_id UUID NOT NULL REFERENCES feed_items(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    cost DECIMAL(4,2) DEFAULT 0.1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- SEASONS AND PHOENIX MODE
-- ============================================================================

CREATE TABLE IF NOT EXISTS seasons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    label TEXT NOT NULL CHECK (label IN ('winter', 'spring', 'summer', 'autumn')),
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS phoenix_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    active BOOLEAN DEFAULT false,
    started_at TIMESTAMPTZ NOT NULL,
    ended_at TIMESTAMPTZ,
    metrics_snapshot JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- PACTS (OPTIONAL FOR MVP)
-- ============================================================================

CREATE TABLE IF NOT EXISTS pacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT NOT NULL CHECK (type IN ('couple', 'friends', 'legion')),
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pact_members (
    pact_id UUID NOT NULL REFERENCES pacts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member',
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (pact_id, user_id)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX idx_daily_contracts_user_date ON daily_contracts(user_id, date DESC);
CREATE INDEX idx_daily_goals_contract ON daily_goals(contract_id);
CREATE INDEX idx_grains_ledger_user ON grains_ledger(user_id, created_at DESC);
CREATE INDEX idx_feed_items_visible ON feed_items(visible_from, expires_at);
CREATE INDEX idx_feed_items_user ON feed_items(user_id, created_at DESC);
CREATE INDEX idx_boosts_feed_item ON boosts(feed_item_id);
CREATE INDEX idx_comments_feed_item ON comments(feed_item_id);
CREATE INDEX idx_goals_user ON goals(user_id, last_used_at DESC);

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Update profile.updated_at on changes
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-increment days_on_app (could be run daily via cron)
CREATE OR REPLACE FUNCTION increment_days_on_app()
RETURNS void AS $$
BEGIN
    UPDATE profiles
    SET days_on_app = days_on_app + 1
    WHERE user_id IN (
        SELECT DISTINCT user_id
        FROM grains_ledger
        WHERE created_at::date = CURRENT_DATE - INTERVAL '1 day'
    );
END;
$$ LANGUAGE plpgsql;
