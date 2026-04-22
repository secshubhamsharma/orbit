// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardScheduleModelImpl _$$CardScheduleModelImplFromJson(
  Map<String, dynamic> json,
) => _$CardScheduleModelImpl(
  cardId: json['cardId'] as String,
  topicId: json['topicId'] as String,
  domainId: json['domainId'] as String? ?? '',
  easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
  interval: (json['interval'] as num?)?.toInt() ?? 1,
  repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
  nextReviewDate: const _TimestampConverter().fromJson(json['nextReviewDate']),
  lastReviewDate: const _NullableTimestampConverter().fromJson(
    json['lastReviewDate'],
  ),
  lastRating: json['lastRating'] as String? ?? '',
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
  incorrectCount: (json['incorrectCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$CardScheduleModelImplToJson(
  _$CardScheduleModelImpl instance,
) => <String, dynamic>{
  'cardId': instance.cardId,
  'topicId': instance.topicId,
  'domainId': instance.domainId,
  'easeFactor': instance.easeFactor,
  'interval': instance.interval,
  'repetitions': instance.repetitions,
  'nextReviewDate': const _TimestampConverter().toJson(instance.nextReviewDate),
  'lastReviewDate': const _NullableTimestampConverter().toJson(
    instance.lastReviewDate,
  ),
  'lastRating': instance.lastRating,
  'totalReviews': instance.totalReviews,
  'correctCount': instance.correctCount,
  'incorrectCount': instance.incorrectCount,
};
