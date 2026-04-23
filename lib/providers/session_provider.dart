import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/models/card_schedule_model.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/models/review_session_model.dart';
import 'package:orbitapp/services/firestore_service.dart';
import 'package:orbitapp/services/srs_service.dart';

// ---------------------------------------------------------------------------
// Session arguments — passed via GoRouter.extra when pushing /review/:id
// ---------------------------------------------------------------------------

class SessionArgs {
  final String domainId;
  final String subjectId;
  final String bookId;
  final String chapterId;
  final String chapterName;
  final String bookTitle;

  const SessionArgs({
    required this.domainId,
    required this.subjectId,
    required this.bookId,
    required this.chapterId,
    required this.chapterName,
    required this.bookTitle,
  });
}

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

class SessionState {
  final List<FlashcardModel> cards;
  final int currentIndex;
  final bool isFlipped;
  final Map<String, String> ratings; // cardId → 'again'|'hard'|'good'|'easy'
  final bool isComplete;
  final bool isLoading;
  final String? error;
  final DateTime startedAt;

  const SessionState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isFlipped = false,
    this.ratings = const {},
    this.isComplete = false,
    this.isLoading = true,
    this.error,
    required this.startedAt,
  });

  SessionState copyWith({
    List<FlashcardModel>? cards,
    int? currentIndex,
    bool? isFlipped,
    Map<String, String>? ratings,
    bool? isComplete,
    bool? isLoading,
    String? error,
    DateTime? startedAt,
  }) {
    return SessionState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      ratings: ratings ?? this.ratings,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  // Convenience getters
  FlashcardModel? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;

  bool get hasCards => cards.isNotEmpty;

  int get correct =>
      ratings.values.where((r) => r == 'good' || r == 'easy').length;

  int get incorrect =>
      ratings.values.where((r) => r == 'again').length;

  double get accuracy =>
      ratings.isEmpty ? 0.0 : correct / ratings.length;

  int get xpEarned {
    int xp = 0;
    for (final r in ratings.values) {
      if (r == 'good' || r == 'easy') {
        xp += 2;
      } else if (r == 'hard') {
        xp += 1;
      }
    }
    xp += 10; // session completion bonus
    if (ratings.isNotEmpty && correct == ratings.length) xp += 20; // perfect
    return xp;
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SessionNotifier extends StateNotifier<SessionState> {
  final SessionArgs _args;
  final String _uid;

  SessionNotifier({required SessionArgs args, required String uid})
      : _args = args,
        _uid = uid,
        super(SessionState(startedAt: DateTime.now())) {
    _loadCards();
  }

  Future<void> _loadCards() async {
    state = state.copyWith(isLoading: true);
    try {
      final cards = await FirestoreService.instance.getChapterFlashcards(
        _args.domainId,
        _args.subjectId,
        _args.bookId,
        _args.chapterId,
      );

      // Shuffle for variety on repeated sessions
      final shuffled = List<FlashcardModel>.from(cards)..shuffle();

      state = state.copyWith(cards: shuffled, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Flip the current card front ↔ back.
  void flip() {
    if (state.isLoading || state.isComplete) return;
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  /// Rate the current card and advance to the next one.
  Future<void> rate(String rating) async {
    final card = state.currentCard;
    if (card == null) return;

    final newRatings = Map<String, String>.from(state.ratings)
      ..[card.id] = rating;

    final nextIndex = state.currentIndex + 1;
    final isComplete = nextIndex >= state.cards.length;

    state = state.copyWith(
      ratings: newRatings,
      currentIndex: nextIndex,
      isFlipped: false,
      isComplete: isComplete,
    );

    if (isComplete) {
      // Fire-and-forget — don't block UI for Firestore writes
      _persistSession(newRatings);
    }
  }

  Future<void> _persistSession(Map<String, String> ratings) async {
    if (_uid.isEmpty) return;

    try {
      // Load existing schedules for all reviewed cards
      final existing = await FirestoreService.instance
          .getAllSchedules(_uid, _args.chapterId);
      final scheduleMap = {for (final s in existing) s.cardId: s};

      // Apply SM-2 to each card
      final updated = state.cards.map((card) {
        final schedule = scheduleMap[card.id] ??
            CardScheduleModel.newCard(
              cardId: card.id,
              topicId: _args.chapterId,
              domainId: _args.domainId,
            );
        final rating = ratings[card.id] ?? 'again';
        return SrsService.instance.applyRating(schedule, rating);
      }).toList();

      await FirestoreService.instance.saveScheduleBatch(_uid, updated);

      // Save review session summary
      final total = ratings.length;
      final correct =
          ratings.values.where((r) => r == 'good' || r == 'easy').length;

      final session = ReviewSessionModel(
        sessionId: '${_uid}_${DateTime.now().millisecondsSinceEpoch}',
        topicId: _args.chapterId,
        topicName: '${_args.bookTitle} — ${_args.chapterName}',
        domainId: _args.domainId,
        startedAt: state.startedAt,
        completedAt: DateTime.now(),
        durationSeconds:
            DateTime.now().difference(state.startedAt).inSeconds,
        cardsReviewed: total,
        correctCount: correct,
        incorrectCount: total - correct,
        accuracy: total > 0 ? correct / total : 0.0,
        ratings: {
          'again': ratings.values.where((r) => r == 'again').length,
          'hard': ratings.values.where((r) => r == 'hard').length,
          'good': ratings.values.where((r) => r == 'good').length,
          'easy': ratings.values.where((r) => r == 'easy').length,
        },
        xpEarned: state.xpEarned,
      );

      await FirestoreService.instance.saveSession(_uid, session);
    } catch (_) {
      // Silently fail — don't disrupt the result screen for persistence errors
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final sessionProvider =
    StateNotifierProvider.family<SessionNotifier, SessionState, SessionArgs>(
  (ref, args) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return SessionNotifier(args: args, uid: uid);
  },
);
