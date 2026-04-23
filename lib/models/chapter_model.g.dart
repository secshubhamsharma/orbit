// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChapterModelImpl _$$ChapterModelImplFromJson(Map<String, dynamic> json) =>
    _$ChapterModelImpl(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      subjectId: json['subjectId'] as String,
      domainId: json['domainId'] as String,
      chapterNumber: (json['chapterNumber'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      totalCards: (json['totalCards'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 10,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      generatedByAI: json['generatedByAI'] as bool? ?? true,
    );

Map<String, dynamic> _$$ChapterModelImplToJson(_$ChapterModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'subjectId': instance.subjectId,
      'domainId': instance.domainId,
      'chapterNumber': instance.chapterNumber,
      'name': instance.name,
      'description': instance.description,
      'difficulty': instance.difficulty,
      'totalCards': instance.totalCards,
      'estimatedMinutes': instance.estimatedMinutes,
      'tags': instance.tags,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'generatedByAI': instance.generatedByAI,
    };
