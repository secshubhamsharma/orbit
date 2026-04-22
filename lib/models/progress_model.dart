import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'progress_model.freezed.dart';
part 'progress_model.g.dart';

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
class ProgressModel with _$ProgressModel {
  const factory ProgressModel({
    required String topicId,
    @Default('') String topicName,
    @Default('') String domainId,
    @_NullableTimestampConverter() DateTime? firstStudied,
    @_NullableTimestampConverter() DateTime? lastStudied,
    @Default(0) int totalSessions,
    @Default(0) int totalCardsReviewed,
    @Default(0) int totalCorrect,
    @Default(0) int totalIncorrect,
    @Default(0.0) double accuracy,
    @Default(0.0) double masteryPercent,
    @Default('learning') String masteryLevel,
    @Default([]) List<String> weakSubTopics,
    @Default(0) int totalStudyMinutes,
    @Default(0) int cardsDue,
    @Default(0) int cardsNew,
    @Default(0) int cardsMastered,
  }) = _ProgressModel;

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);
}
