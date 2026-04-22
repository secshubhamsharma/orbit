// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewSessionModelImpl _$$ReviewSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$ReviewSessionModelImpl(
  sessionId: json['sessionId'] as String,
  topicId: json['topicId'] as String,
  topicName: json['topicName'] as String? ?? '',
  domainId: json['domainId'] as String? ?? '',
  startedAt: const _TimestampConverter().fromJson(json['startedAt']),
  completedAt: const _NullableTimestampConverter().fromJson(
    json['completedAt'],
  ),
  durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
  cardsReviewed: (json['cardsReviewed'] as num?)?.toInt() ?? 0,
  correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
  incorrectCount: (json['incorrectCount'] as num?)?.toInt() ?? 0,
  accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
  ratings:
      (json['ratings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      const {},
  xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$ReviewSessionModelImplToJson(
  _$ReviewSessionModelImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'topicId': instance.topicId,
  'topicName': instance.topicName,
  'domainId': instance.domainId,
  'startedAt': const _TimestampConverter().toJson(instance.startedAt),
  'completedAt': const _NullableTimestampConverter().toJson(
    instance.completedAt,
  ),
  'durationSeconds': instance.durationSeconds,
  'cardsReviewed': instance.cardsReviewed,
  'correctCount': instance.correctCount,
  'incorrectCount': instance.incorrectCount,
  'accuracy': instance.accuracy,
  'ratings': instance.ratings,
  'xpEarned': instance.xpEarned,
};
