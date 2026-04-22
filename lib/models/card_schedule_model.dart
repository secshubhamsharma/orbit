import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'card_schedule_model.freezed.dart';
part 'card_schedule_model.g.dart';

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
class CardScheduleModel with _$CardScheduleModel {
  const factory CardScheduleModel({
    required String cardId,
    required String topicId,
    @Default('') String domainId,
    @Default(2.5) double easeFactor,
    @Default(1) int interval,
    @Default(0) int repetitions,
    @_TimestampConverter() required DateTime nextReviewDate,
    @_NullableTimestampConverter() DateTime? lastReviewDate,
    @Default('') String lastRating,
    @Default(0) int totalReviews,
    @Default(0) int correctCount,
    @Default(0) int incorrectCount,
  }) = _CardScheduleModel;

  factory CardScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$CardScheduleModelFromJson(json);

  factory CardScheduleModel.newCard({
    required String cardId,
    required String topicId,
    required String domainId,
  }) => CardScheduleModel(
    cardId: cardId,
    topicId: topicId,
    domainId: domainId,
    nextReviewDate: DateTime.now(),
  );
}
