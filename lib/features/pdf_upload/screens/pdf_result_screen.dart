import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';

// ---------------------------------------------------------------------------
// Screen entry point
// ---------------------------------------------------------------------------

class PdfResultScreen extends ConsumerWidget {
  final String uploadId;
  final Map<String, String>? extra;

  const PdfResultScreen({
    super.key,
    required this.uploadId,
    this.extra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterId = extra?['chapterId'] ?? '';
    final chapterTitle = extra?['chapterTitle'] ?? 'Flashcards';

    final cardsAsync = ref.watch(chapterCardsProvider(
      (uploadId: uploadId, chapterId: chapterId),
    ));

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: cardsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary),
          ),
          error: (e, _) => _ErrorView(
            onRetry: () => ref.invalidate(chapterCardsProvider(
              (uploadId: uploadId, chapterId: chapterId),
            )),
          ),
          data: (rawCards) {
            final cards = rawCards.cast<FlashcardModel>();
            if (cards.isEmpty) {
              return _EmptyView(chapterTitle: chapterTitle);
            }
            return _StudyView(
              cards: cards,
              chapterTitle: chapterTitle,
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Study view — the full flashcard session
// ---------------------------------------------------------------------------

class _StudyView extends StatefulWidget {
  const _StudyView({required this.cards, required this.chapterTitle});
  final List<FlashcardModel> cards;
  final String chapterTitle;

  @override
  State<_StudyView> createState() => _StudyViewState();
}

class _StudyViewState extends State<_StudyView>
    with TickerProviderStateMixin {
  int _index = 0;
  bool _isFlipped = false;
  final Map<String, String> _ratings = {};

  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideOut;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, 0),
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn));
    _slideIn = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipCtrl.isAnimating) return;
    if (_isFlipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  Future<void> _rate(String rating) async {
    final card = widget.cards[_index];
    _ratings[card.id] = rating;

    if (_index >= widget.cards.length - 1) {
      // Session done
      setState(() => _index = widget.cards.length);
      return;
    }

    // Slide out current, slide in next
    await _slideCtrl.forward();
    setState(() {
      _index++;
      _isFlipped = false;
    });
    _flipCtrl.reset();
    _slideCtrl.reset();
  }

  bool get _isDone => _index >= widget.cards.length;

  @override
  Widget build(BuildContext context) {
    if (_isDone) {
      return _ResultSummary(
        cards: widget.cards,
        ratings: _ratings,
        chapterTitle: widget.chapterTitle,
      );
    }

    final card = widget.cards[_index];
    final progress = (_index) / widget.cards.length;

    return Column(
      children: [
        // ── Header ────────────────────────────────────────────────────────
        _Header(
          chapterTitle: widget.chapterTitle,
          current: _index + 1,
          total: widget.cards.length,
          progress: progress,
        ),

        // ── Card ──────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding),
            child: Stack(
              children: [
                // Slide out animation
                if (_slideCtrl.isAnimating)
                  SlideTransition(
                    position: _slideOut,
                    child: _FlipCard(
                      card: card,
                      flipAnim: _flipAnim,
                      isFlipped: _isFlipped,
                      onTap: _flip,
                    ),
                  ),
                // Slide in animation / static card
                SlideTransition(
                  position: _slideCtrl.isAnimating
                      ? _slideIn
                      : const AlwaysStoppedAnimation(Offset.zero),
                  child: _FlipCard(
                    card: _slideCtrl.isAnimating && _index + 1 < widget.cards.length
                        ? widget.cards[_index + 1]
                        : card,
                    flipAnim: _slideCtrl.isAnimating
                        ? const AlwaysStoppedAnimation(0)
                        : _flipAnim,
                    isFlipped: _slideCtrl.isAnimating ? false : _isFlipped,
                    onTap: _flip,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Hint ──────────────────────────────────────────────────────────
        if (!_isFlipped)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              'Tap the card to reveal the answer',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.kTextDisabled),
            ),
          ),

        // ── Rating buttons ────────────────────────────────────────────────
        if (_isFlipped)
          _RatingBar(onRate: _rate),

        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header with progress
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.chapterTitle,
    required this.current,
    required this.total,
    required this.progress,
  });
  final String chapterTitle;
  final int current;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.kSurface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.kBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: AppColors.kTextPrimary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapterTitle,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('$current / $total',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.kTextSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Progress bar
        ClipRRect(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.kSurfaceVariant,
            valueColor:
                const AlwaysStoppedAnimation(AppColors.kPrimary),
            minHeight: 3,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Flip card
// ---------------------------------------------------------------------------

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.card,
    required this.flipAnim,
    required this.isFlipped,
    required this.onTap,
  });
  final FlashcardModel card;
  final Animation<double> flipAnim;
  final bool isFlipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: flipAnim,
        builder: (_, __) {
          final angle = flipAnim.value * math.pi;
          final isFrontVisible = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFrontVisible
                ? _CardFace(
                    text: card.front,
                    label: 'QUESTION',
                    labelColor: AppColors.kPrimary,
                    isFront: true,
                    difficulty: card.difficulty,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardFace(
                      text: card.back,
                      label: 'ANSWER',
                      labelColor: AppColors.kSuccess,
                      isFront: false,
                      explanation: card.explanation,
                      difficulty: card.difficulty,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.text,
    required this.label,
    required this.labelColor,
    required this.isFront,
    this.explanation,
    required this.difficulty,
  });
  final String text;
  final String label;
  final Color labelColor;
  final bool isFront;
  final String? explanation;
  final String difficulty;

  Color get _difficultyColor {
    return switch (difficulty) {
      'easy' => AppColors.kDifficultyEasy,
      'hard' => AppColors.kDifficultyHard,
      _ => AppColors.kDifficultyMedium,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: isFront ? AppColors.kSurface : AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isFront
              ? AppColors.kBorder
              : AppColors.kPrimary.withValues(alpha: 0.3),
          width: isFront ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: labelColor.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(label,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: labelColor, letterSpacing: 0.8)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    difficulty[0].toUpperCase() + difficulty.substring(1),
                    style: AppTextStyles.labelSmall
                        .copyWith(color: _difficultyColor),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Card text
            Text(
              text,
              style: AppTextStyles.cardFront,
              textAlign: TextAlign.center,
            ),

            if (!isFront && explanation != null &&
                explanation!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.kBorder),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.kTextSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      explanation!,
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            ],

            const Spacer(),

            // Tap hint
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded,
                      size: 14, color: AppColors.kTextDisabled),
                  const SizedBox(width: 4),
                  Text(
                    isFront ? 'Tap to reveal answer' : 'Tap to flip back',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kTextDisabled),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rating bar
// ---------------------------------------------------------------------------

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.onRate});
  final void Function(String) onRate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          _RateBtn(
              label: 'Again',
              color: AppColors.kError,
              icon: Icons.replay_rounded,
              onTap: () => onRate('again')),
          const SizedBox(width: AppSpacing.sm),
          _RateBtn(
              label: 'Hard',
              color: AppColors.kWarning,
              icon: Icons.sentiment_dissatisfied_rounded,
              onTap: () => onRate('hard')),
          const SizedBox(width: AppSpacing.sm),
          _RateBtn(
              label: 'Good',
              color: AppColors.kPrimary,
              icon: Icons.sentiment_satisfied_rounded,
              onTap: () => onRate('good')),
          const SizedBox(width: AppSpacing.sm),
          _RateBtn(
              label: 'Easy',
              color: AppColors.kSuccess,
              icon: Icons.sentiment_very_satisfied_rounded,
              onTap: () => onRate('easy')),
        ],
      ),
    );
  }
}

class _RateBtn extends StatefulWidget {
  const _RateBtn({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_RateBtn> createState() => _RateBtnState();
}

class _RateBtnState extends State<_RateBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: widget.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 20, color: widget.color),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: widget.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result summary (after all cards are rated)
// ---------------------------------------------------------------------------

class _ResultSummary extends StatefulWidget {
  const _ResultSummary({
    required this.cards,
    required this.ratings,
    required this.chapterTitle,
  });
  final List<FlashcardModel> cards;
  final Map<String, String> ratings;
  final String chapterTitle;

  @override
  State<_ResultSummary> createState() => _ResultSummaryState();
}

class _ResultSummaryState extends State<_ResultSummary>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.ratings.length;
    final correct = widget.ratings.values
        .where((r) => r == 'good' || r == 'easy')
        .length;
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;

    final accColor = accuracy >= 80
        ? AppColors.kSuccess
        : accuracy >= 60
            ? AppColors.kWarning
            : AppColors.kError;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: accColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    accuracy >= 80
                        ? Icons.emoji_events_rounded
                        : accuracy >= 60
                            ? Icons.thumb_up_rounded
                            : Icons.refresh_rounded,
                    size: 36,
                    color: accColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Chapter Complete',
                    style: AppTextStyles.headingMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.chapterTitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          FadeTransition(
            opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.kSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatCell(
                      label: 'Accuracy',
                      value: '$accuracy%',
                      color: accColor),
                  _StatCell(
                      label: 'Correct',
                      value: '$correct',
                      color: AppColors.kSuccess),
                  _StatCell(
                      label: 'Total',
                      value: '$total',
                      color: AppColors.kTextSecondary),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          FadeTransition(
            opacity: CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: Text('Back to Chapters',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text('Go to Home',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.kTextSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style:
                AppTextStyles.headingMedium.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty & Error states
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.chapterTitle});
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.style_outlined,
                size: 52, color: AppColors.kTextDisabled),
            const SizedBox(height: AppSpacing.lg),
            Text('No cards found', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No flashcards were generated for "$chapterTitle" yet.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.kBorder),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd)),
              ),
              child: Text('Go Back',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 52, color: AppColors.kError),
          const SizedBox(height: AppSpacing.lg),
          Text('Failed to load cards', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.kPrimary),
            child: Text('Retry',
                style: AppTextStyles.labelMedium
                    .copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
