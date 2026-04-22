// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  type: json['type'] as String? ?? 'general',
  title: json['title'] as String,
  body: json['body'] as String,
  data: json['data'] as Map<String, dynamic>? ?? const {},
  createdAt: const _TimestampConverter().fromJson(json['createdAt']),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'body': instance.body,
  'data': instance.data,
  'createdAt': const _TimestampConverter().toJson(instance.createdAt),
  'isRead': instance.isRead,
};
