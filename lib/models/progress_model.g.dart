// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressModelImpl _$$ProgressModelImplFromJson(Map<String, dynamic> json) =>
    _$ProgressModelImpl(
      topicId: json['topicId'] as String,
      topicName: json['topicName'] as String? ?? '',
      domainId: json['domainId'] as String? ?? '',
      firstStudied: const _NullableTimestampConverter().fromJson(
        json['firstStudied'],
      ),
      lastStudied: const _NullableTimestampConverter().fromJson(
        json['lastStudied'],
      ),
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      totalCardsReviewed: (json['totalCardsReviewed'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      totalIncorrect: (json['totalIncorrect'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      masteryPercent: (json['masteryPercent'] as num?)?.toDouble() ?? 0.0,
      masteryLevel: json['masteryLevel'] as String? ?? 'learning',
      weakSubTopics:
          (json['weakSubTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      cardsDue: (json['cardsDue'] as num?)?.toInt() ?? 0,
      cardsNew: (json['cardsNew'] as num?)?.toInt() ?? 0,
      cardsMastered: (json['cardsMastered'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProgressModelImplToJson(_$ProgressModelImpl instance) =>
    <String, dynamic>{
      'topicId': instance.topicId,
      'topicName': instance.topicName,
      'domainId': instance.domainId,
      'firstStudied': const _NullableTimestampConverter().toJson(
        instance.firstStudied,
      ),
      'lastStudied': const _NullableTimestampConverter().toJson(
        instance.lastStudied,
      ),
      'totalSessions': instance.totalSessions,
      'totalCardsReviewed': instance.totalCardsReviewed,
      'totalCorrect': instance.totalCorrect,
      'totalIncorrect': instance.totalIncorrect,
      'accuracy': instance.accuracy,
      'masteryPercent': instance.masteryPercent,
      'masteryLevel': instance.masteryLevel,
      'weakSubTopics': instance.weakSubTopics,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'cardsDue': instance.cardsDue,
      'cardsNew': instance.cardsNew,
      'cardsMastered': instance.cardsMastered,
    };
