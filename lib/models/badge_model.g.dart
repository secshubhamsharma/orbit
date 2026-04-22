// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BadgeModelImpl _$$BadgeModelImplFromJson(Map<String, dynamic> json) =>
    _$BadgeModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconEmoji: json['iconEmoji'] as String? ?? '🏆',
      condition: json['condition'] as String,
      earnedAt: const _NullableTimestampConverter().fromJson(json['earnedAt']),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      progressTarget: (json['progressTarget'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BadgeModelImplToJson(_$BadgeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconEmoji': instance.iconEmoji,
      'condition': instance.condition,
      'earnedAt': const _NullableTimestampConverter().toJson(instance.earnedAt),
      'progress': instance.progress,
      'progressTarget': instance.progressTarget,
    };
