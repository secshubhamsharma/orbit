// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_upload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfUploadModelImpl _$$PdfUploadModelImplFromJson(Map<String, dynamic> json) =>
    _$PdfUploadModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fileName: json['fileName'] as String,
      storagePath: json['storagePath'] as String? ?? '',
      pageCount: (json['pageCount'] as num?)?.toInt() ?? 0,
      fileSizeMB: (json['fileSizeMB'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'uploading',
      uploadedAt: const _TimestampConverter().fromJson(json['uploadedAt']),
      completedAt: const _NullableTimestampConverter().fromJson(
        json['completedAt'],
      ),
      topicName: json['topicName'] as String? ?? '',
      domainId: json['domainId'] as String? ?? '',
      generatedCardCount: (json['generatedCardCount'] as num?)?.toInt() ?? 0,
      error: json['error'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
    );

Map<String, dynamic> _$$PdfUploadModelImplToJson(
  _$PdfUploadModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'fileName': instance.fileName,
  'storagePath': instance.storagePath,
  'pageCount': instance.pageCount,
  'fileSizeMB': instance.fileSizeMB,
  'status': instance.status,
  'uploadedAt': const _TimestampConverter().toJson(instance.uploadedAt),
  'completedAt': const _NullableTimestampConverter().toJson(
    instance.completedAt,
  ),
  'topicName': instance.topicName,
  'domainId': instance.domainId,
  'generatedCardCount': instance.generatedCardCount,
  'error': instance.error,
  'isPublic': instance.isPublic,
};
