import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/card_schedule_model.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

/// All flashcards for a topic, ordered by the `order` field.
///
/// Usage:
/// ```dart
/// ref.watch(flashcardsProvider((domainId: 'd', subjectId: 's', topicId: 't')))
/// ```
final flashcardsProvider = FutureProvider.family<List<FlashcardModel>,
    ({String domainId, String subjectId, String topicId})>(
  (_, args) => FirestoreService.instance
      .getFlashcards(args.domainId, args.subjectId, args.topicId),
);

/// Total number of flashcards for a topic. Useful for showing a count badge
/// before the full list is fetched.
final flashcardCountProvider = FutureProvider.family<int,
    ({String domainId, String subjectId, String topicId})>(
  (_, args) => FirestoreService.instance
      .getFlashcardCount(args.domainId, args.subjectId, args.topicId),
);

/// Cards that are due for review right now (nextReviewDate <= now) for the
/// given user + topic pair. The list is pre-sorted by nextReviewDate so the
/// most overdue cards are presented first.
///
/// Usage:
/// ```dart
/// ref.watch(dueCardsProvider((uid: user.uid, topicId: 't')))
/// ```
final dueCardsProvider = FutureProvider.family<List<CardScheduleModel>,
    ({String uid, String topicId})>(
  (_, args) =>
      FirestoreService.instance.getDueCards(args.uid, args.topicId),
);
