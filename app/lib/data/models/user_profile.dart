import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    @Default('') String displayName,
    String? avatarUrl,
    @Default('Europe/Paris') String timezone,
    @Default(0.0) double ratio,
    @Default(0.0) double totalGrains,
    @Default(0) int daysOnApp,
    @Default(false) bool privacyHideFromFeed,
    @Default(false) bool privacyAnonymous,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class DailyContract with _$DailyContract {
  const factory DailyContract({
    required String id,
    required String userId,
    required DateTime date,
    @Default('open') String status, // open, synced
    required DateTime createdAt,
  }) = _DailyContract;

  factory DailyContract.fromJson(Map<String, dynamic> json) =>
      _$DailyContractFromJson(json);
}

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String userId,
    required String title,
    @Default(1.0) double baseValue,
    DateTime? lastUsedAt,
    @Default(0) int repeatCount,
    required DateTime createdAt,
  }) = _Goal;

  factory Goal.fromJson(Map<String, dynamic> json) =>
      _$GoalFromJson(json);
}

@freezed
class DailyGoal with _$DailyGoal {
  const factory DailyGoal({
    required String id,
    required String contractId,
    required String goalId,
    required String title,
    required double assignedValue,
    @Default(1) int phase, // 1-4 for devaluation phases
    String? proofUrl,
    DateTime? completedAt,
    required DateTime createdAt,
  }) = _DailyGoal;

  factory DailyGoal.fromJson(Map<String, dynamic> json) =>
      _$DailyGoalFromJson(json);
}

@freezed
class GrainLedger with _$GrainLedger {
  const factory GrainLedger({
    required String id,
    required String userId,
    required String type, // earn, evaporate, boost, transfusion_in, transfusion_out, comment_cost
    required double amount,
    String? refId,
    required DateTime createdAt,
  }) = _GrainLedger;

  factory GrainLedger.fromJson(Map<String, dynamic> json) =>
      _$GrainLedgerFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String id,
    required String userId,
    required String dailyGoalId,
    required String goalTitle,
    String? proofUrl,
    double? grainsEarned,
    String? userDisplayName,
    String? userAvatarUrl,
    required DateTime visibleFrom,
    required DateTime expiresAt,
    @Default(0) int boostsCount,
    @Default(0) int commentsCount,
    required DateTime createdAt,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);
}

@freezed
class Season with _$Season {
  const factory Season({
    required String id,
    required String userId,
    required String label, // winter, spring, summer, autumn
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) =>
      _$SeasonFromJson(json);
}

@freezed
class PhoenixState with _$PhoenixState {
  const factory PhoenixState({
    required String id,
    required String userId,
    @Default(false) bool active,
    required DateTime startedAt,
    DateTime? endedAt,
    Map<String, dynamic>? metricsSnapshot,
  }) = _PhoenixState;

  factory PhoenixState.fromJson(Map<String, dynamic> json) =>
      _$PhoenixStateFromJson(json);
}
