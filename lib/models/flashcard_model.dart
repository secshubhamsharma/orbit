import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'flashcard_model.freezed.dart';
part 'flashcard_model.g.dart';

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
class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String topicId,
    @Default('flashcard') String type,
    required String front,
    required String back,
    @Default([]) List<String> options,
    int? correctOption,
    String? explanation,
    @Default('medium') String difficulty,
    @Default([]) List<String> tags,
    @_TimestampConverter() required DateTime createdAt,
    @Default(true) bool generatedByAI,
    @Default(0) int order,
  }) = _FlashcardModel;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) =>
      _$FlashcardModelFromJson(json);
}
