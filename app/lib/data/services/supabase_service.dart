import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../../core/env.dart';

/// Core Supabase service for authentication and database operations
class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('SupabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Auth
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // User Profile
  static Future<UserProfile?> getUserProfile(String userId) async {
    final response = await client
        .from('users')
        .select('*, profiles(*)')
        .eq('id', userId)
        .single();

    if (response == null) return null;

    return UserProfile(
      id: response['id'],
      email: response['email'],
      displayName: response['display_name'] ?? '',
      avatarUrl: response['avatar_url'],
      timezone: response['tz'] ?? 'Europe/Paris',
      ratio: (response['profiles']?['ratio'] ?? 0.0).toDouble(),
      totalGrains: (response['profiles']?['total_grains'] ?? 0.0).toDouble(),
      daysOnApp: response['profiles']?['days_on_app'] ?? 0,
      privacyHideFromFeed: response['profiles']?['privacy_hide_from_feed'] ?? false,
      privacyAnonymous: response['profiles']?['privacy_anonymous'] ?? false,
      createdAt: DateTime.parse(response['created_at']),
    );
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? timezone,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    if (displayName != null || avatarUrl != null || timezone != null) {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (timezone != null) updates['tz'] = timezone;

      await client.from('users').update(updates).eq('id', userId);
    }
  }

  // Daily Contract
  static Future<DailyContract?> getTodayContract() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      final response = await client
          .from('daily_contracts')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .single();

      return DailyContract.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  static Future<DailyContract> createTodayContract() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await client
        .from('daily_contracts')
        .insert({
          'user_id': userId,
          'date': today,
          'status': 'open',
        })
        .select()
        .single();

    return DailyContract.fromJson(response);
  }

  // Goals
  static Future<List<Goal>> getUserGoals() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('goals')
        .select()
        .eq('user_id', userId)
        .order('last_used_at', ascending: false);

    return (response as List).map((json) => Goal.fromJson(json)).toList();
  }

  static Future<Goal> createGoal(String title, double baseValue) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final response = await client
        .from('goals')
        .insert({
          'user_id': userId,
          'title': title,
          'base_value': baseValue,
        })
        .select()
        .single();

    return Goal.fromJson(response);
  }

  // Daily Goals
  static Future<List<DailyGoal>> getTodayGoals(String contractId) async {
    final response = await client
        .from('daily_goals')
        .select()
        .eq('contract_id', contractId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => DailyGoal.fromJson(json)).toList();
  }

  static Future<DailyGoal> createDailyGoal({
    required String contractId,
    required String goalId,
    required String title,
    required double assignedValue,
    required int phase,
  }) async {
    final response = await client
        .from('daily_goals')
        .insert({
          'contract_id': contractId,
          'goal_id': goalId,
          'title': title,
          'assigned_value': assignedValue,
          'phase': phase,
        })
        .select()
        .single();

    return DailyGoal.fromJson(response);
  }

  static Future<void> updateDailyGoalProof(String dailyGoalId, String proofUrl) async {
    await client
        .from('daily_goals')
        .update({
          'proof_url': proofUrl,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', dailyGoalId);
  }

  // Feed
  static Future<List<FeedItem>> getVictoryFeed({int limit = 50}) async {
    final now = DateTime.now().toIso8601String();

    final response = await client
        .from('feed_items')
        .select('''
          *,
          users!inner(display_name, avatar_url)
        ''')
        .lte('visible_from', now)
        .gte('expires_at', now)
        .order('visible_from', ascending: false)
        .limit(limit);

    return (response as List).map((json) {
      return FeedItem(
        id: json['id'],
        userId: json['user_id'],
        dailyGoalId: json['daily_goal_id'],
        goalTitle: json['goal_title'] ?? '',
        proofUrl: json['proof_url'],
        grainsEarned: json['grains_earned']?.toDouble(),
        userDisplayName: json['users']?['display_name'],
        userAvatarUrl: json['users']?['avatar_url'],
        visibleFrom: DateTime.parse(json['visible_from']),
        expiresAt: DateTime.parse(json['expires_at']),
        boostsCount: json['boosts_count'] ?? 0,
        commentsCount: json['comments_count'] ?? 0,
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  // Storage
  static Future<String> uploadProof(String dailyGoalId, String filePath) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_$dailyGoalId.jpg';

    await client.storage
        .from('proofs')
        .upload(fileName, filePath);

    final signedUrl = await client.storage
        .from('proofs')
        .createSignedUrl(fileName, 86400); // 24h

    return signedUrl;
  }

  // Grains Ledger
  static Future<void> recordGrainTransaction({
    required String type,
    required double amount,
    String? refId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    await client.from('grains_ledger').insert({
      'user_id': userId,
      'type': type,
      'amount': amount,
      'ref_id': refId,
    });
  }

  static Future<List<GrainLedger>> getGrainHistory({int limit = 100}) async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('grains_ledger')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List).map((json) => GrainLedger.fromJson(json)).toList();
  }
}
