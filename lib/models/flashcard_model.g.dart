// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlashcardModelImpl _$$FlashcardModelImplFromJson(Map<String, dynamic> json) =>
    _$FlashcardModelImpl(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      type: json['type'] as String? ?? 'flashcard',
      front: json['front'] as String,
      back: json['back'] as String,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctOption: (json['correctOption'] as num?)?.toInt(),
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: const _TimestampConverter().fromJson(json['createdAt']),
      generatedByAI: json['generatedByAI'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FlashcardModelImplToJson(
  _$FlashcardModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'topicId': instance.topicId,
  'type': instance.type,
  'front': instance.front,
  'back': instance.back,
  'options': instance.options,
  'correctOption': instance.correctOption,
  'explanation': instance.explanation,
  'difficulty': instance.difficulty,
  'tags': instance.tags,
  'createdAt': const _TimestampConverter().toJson(instance.createdAt),
  'generatedByAI': instance.generatedByAI,
  'order': instance.order,
};
