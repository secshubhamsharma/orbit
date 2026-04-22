// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicModelImpl _$$TopicModelImplFromJson(Map<String, dynamic> json) =>
    _$TopicModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      subjectId: json['subjectId'] as String,
      domainId: json['domainId'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: const _TimestampConverter().fromJson(json['createdAt']),
      lastUpdated: const _TimestampConverter().fromJson(json['lastUpdated']),
      generatedByAI: json['generatedByAI'] as bool? ?? true,
    );

Map<String, dynamic> _$$TopicModelImplToJson(_$TopicModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subjectId': instance.subjectId,
      'domainId': instance.domainId,
      'description': instance.description,
      'difficulty': instance.difficulty,
      'totalCards': instance.totalCards,
      'estimatedMinutes': instance.estimatedMinutes,
      'tags': instance.tags,
      'createdAt': const _TimestampConverter().toJson(instance.createdAt),
      'lastUpdated': const _TimestampConverter().toJson(instance.lastUpdated),
      'generatedByAI': instance.generatedByAI,
    };
