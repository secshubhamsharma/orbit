// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserSettingsImpl _$$UserSettingsImplFromJson(Map<String, dynamic> json) =>
    _$UserSettingsImpl(
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      reminderTime: json['reminderTime'] as String? ?? '20:00',
      streakAlertEnabled: json['streakAlertEnabled'] as bool? ?? true,
      darkMode: json['darkMode'] as bool? ?? false,
      fontSize: json['fontSize'] as String? ?? 'medium',
      hideFromLeaderboard: json['hideFromLeaderboard'] as bool? ?? false,
      defaultCardOrder: json['defaultCardOrder'] as String? ?? 'due_first',
    );

Map<String, dynamic> _$$UserSettingsImplToJson(_$UserSettingsImpl instance) =>
    <String, dynamic>{
      'reminderEnabled': instance.reminderEnabled,
      'reminderTime': instance.reminderTime,
      'streakAlertEnabled': instance.streakAlertEnabled,
      'darkMode': instance.darkMode,
      'fontSize': instance.fontSize,
      'hideFromLeaderboard': instance.hideFromLeaderboard,
      'defaultCardOrder': instance.defaultCardOrder,
    };

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: const _TimestampConverter().fromJson(json['createdAt']),
      lastActiveAt: const _TimestampConverter().fromJson(json['lastActiveAt']),
      isPremium: json['isPremium'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String? ?? '',
      selectedDomains:
          (json['selectedDomains'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 10,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastStudiedDate: const _NullableTimestampConverter().fromJson(
        json['lastStudiedDate'],
      ),
      streakFreezeAvailable:
          (json['streakFreezeAvailable'] as num?)?.toInt() ?? 1,
      totalCardsReviewed: (json['totalCardsReviewed'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      overallAccuracy: (json['overallAccuracy'] as num?)?.toDouble() ?? 0.0,
      topicsStarted: (json['topicsStarted'] as num?)?.toInt() ?? 0,
      weeklyCardsReviewed: (json['weeklyCardsReviewed'] as num?)?.toInt() ?? 0,
      earnedBadges:
          (json['earnedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      settings: json['settings'] == null
          ? const UserSettings()
          : UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'lastActiveAt': const _TimestampConverter().toJson(instance.lastActiveAt),
      'isPremium': instance.isPremium,
      'fcmToken': instance.fcmToken,
      'selectedDomains': instance.selectedDomains,
      'dailyGoalMinutes': instance.dailyGoalMinutes,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastStudiedDate': const _NullableTimestampConverter().toJson(
        instance.lastStudiedDate,
      ),
      'streakFreezeAvailable': instance.streakFreezeAvailable,
      'totalCardsReviewed': instance.totalCardsReviewed,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'overallAccuracy': instance.overallAccuracy,
      'topicsStarted': instance.topicsStarted,
      'weeklyCardsReviewed': instance.weeklyCardsReviewed,
      'earnedBadges': instance.earnedBadges,
      'settings': instance.settings,
      'onboardingCompleted': instance.onboardingCompleted,
      'emailVerified': instance.emailVerified,
    };
