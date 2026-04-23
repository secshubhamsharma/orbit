// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookModelImpl _$$BookModelImplFromJson(
  Map<String, dynamic> json,
) => _$BookModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  domainId: json['domainId'] as String,
  subjectId: json['subjectId'] as String,
  authors:
      (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  coverUrl: json['coverUrl'] as String? ?? '',
  googleBooksId: json['googleBooksId'] as String? ?? '',
  isbn: json['isbn'] as String? ?? '',
  publisher: json['publisher'] as String? ?? '',
  description: json['description'] as String? ?? '',
  totalChapters: (json['totalChapters'] as num?)?.toInt() ?? 0,
  examTags:
      (json['examTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$BookModelImplToJson(_$BookModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'domainId': instance.domainId,
      'subjectId': instance.subjectId,
      'authors': instance.authors,
      'coverUrl': instance.coverUrl,
      'googleBooksId': instance.googleBooksId,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'description': instance.description,
      'totalChapters': instance.totalChapters,
      'examTags': instance.examTags,
      'order': instance.order,
    };
