import 'package:freezed_annotation/freezed_annotation.dart';

import 'timestamp_converter.dart';

part 'leaderboard_model.freezed.dart';
part 'leaderboard_model.g.dart';

/// One entry in the flat `leaderboard/{userId}` collection.
///
/// Score = totalCardsReviewed × overallAccuracy — ranks users by a combination
/// of study volume and quality. Rank is assigned client-side after sorting.
@freezed
class LeaderboardEntryModel with _$LeaderboardEntryModel {
  const factory LeaderboardEntryModel({
    required String userId,
    required String displayName,
    String? photoUrl,
    @Default(0) int totalCardsReviewed,
    @Default(0.0) double overallAccuracy,
    @Default(0) int currentStreak,
    @Default(0) int rank,         // populated client-side after sorting
    @Default(0.0) double score,   // totalCardsReviewed × overallAccuracy
    @NullableTimestampConverter() DateTime? updatedAt,
  }) = _LeaderboardEntryModel;

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryModelFromJson(json);
}
