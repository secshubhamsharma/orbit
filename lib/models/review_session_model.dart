import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'review_session_model.freezed.dart';
part 'review_session_model.g.dart';

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
class ReviewSessionModel with _$ReviewSessionModel {
  const factory ReviewSessionModel({
    required String sessionId,
    required String topicId,
    @Default('') String topicName,
    @Default('') String domainId,
    @_TimestampConverter() required DateTime startedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    @Default(0) int durationSeconds,
    @Default(0) int cardsReviewed,
    @Default(0) int correctCount,
    @Default(0) int incorrectCount,
    @Default(0.0) double accuracy,
    @Default({}) Map<String, int> ratings,
    @Default(0) int xpEarned,
  }) = _ReviewSessionModel;

  factory ReviewSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewSessionModelFromJson(json);
}
