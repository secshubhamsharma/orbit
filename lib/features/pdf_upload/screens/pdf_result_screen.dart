import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/models/review_session_model.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';
import 'package:orbitapp/providers/quiz_progress_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ─── Answer record ────────────────────────────────────────────────────────────

class _Answer {
  const _Answer({
    required this.cardId,
    required this.correct,
    required this.card,
  });
  final String cardId;
  final bool correct;
  final FlashcardModel card;
}

// ─── Entry point ──────────────────────────────────────────────────────────────

class PdfResultScreen extends ConsumerStatefulWidget {
  const PdfResultScreen({
    super.key,
    required this.uploadId,
    this.extra,
  });

  final String uploadId;
  final Map<String, String>? extra;

  @override
  ConsumerState<PdfResultScreen> createState() => _PdfResultScreenState();
}

class _PdfResultScreenState extends ConsumerState<PdfResultScreen> {
  List<FlashcardModel>? _retryCards;

  void _handleRetry(List<FlashcardModel> wrongCards) =>
      setState(() => _retryCards = wrongCards);

  @override
  Widget build(BuildContext context) {
    final chapterId = widget.extra?['chapterId'] ?? '';
    final chapterTitle = widget.extra?['chapterTitle'] ?? 'Quiz';

    final cardsAsync = ref.watch(
      chapterCardsProvider((uploadId: widget.uploadId, chapterId: chapterId)),
    );

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: cardsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary),
          ),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(
              chapterCardsProvider(
                  (uploadId: widget.uploadId, chapterId: chapterId)),
            ),
          ),
          data: (allCards) {
            final cards = _retryCards ?? allCards;
            if (cards.isEmpty) {
              return _EmptyView(onBack: () => context.pop());
            }
            return _QuizSession(
              key: ObjectKey(_retryCards),
              cards: cards,
              uploadId: widget.uploadId,
              chapterId: chapterId,
              chapterTitle: chapterTitle,
              onRetry: _handleRetry,
            );
          },
        ),
      ),
    );
  }
}

// ─── Quiz session ─────────────────────────────────────────────────────────────

class _QuizSession extends ConsumerStatefulWidget {
  const _QuizSession({
    super.key,
    required this.cards,
    required this.uploadId,
    required this.chapterId,
    required this.chapterTitle,
    required this.onRetry,
  });

  final List<FlashcardModel> cards;
  final String uploadId;
  final String chapterId;
  final String chapterTitle;
  final void Function(List<FlashcardModel> wrongCards) onRetry;

  @override
  ConsumerState<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends ConsumerState<_QuizSession>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int? _chosenIndex;
  bool _isAnswered = false;
  bool _showResults = false;
  late final DateTime _startedAt;

  final List<_Answer> _answers = [];

  late final AnimationController _cardCtrl;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardCtrl.forward();

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _btnFade = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);
    _btnSlide =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
            CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  FlashcardModel get _currentCard => widget.cards[_currentIndex];

  /// Returns the 4 options for the current card.
  List<String> get _options {
    final card = _currentCard;
    if (card.options.isNotEmpty) return card.options;
    // Fallback for any legacy true_false stored in Firestore
    return ['True', 'False', 'Cannot be determined', 'None of the above'];
  }

  /// Returns the correct answer index for the current card.
  int get _correctIndex {
    final card = _currentCard;
    if (card.correctOption != null) return card.correctOption!;
    // Fallback for legacy true_false
    return card.back.trim().toLowerCase() == 'true' ? 0 : 1;
  }

  // ── Interactions ─────────────────────────────────────────────────────────────

  Future<void> _onOptionTap(int index) async {
    if (_isAnswered) return;

    HapticFeedback.lightImpact();
    if (index != _correctIndex) HapticFeedback.heavyImpact();

    setState(() {
      _chosenIndex = index;
      _isAnswered = true;
    });

    await Future.delayed(const Duration(milliseconds: 380));
    if (mounted) _btnCtrl.forward();
  }

  Future<void> _goNext() async {
    _answers.add(_Answer(
      cardId: _currentCard.id,
      correct: _chosenIndex == _correctIndex,
      card: _currentCard,
    ));

    await _cardCtrl.reverse();
    if (!mounted) return;

    if (_currentIndex >= widget.cards.length - 1) {
      _finish();
      return;
    }

    setState(() {
      _currentIndex++;
      _chosenIndex = null;
      _isAnswered = false;
    });
    _btnCtrl.reset();
    _cardCtrl.forward();
  }

  void _finish() {
    final total        = _answers.length;
    final correctCount = _answers.where((a) => a.correct).length;

    // 1. Update in-memory provider (used by PDF preview screen cards badge)
    ref.read(chapterProgressProvider.notifier).save(
      uploadId:     widget.uploadId,
      chapterId:    widget.chapterId,
      totalCards:   total,
      correctCount: correctCount,
    );

    // 2. Persist to Firestore (fire-and-forget so UI isn't blocked)
    _persistToFirestore(total: total, correctCount: correctCount);

    setState(() => _showResults = true);
  }

  Future<void> _persistToFirestore({
    required int total,
    required int correctCount,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty || total == 0) return;

    final completedAt     = DateTime.now();
    final durationSeconds = completedAt.difference(_startedAt).inSeconds;
    final accuracy        = correctCount / total;

    try {
      // ── Save session history ─────────────────────────────────────────────
      final session = ReviewSessionModel(
        sessionId:       '${uid}_${completedAt.millisecondsSinceEpoch}',
        topicId:         widget.chapterId,
        topicName:       widget.chapterTitle,
        domainId:        'uploads',
        startedAt:       _startedAt,
        completedAt:     completedAt,
        durationSeconds: durationSeconds,
        cardsReviewed:   total,
        correctCount:    correctCount,
        incorrectCount:  total - correctCount,
        accuracy:        accuracy,
        ratings: {
          'again': total - correctCount,
          'hard':  0,
          'good':  correctCount,
          'easy':  0,
        },
        xpEarned: correctCount * 2 + 10,
      );
      await FirestoreService.instance.saveSession(uid, session);

      // ── Update topic progress ────────────────────────────────────────────
      await FirestoreService.instance.updateTopicProgress(
        uid:             uid,
        topicId:         widget.chapterId,
        topicName:       widget.chapterTitle,
        domainId:        'uploads',
        cardsReviewed:   total,
        correctCount:    correctCount,
        durationSeconds: durationSeconds,
        // No SM-2 schedules for PDF quizzes; mastery derived from accuracy
      );

      // ── Update global user stats, streak & leaderboard ──────────────────
      final fbUser = FirebaseAuth.instance.currentUser;
      await FirestoreService.instance.updateUserStats(
        uid:             uid,
        cardsReviewed:   total,
        sessionAccuracy: accuracy,
        durationSeconds: durationSeconds,
        displayName:     fbUser?.displayName ?? '',
        photoUrl:        fbUser?.photoURL,
      );
    } catch (e) {
      assert(() {
        // ignore: avoid_print
        print('[PdfResultScreen] _persistToFirestore error: $e');
        return true;
      }());
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      final correct = _answers.where((a) => a.correct).length;
      final wrongCards =
          _answers.where((a) => !a.correct).map((a) => a.card).toList();
      return _ResultsScreen(
        chapterTitle: widget.chapterTitle,
        correct: correct,
        total: _answers.length,
        wrongCards: wrongCards,
        onRetry: () => widget.onRetry(wrongCards),
        onBack: () => context.pop(),
        onUploads: () => context.go('/home/profile/uploads'),
      );
    }

    final total = widget.cards.length;
    final progress = _currentIndex / total;

    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.kSurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.kBorder),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.kTextSecondary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Chapter title + question counter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chapterTitle,
                          style: AppTextStyles.labelLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Question ${_currentIndex + 1} of $total',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  // Live score pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: Text(
                      '${_answers.where((a) => a.correct).length}'
                      ' / ${_answers.length}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.kPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: AppColors.kSurfaceVariant,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.kPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── MCQ card ──────────────────────────────────────────────────────────
        Expanded(
          child: FadeTransition(
            opacity: _cardFade,
            child: SlideTransition(
              position: _cardSlide,
              child: _QuizCard(
                card: _currentCard,
                options: _options,
                correctIndex: _correctIndex,
                chosenIndex: _chosenIndex,
                isAnswered: _isAnswered,
                onOptionTap: _onOptionTap,
              ),
            ),
          ),
        ),

        // ── Next / See Results button ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _btnCtrl,
          builder: (_, __) => _btnCtrl.value == 0
              ? const SizedBox(height: 88)
              : FadeTransition(
                  opacity: _btnFade,
                  child: SlideTransition(
                    position: _btnSlide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePadding,
                          AppSpacing.md,
                          AppSpacing.pagePadding,
                          AppSpacing.xl),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _goNext,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd),
                            ),
                          ),
                          child: Text(
                            _currentIndex < widget.cards.length - 1
                                ? 'Next Question'
                                : 'See Results',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── MCQ card widget ──────────────────────────────────────────────────────────

class _QuizCard extends StatefulWidget {
  const _QuizCard({
    required this.card,
    required this.options,
    required this.correctIndex,
    required this.chosenIndex,
    required this.isAnswered,
    required this.onOptionTap,
  });

  final FlashcardModel card;
  final List<String> options;
  final int correctIndex;
  final int? chosenIndex;
  final bool isAnswered;
  final void Function(int) onOptionTap;

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _optCtrl;

  @override
  void initState() {
    super.initState();
    _optCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _optCtrl.forward();
  }

  @override
  void dispose() {
    _optCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Question box ─────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C1F2E), Color(0xFF12141F)],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    widget.card.difficulty.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.kPrimary,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Question text
                Text(
                  widget.card.front,
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600, height: 1.55),
                ),
              ],
            ),
          ),

          // ── Explanation (shown after answering) ──────────────────────────────
          if (widget.isAnswered &&
              widget.card.explanation != null &&
              widget.card.explanation!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                    color: AppColors.kPrimary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: AppColors.kPrimary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      widget.card.explanation!,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.kTextSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // ── Options ───────────────────────────────────────────────────────────
          ...List.generate(widget.options.length, (i) {
            final start = i * 0.11;
            final end = (start + 0.55).clamp(0.0, 1.0);
            final anim = CurvedAnimation(
              parent: _optCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            );

            _OptionState state = _OptionState.idle;
            if (widget.isAnswered) {
              if (i == widget.correctIndex) {
                state = _OptionState.correct;
              } else if (i == widget.chosenIndex) {
                state = _OptionState.wrong;
              } else {
                state = _OptionState.dimmed;
              }
            }

            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                        .animate(anim),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OptionTile(
                    label: String.fromCharCode(65 + i), // A B C D
                    text: widget.options[i],
                    state: state,
                    onTap: widget.isAnswered ? null : () => widget.onOptionTap(i),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Option tile ──────────────────────────────────────────────────────────────

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color labelBg;
    final Color labelColor;
    final Color textColor;
    final Widget? trailing;

    switch (state) {
      case _OptionState.correct:
        borderColor = AppColors.kSuccess;
        bgColor = AppColors.kSuccess.withValues(alpha: 0.10);
        labelBg = AppColors.kSuccess;
        labelColor = Colors.white;
        textColor = AppColors.kSuccess;
        trailing = const Icon(Icons.check_circle_rounded,
            size: 20, color: AppColors.kSuccess);
      case _OptionState.wrong:
        borderColor = AppColors.kError;
        bgColor = AppColors.kError.withValues(alpha: 0.10);
        labelBg = AppColors.kError;
        labelColor = Colors.white;
        textColor = AppColors.kError;
        trailing =
            const Icon(Icons.cancel_rounded, size: 20, color: AppColors.kError);
      case _OptionState.dimmed:
        borderColor = AppColors.kBorder.withValues(alpha: 0.35);
        bgColor = Colors.transparent;
        labelBg = AppColors.kSurfaceVariant;
        labelColor = AppColors.kTextDisabled;
        textColor = AppColors.kTextDisabled;
        trailing = null;
      case _OptionState.idle:
        borderColor = AppColors.kBorder;
        bgColor = AppColors.kSurface;
        labelBg = AppColors.kSurfaceVariant;
        labelColor = AppColors.kTextSecondary;
        textColor = AppColors.kTextPrimary;
        trailing = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: borderColor,
          width: state == _OptionState.idle ? 1.0 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                // Letter badge (A / B / C / D)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Option text
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 240),
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                    child: Text(text),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Results screen ───────────────────────────────────────────────────────────

class _ResultsScreen extends StatefulWidget {
  const _ResultsScreen({
    required this.chapterTitle,
    required this.correct,
    required this.total,
    required this.wrongCards,
    required this.onRetry,
    required this.onBack,
    required this.onUploads,
  });

  final String chapterTitle;
  final int correct;
  final int total;
  final List<FlashcardModel> wrongCards;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final VoidCallback onUploads;

  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = widget.total > 0 ? widget.correct / widget.total : 0.0;
    final pct = (accuracy * 100).round();

    final Color ringColor;
    final String emoji;
    final String headline;
    if (pct >= 75) {
      ringColor = AppColors.kSuccess;
      emoji = '🎉';
      headline = 'Excellent!';
    } else if (pct >= 50) {
      ringColor = AppColors.kWarning;
      emoji = '👍';
      headline = 'Good effort!';
    } else {
      ringColor = AppColors.kError;
      emoji = '💪';
      headline = 'Keep practicing!';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Emoji + headline
            Text(emoji, style: const TextStyle(fontSize: 54)),
            const SizedBox(height: AppSpacing.md),
            Text(headline, style: AppTextStyles.headingLarge),
            const SizedBox(height: 4),
            Text(
              widget.chapterTitle,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Accuracy ring ──────────────────────────────────────────────────
            SizedBox(
              width: 168,
              height: 168,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: accuracy),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) => CustomPaint(
                      size: const Size(168, 168),
                      painter: _RingPainter(
                        progress: value,
                        color: ringColor,
                        trackColor: AppColors.kSurfaceVariant,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (_, value, __) => Text(
                          '$value%',
                          style: AppTextStyles.displayMedium
                              .copyWith(color: ringColor),
                        ),
                      ),
                      Text('accuracy', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Stat cards ─────────────────────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Correct',
                  value: '${widget.correct}',
                  color: AppColors.kSuccess,
                ),
                const SizedBox(width: AppSpacing.md),
                _StatCard(
                  icon: Icons.cancel_rounded,
                  label: 'Wrong',
                  value: '${widget.total - widget.correct}',
                  color: AppColors.kError,
                ),
                const SizedBox(width: AppSpacing.md),
                _StatCard(
                  icon: Icons.quiz_rounded,
                  label: 'Total',
                  value: '${widget.total}',
                  color: AppColors.kPrimary,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Retry wrong questions ──────────────────────────────────────────
            if (widget.wrongCards.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label:
                      Text('Retry ${widget.wrongCards.length} Wrong Questions'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kError.withValues(alpha: 0.12),
                    foregroundColor: AppColors.kError,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      side: BorderSide(
                          color: AppColors.kError.withValues(alpha: 0.35)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Back to chapters ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.onBack,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text('Back to Chapters',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white)),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── My uploads ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onUploads,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kTextSecondary,
                  side: const BorderSide(color: AppColors.kBorder),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child:
                    Text('My Uploads', style: AppTextStyles.labelMedium),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headingSmall.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ─── Ring painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 13.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined,
                size: 52, color: AppColors.kTextDisabled),
            const SizedBox(height: AppSpacing.lg),
            Text('No questions found', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onBack,
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.kPrimary),
              child: Text('Go Back',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 52, color: AppColors.kError),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onRetry,
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.kPrimary),
              child: Text('Retry',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
