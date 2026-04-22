// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaderboardEntryModelImpl _$$LeaderboardEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$LeaderboardEntryModelImpl(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String,
  photoUrl: json['photoUrl'] as String?,
  weeklyCardsReviewed: (json['weeklyCardsReviewed'] as num?)?.toInt() ?? 0,
  weeklyAccuracy: (json['weeklyAccuracy'] as num?)?.toDouble() ?? 0.0,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  rank: (json['rank'] as num?)?.toInt() ?? 0,
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$$LeaderboardEntryModelImplToJson(
  _$LeaderboardEntryModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'weeklyCardsReviewed': instance.weeklyCardsReviewed,
  'weeklyAccuracy': instance.weeklyAccuracy,
  'currentStreak': instance.currentStreak,
  'rank': instance.rank,
  'updatedAt': const NullableTimestampConverter().toJson(instance.updatedAt),
};
