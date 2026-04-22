import 'package:freezed_annotation/freezed_annotation.dart';

import 'timestamp_converter.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

/// One entry in `leaderboard/weekly/{weekId}/entries/{userId}`.
@freezed
class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    required String userId,
    required String displayName,
    String? photoUrl,
    @Default(0) int weeklyCardsReviewed,
    @Default(0.0) double weeklyAccuracy,
    @Default(0) int currentStreak,
    @Default(0) int rank,
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _LeaderboardEntryModel;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);
}
