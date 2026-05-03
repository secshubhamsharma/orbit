import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// In-memory record of how a user performed on a chapter quiz.
/// Persists for the lifetime of the app session (no Firestore write needed).
class ChapterProgress {
  const ChapterProgress({
    required this.totalCards,
    required this.correctCount,
    required this.completedAt,
  });

  final int totalCards;
  final int correctCount;
  final DateTime completedAt;

  int get incorrectCount => totalCards - correctCount;
  double get accuracy => totalCards > 0 ? correctCount / totalCards : 0.0;
  int get accuracyPercent => (accuracy * 100).round();
  bool get isPerfect => totalCards > 0 && correctCount == totalCards;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ChapterProgressNotifier
    extends StateNotifier<Map<String, ChapterProgress>> {
  ChapterProgressNotifier() : super({});

  static String _key(String uploadId, String chapterId) =>
      '$uploadId:$chapterId';

  /// Persist (or overwrite) quiz results for a chapter.
  void save({
    required String uploadId,
    required String chapterId,
    required int totalCards,
    required int correctCount,
  }) {
    state = {
      ...state,
      _key(uploadId, chapterId): ChapterProgress(
        totalCards: totalCards,
        correctCount: correctCount,
        completedAt: DateTime.now(),
      ),
    };
  }

  ChapterProgress? getProgress(String uploadId, String chapterId) =>
      state[_key(uploadId, chapterId)];
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final chapterProgressProvider =
    StateNotifierProvider<ChapterProgressNotifier, Map<String, ChapterProgress>>(
  (_) => ChapterProgressNotifier(),
);
