// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      timezone: json['timezone'] as String? ?? 'Europe/Paris',
      ratio: (json['ratio'] as num?)?.toDouble() ?? 0.0,
      totalGrains: (json['totalGrains'] as num?)?.toDouble() ?? 0.0,
      daysOnApp: (json['daysOnApp'] as num?)?.toInt() ?? 0,
      privacyHideFromFeed: json['privacyHideFromFeed'] as bool? ?? false,
      privacyAnonymous: json['privacyAnonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'timezone': instance.timezone,
      'ratio': instance.ratio,
      'totalGrains': instance.totalGrains,
      'daysOnApp': instance.daysOnApp,
      'privacyHideFromFeed': instance.privacyHideFromFeed,
      'privacyAnonymous': instance.privacyAnonymous,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$DailyContractImpl _$$DailyContractImplFromJson(Map<String, dynamic> json) =>
    _$DailyContractImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String? ?? 'open',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DailyContractImplToJson(_$DailyContractImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$GoalImpl _$$GoalImplFromJson(Map<String, dynamic> json) => _$GoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      baseValue: (json['baseValue'] as num?)?.toDouble() ?? 1.0,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      repeatCount: (json['repeatCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GoalImplToJson(_$GoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'baseValue': instance.baseValue,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'repeatCount': instance.repeatCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$DailyGoalImpl _$$DailyGoalImplFromJson(Map<String, dynamic> json) =>
    _$DailyGoalImpl(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      assignedValue: (json['assignedValue'] as num).toDouble(),
      phase: (json['phase'] as num?)?.toInt() ?? 1,
      proofUrl: json['proofUrl'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DailyGoalImplToJson(_$DailyGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contractId': instance.contractId,
      'goalId': instance.goalId,
      'title': instance.title,
      'assignedValue': instance.assignedValue,
      'phase': instance.phase,
      'proofUrl': instance.proofUrl,
      'completedAt': instance.completedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$GrainLedgerImpl _$$GrainLedgerImplFromJson(Map<String, dynamic> json) =>
    _$GrainLedgerImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      refId: json['refId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GrainLedgerImplToJson(_$GrainLedgerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'refId': instance.refId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$FeedItemImpl _$$FeedItemImplFromJson(Map<String, dynamic> json) =>
    _$FeedItemImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dailyGoalId: json['dailyGoalId'] as String,
      goalTitle: json['goalTitle'] as String,
      proofUrl: json['proofUrl'] as String?,
      grainsEarned: (json['grainsEarned'] as num?)?.toDouble(),
      userDisplayName: json['userDisplayName'] as String?,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      visibleFrom: DateTime.parse(json['visibleFrom'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      boostsCount: (json['boostsCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FeedItemImplToJson(_$FeedItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dailyGoalId': instance.dailyGoalId,
      'goalTitle': instance.goalTitle,
      'proofUrl': instance.proofUrl,
      'grainsEarned': instance.grainsEarned,
      'userDisplayName': instance.userDisplayName,
      'userAvatarUrl': instance.userAvatarUrl,
      'visibleFrom': instance.visibleFrom.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'boostsCount': instance.boostsCount,
      'commentsCount': instance.commentsCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$SeasonImpl _$$SeasonImplFromJson(Map<String, dynamic> json) => _$SeasonImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      label: json['label'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
    );

Map<String, dynamic> _$$SeasonImplToJson(_$SeasonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'label': instance.label,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
    };

_$PhoenixStateImpl _$$PhoenixStateImplFromJson(Map<String, dynamic> json) =>
    _$PhoenixStateImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      active: json['active'] as bool? ?? false,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      metricsSnapshot: json['metricsSnapshot'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$PhoenixStateImplToJson(_$PhoenixStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'active': instance.active,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'metricsSnapshot': instance.metricsSnapshot,
    };
