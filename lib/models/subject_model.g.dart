// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectModelImpl _$$SubjectModelImplFromJson(Map<String, dynamic> json) =>
    _$SubjectModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      domainId: json['domainId'] as String,
      applicableExams:
          (json['applicableExams'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      iconUrl: json['iconUrl'] as String? ?? '',
      totalTopics: (json['totalTopics'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SubjectModelImplToJson(_$SubjectModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'domainId': instance.domainId,
      'applicableExams': instance.applicableExams,
      'iconUrl': instance.iconUrl,
      'totalTopics': instance.totalTopics,
      'order': instance.order,
    };
