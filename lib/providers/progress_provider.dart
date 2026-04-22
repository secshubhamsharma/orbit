import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

import 'auth_provider.dart';

/// All per-topic progress records for the currently signed-in user.
///
/// Returns an empty list when no user is authenticated or while auth is loading.
final allProgressProvider = FutureProvider<List<ProgressModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Future.value([]);
      return FirestoreService.instance.getAllProgress(user.uid);
    },
    loading: () => Future.value([]),
    error: (_, __) => Future.value([]),
  );
});

/// Up to 3 topics where the user's accuracy is below 70%, sorted by accuracy
/// ascending (worst first). Shown on the Home screen as weak-topic alerts.
final weakTopicsProvider = FutureProvider<List<ProgressModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Future.value([]);
      return FirestoreService.instance.getWeakTopics(user.uid);
    },
    loading: () => Future.value([]),
    error: (_, __) => Future.value([]),
  );
});

/// Progress document for a single topic, or `null` when the user has not yet
/// studied that topic.
///
/// Usage:
/// ```dart
/// ref.watch(topicProgressProvider((uid: user.uid, topicId: 't')))
/// ```
final topicProgressProvider =
    FutureProvider.family<ProgressModel?, ({String uid, String topicId})>(
  (_, args) =>
      FirestoreService.instance.getTopicProgress(args.uid, args.topicId),
);
