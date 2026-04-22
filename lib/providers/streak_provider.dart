import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/streak_model.dart';

import 'user_provider.dart';

/// Derives a [StreakModel] from the live Firestore user document so any widget
/// that cares about streaks re-renders automatically when the document changes.
///
/// Falls back to a zeroed-out [StreakModel] while loading or when the user is
/// signed out — callers never need to handle a null case.
final streakProvider = Provider<StreakModel>((ref) {
  final userAsync = ref.watch(userProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return const StreakModel();
      return StreakModel(
        currentStreak: user.currentStreak,
        longestStreak: user.longestStreak,
        lastStudiedDate: user.lastStudiedDate,
        streakFreezeAvailable: user.streakFreezeAvailable,
      );
    },
    loading: () => const StreakModel(),
    error: (_, __) => const StreakModel(),
  );
});
