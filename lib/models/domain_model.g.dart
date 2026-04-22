// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DomainModelImpl _$$DomainModelImplFromJson(Map<String, dynamic> json) =>
    _$DomainModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String? ?? '',
      colorHex: json['colorHex'] as String? ?? '#7C6FE8',
      subDomains:
          (json['subDomains'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      totalTopics: (json['totalTopics'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DomainModelImplToJson(_$DomainModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'colorHex': instance.colorHex,
      'subDomains': instance.subDomains,
      'totalTopics': instance.totalTopics,
      'order': instance.order,
    };
