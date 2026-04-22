import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'domain_model.freezed.dart';
part 'domain_model.g.dart';

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
class DomainModel with _$DomainModel {
  const factory DomainModel({
    required String id,
    required String name,
    required String description,
    @Default('') String iconUrl,
    @Default('#7C6FE8') String colorHex,
    @Default([]) List<String> subDomains,
    @Default(0) int totalTopics,
    @Default(0) int order,
  }) = _DomainModel;

  factory DomainModel.fromJson(Map<String, dynamic> json) =>
      _$DomainModelFromJson(json);
}
