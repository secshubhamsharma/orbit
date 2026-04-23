import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/subject_model.dart';
import 'package:orbitapp/models/topic_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

/// All top-level domains, ordered by their `order` field.
final domainsProvider = FutureProvider<List<DomainModel>>(
  (_) => FirestoreService.instance.getDomains(),
);

/// Subjects that belong to [domainId], ordered by their `order` field.
final subjectsProvider =
    FutureProvider.family<List<SubjectModel>, String>(
  (_, domainId) => FirestoreService.instance.getSubjects(domainId),
);

/// Topics within a subject, keyed by a record of domainId + subjectId.
///
/// Usage:
/// ```dart
/// ref.watch(topicsProvider((domainId: 'school', subjectId: 'physics')))
/// ```
final topicsProvider = FutureProvider.family<List<TopicModel>,
    ({String domainId, String subjectId})>(
  (_, args) =>
      FirestoreService.instance.getTopics(args.domainId, args.subjectId),
);

/// Single topic document, or `null` when not found.
///
/// Usage:
/// ```dart
/// ref.watch(topicProvider((domainId: 'd', subjectId: 's', topicId: 't')))
/// ```
final topicProvider = FutureProvider.family<TopicModel?,
    ({String domainId, String subjectId, String topicId})>(
  (_, args) => FirestoreService.instance
      .getTopic(args.domainId, args.subjectId, args.topicId),
);

// Books for a subject
final booksProvider = FutureProvider.family<List<BookModel>,
    ({String domainId, String subjectId})>(
  (_, args) =>
      FirestoreService.instance.getBooks(args.domainId, args.subjectId),
);

// Single book
final bookProvider = FutureProvider.family<BookModel?,
    ({String domainId, String subjectId, String bookId})>(
  (_, args) =>
      FirestoreService.instance.getBook(args.domainId, args.subjectId, args.bookId),
);

// Chapters for a book
final chaptersProvider = FutureProvider.family<List<ChapterModel>,
    ({String domainId, String subjectId, String bookId})>(
  (_, args) => FirestoreService.instance
      .getChapters(args.domainId, args.subjectId, args.bookId),
);

// Single chapter
final chapterProvider = FutureProvider.family<ChapterModel?,
    ({String domainId, String subjectId, String bookId, String chapterId})>(
  (_, args) => FirestoreService.instance
      .getChapter(args.domainId, args.subjectId, args.bookId, args.chapterId),
);

// Chapter flashcard count
final chapterCardCountProvider = FutureProvider.family<int,
    ({String domainId, String subjectId, String bookId, String chapterId})>(
  (_, args) => FirestoreService.instance.getChapterFlashcardCount(
      args.domainId, args.subjectId, args.bookId, args.chapterId),
);
