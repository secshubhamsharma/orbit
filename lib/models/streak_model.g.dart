// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakModelImpl _$$StreakModelImplFromJson(Map<String, dynamic> json) =>
    _$StreakModelImpl(
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastStudiedDate: const _NullableTimestampConverter().fromJson(
        json['lastStudiedDate'],
      ),
      streakFreezeAvailable:
          (json['streakFreezeAvailable'] as num?)?.toInt() ?? 1,
      weeklyActivity:
          (json['weeklyActivity'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$StreakModelImplToJson(_$StreakModelImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastStudiedDate': const _NullableTimestampConverter().toJson(
        instance.lastStudiedDate,
      ),
      'streakFreezeAvailable': instance.streakFreezeAvailable,
      'weeklyActivity': instance.weeklyActivity,
    };
