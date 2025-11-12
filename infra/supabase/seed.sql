-- Seed Data for Hourglass MVP
-- Creates demo users, goals, and feed items for testing

-- ============================================================================
-- DEMO USERS
-- ============================================================================

-- Note: In production, users are created via Supabase Auth
-- These are example data structures

INSERT INTO users (id, email, display_name, avatar_url, tz) VALUES
('00000000-0000-0000-0000-000000000001', 'alice@example.com', 'Alice', NULL, 'Europe/Paris'),
('00000000-0000-0000-0000-000000000002', 'bob@example.com', 'Bob', NULL, 'Europe/Paris'),
('00000000-0000-0000-0000-000000000003', 'charlie@example.com', 'Charlie', NULL, 'Europe/Paris')
ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (user_id, ratio, total_grains, days_on_app) VALUES
('00000000-0000-0000-0000-000000000001', 75.5, 151.0, 20),
('00000000-0000-0000-0000-000000000002', 82.3, 164.6, 20),
('00000000-0000-0000-0000-000000000003', 45.2, 90.4, 20)
ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- DEMO GOALS
-- ============================================================================

INSERT INTO goals (id, user_id, title, base_value, repeat_count, last_used_at) VALUES
('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Morning run', 2.5, 15, NOW() - INTERVAL '1 day'),
('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Read for 30 minutes', 2.0, 8, NOW() - INTERVAL '2 days'),
('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Meditate', 2.5, 20, NOW() - INTERVAL '1 day'),
('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000002', 'Workout at gym', 2.5, 10, NOW() - INTERVAL '1 day'),
('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000002', 'Practice guitar', 2.0, 5, NOW() - INTERVAL '3 days'),
('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000003', 'Write journal', 2.0, 12, NOW() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- TODAY'S CONTRACTS
-- ============================================================================

INSERT INTO daily_contracts (id, user_id, date, status) VALUES
('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', CURRENT_DATE, 'open'),
('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', CURRENT_DATE, 'open'),
('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000003', CURRENT_DATE, 'open')
ON CONFLICT (user_id, date) DO NOTHING;

-- ============================================================================
-- YESTERDAY'S COMPLETED DAILY GOALS (for feed demonstration)
-- ============================================================================

INSERT INTO daily_goals (id, contract_id, goal_id, title, assigned_value, phase, completed_at) VALUES
('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Morning run', 4.0, 1, NOW() - INTERVAL '1 day' + INTERVAL '9 hours'),
('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', 'Read for 30 minutes', 3.0, 1, NOW() - INTERVAL '1 day' + INTERVAL '14 hours'),
('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000003', 'Meditate', 3.0, 1, NOW() - INTERVAL '1 day' + INTERVAL '7 hours')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- FEED ITEMS (visible for 24h after 20:00)
-- ============================================================================

INSERT INTO feed_items (id, user_id, daily_goal_id, goal_title, grains_earned, visible_from, expires_at, boosts_count, comments_count) VALUES
('40000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Morning run', 4.0, NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours', 2, 1),
('40000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', 'Read for 30 minutes', 3.0, NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours', 0, 0),
('40000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', 'Meditate', 3.0, NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours', 1, 0)
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- DEMO BOOSTS AND COMMENTS
-- ============================================================================

INSERT INTO boosts (from_user, to_user, amount, feed_item_id) VALUES
('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 0.2, '40000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 0.2, '40000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO comments (user_id, feed_item_id, text, cost) VALUES
('00000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000001', 'Great work! Keep it up!', 0.1)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- GRAINS LEDGER HISTORY
-- ============================================================================

INSERT INTO grains_ledger (user_id, type, amount, ref_id) VALUES
-- Alice's earnings
('00000000-0000-0000-0000-000000000001', 'earn', 4.0, '30000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000001', 'earn', 3.0, '30000000-0000-0000-0000-000000000002'),
('00000000-0000-0000-0000-000000000001', 'earn', 3.0, '30000000-0000-0000-0000-000000000003'),
('00000000-0000-0000-0000-000000000001', 'boost_in', 0.2, '40000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000001', 'boost_in', 0.2, '40000000-0000-0000-0000-000000000001'),
-- Bob's boosts
('00000000-0000-0000-0000-000000000002', 'boost_out', -0.2, '40000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000002', 'comment_cost', -0.1, '40000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- SEASONS
-- ============================================================================

INSERT INTO seasons (user_id, label, started_at) VALUES
('00000000-0000-0000-0000-000000000001', 'summer', NOW() - INTERVAL '10 days'),
('00000000-0000-0000-0000-000000000002', 'summer', NOW() - INTERVAL '15 days'),
('00000000-0000-0000-0000-000000000003', 'spring', NOW() - INTERVAL '8 days')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Verify data was inserted
SELECT 'Users created:' as status, COUNT(*) as count FROM users;
SELECT 'Profiles created:' as status, COUNT(*) as count FROM profiles;
SELECT 'Goals created:' as status, COUNT(*) as count FROM goals;
SELECT 'Feed items:' as status, COUNT(*) as count FROM feed_items;
SELECT 'Grain transactions:' as status, COUNT(*) as count FROM grains_ledger;
