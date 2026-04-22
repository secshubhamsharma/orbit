import 'package:flutter_riverpod/flutter_riverpod.dart';

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
