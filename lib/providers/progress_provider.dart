import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

import 'auth_provider.dart';

/// All per-topic progress records for the currently signed-in user.
///
/// Uses a real-time Firestore stream so the progress screen and home screen
/// automatically reflect changes immediately after each quiz session completes.
final allProgressProvider = StreamProvider<List<ProgressModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirestoreService.instance.allProgressStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Up to 3 topics where the user's accuracy is below 70%, sorted by accuracy
/// ascending (worst first). Shown on the Home screen as weak-topic alerts.
///
/// Real-time stream — updates automatically after each session.
final weakTopicsProvider = StreamProvider<List<ProgressModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirestoreService.instance.weakTopicsStream(user.uid);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
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
