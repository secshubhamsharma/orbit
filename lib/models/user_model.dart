import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// Timestamp converter — handles Firestore Timestamp, String ISO, and int ms
class _TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const _TimestampConverter();
  @override
  DateTime fromJson(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    throw ArgumentError('Cannot convert $v to DateTime');
  }

  @override
  dynamic toJson(DateTime d) => d.toIso8601String();
}

class _NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const _NullableTimestampConverter();
  @override
  DateTime? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  @override
  dynamic toJson(DateTime? d) => d?.toIso8601String();
}

@freezed
class UserSettings with _$UserSettings {
  const factory UserSettings({
    @Default(true) bool reminderEnabled,
    @Default('20:00') String reminderTime,
    @Default(true) bool streakAlertEnabled,
    @Default(false) bool darkMode,
    @Default('medium') String fontSize,
    @Default(false) bool hideFromLeaderboard,
    @Default('due_first') String defaultCardOrder,
  }) = _UserSettings;

  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String displayName,
    required String email,
    String? photoUrl,
    @_TimestampConverter() required DateTime createdAt,
    @_TimestampConverter() required DateTime lastActiveAt,
    @Default(false) bool isPremium,
    @Default('') String fcmToken,
    @Default([]) List<String> selectedDomains,
    @Default(10) int dailyGoalMinutes,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    @Default(1) int streakFreezeAvailable,
    @Default(0) int totalCardsReviewed,
    @Default(0) int totalStudyMinutes,
    @Default(0.0) double overallAccuracy,
    @Default(0) int topicsStarted,
    @Default(0) int weeklyCardsReviewed,
    @Default([]) List<String> earnedBadges,
    @Default(UserSettings()) UserSettings settings,
    @Default(false) bool onboardingCompleted,
    @Default(false) bool emailVerified,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.initial({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) => UserModel(
    uid: uid,
    email: email,
    displayName: displayName ?? '',
    photoUrl: photoUrl,
    createdAt: DateTime.now(),
    lastActiveAt: DateTime.now(),
  );
}
