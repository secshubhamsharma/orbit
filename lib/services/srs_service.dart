import 'package:orbitapp/models/card_schedule_model.dart';

/// SM-2 spaced repetition algorithm implementation.
///
/// Rating → quality mapping:
///   again → 0   (failed, resets repetitions)
///   hard  → 3
///   good  → 4
///   easy  → 5
class SrsService {
  SrsService._();
  static final SrsService instance = SrsService._();

  /// Applies an SM-2 rating to an existing [schedule] and returns the updated
  /// schedule with new interval, ease factor, and next review date.
  CardScheduleModel applyRating(CardScheduleModel schedule, String rating) {
    final quality = _toQuality(rating);

    int repetitions = schedule.repetitions;
    int interval = schedule.interval;
    double easeFactor = schedule.easeFactor;

    if (quality < 3) {
      // Failed — reset streak, review again tomorrow
      repetitions = 0;
      interval = 1;
    } else {
      // Successful recall — advance interval
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetitions += 1;
    }

    // Update ease factor (clamped to minimum 1.3)
    easeFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (easeFactor < 1.3) easeFactor = 1.3;

    final now = DateTime.now();

    return schedule.copyWith(
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      nextReviewDate: now.add(Duration(days: interval)),
      lastReviewDate: now,
      lastRating: rating,
      totalReviews: schedule.totalReviews + 1,
      correctCount: quality >= 3
          ? schedule.correctCount + 1
          : schedule.correctCount,
      incorrectCount: quality < 3
          ? schedule.incorrectCount + 1
          : schedule.incorrectCount,
    );
  }

  /// Days until next review for a given rating from a fresh card (no history).
  int previewInterval(String rating) {
    return switch (rating) {
      'again' => 1,
      'hard' => 1,
      'good' => 1,
      'easy' => 4,
      _ => 1,
    };
  }

  int _toQuality(String rating) {
    return switch (rating) {
      'again' => 0,
      'hard' => 3,
      'good' => 4,
      'easy' => 5,
      _ => 0,
    };
  }
}
