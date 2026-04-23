import 'package:freezed_annotation/freezed_annotation.dart';

import 'timestamp_converter.dart';

part 'chapter_model.freezed.dart';
part 'chapter_model.g.dart';

/// One chapter of a book, stored under
/// `domains/{domainId}/subjects/{subjectId}/books/{bookId}/chapters/{chapterId}`.
@freezed
class ChapterModel with _$ChapterModel {
  const factory ChapterModel({
    required String id,
    required String bookId,
    required String subjectId,
    required String domainId,
    @Default(0) int chapterNumber,
    required String name,
    @Default('') String description,
    @Default('beginner') String difficulty,
    @Default(0) int totalCards,
    @Default(10) int estimatedMinutes,
    @Default([]) List<String> tags,
    @TimestampConverter() required DateTime createdAt,
    @Default(true) bool generatedByAI,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);
}
