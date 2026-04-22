import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'pdf_upload_model.freezed.dart';
part 'pdf_upload_model.g.dart';

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
class PdfUploadModel with _$PdfUploadModel {
  const PdfUploadModel._();

  const factory PdfUploadModel({
    required String id,
    required String userId,
    required String fileName,
    @Default('') String storagePath,
    @Default(0) int pageCount,
    @Default(0.0) double fileSizeMB,
    @Default('uploading') String status,
    @_TimestampConverter() required DateTime uploadedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    @Default('') String topicName,
    @Default('') String domainId,
    @Default(0) int generatedCardCount,
    String? error,
    @Default(false) bool isPublic,
  }) = _PdfUploadModel;

  factory PdfUploadModel.fromJson(Map<String, dynamic> json) =>
      _$PdfUploadModelFromJson(json);

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'uploading' || status == 'processing';
}
