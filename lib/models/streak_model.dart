import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'streak_model.freezed.dart';
part 'streak_model.g.dart';

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
class StreakModel with _$StreakModel {
  const StreakModel._();

  const factory StreakModel({
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    @Default(1) int streakFreezeAvailable,
    @Default({}) Map<String, int> weeklyActivity,
  }) = _StreakModel;

  factory StreakModel.fromJson(Map<String, dynamic> json) =>
      _$StreakModelFromJson(json);

  bool get studiedToday {
    if (lastStudiedDate == null) return false;
    final now = DateTime.now();
    final d = lastStudiedDate!;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool get isAtRisk {
    if (currentStreak == 0) return false;
    return !studiedToday;
  }
}
