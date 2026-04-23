import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_model.freezed.dart';
part 'book_model.g.dart';

/// A textbook stored under `domains/{domainId}/subjects/{subjectId}/books/{bookId}`.
@freezed
class BookModel with _$BookModel {
  const factory BookModel({
    required String id,
    required String title,
    required String domainId,
    required String subjectId,
    @Default([]) List<String> authors,
    @Default('') String coverUrl,
    @Default('') String googleBooksId,
    @Default('') String isbn,
    @Default('') String publisher,
    @Default('') String description,
    @Default(0) int totalChapters,
    @Default([]) List<String> examTags,
    @Default(0) int order,
  }) = _BookModel;

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);
}
