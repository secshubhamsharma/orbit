import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/providers/session_provider.dart';

class ReviewSessionScreen extends ConsumerWidget {
  final SessionArgs args;

  const ReviewSessionScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider(args));

    // Navigate to result when session completes
    ref.listen(sessionProvider(args), (prev, next) {
      if (!prev!.isComplete && next.isComplete) {
        context.pushReplacement(
          '/review/${args.chapterId}/result',
          extra: args,
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: SafeArea(
          child: state.isLoading
              ? const _LoadingView()
              : state.error != null
                  ? _ErrorView(
                      message: state.error!,
                      onRetry: () =>
                          ref.invalidate(sessionProvider(args)),
                    )
                  : !state.hasCards
                      ? const _EmptyView()
                      : _SessionView(args: args, state: state),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: Text(
              'Quit session?',
              style: AppTextStyles.headingSmall,
            ),
            content: Text(
              'Your progress for this session will be lost.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Keep studying',
                    style:
                        AppTextStyles.labelMedium.copyWith(color: AppColors.kPrimary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Quit',
                    style:
                        AppTextStyles.labelMedium.copyWith(color: AppColors.kError)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ---------------------------------------------------------------------------
// Session view — progress bar + card + rating buttons
// ---------------------------------------------------------------------------

class _SessionView extends ConsumerWidget {
  final SessionArgs args;
  final SessionState state;

  const _SessionView({required this.args, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final card = state.currentCard!;
    final progress = state.currentIndex / state.cards.length;

    return Column(
      children: [
        // Top bar — progress + close
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.kTextSecondary),
                onPressed: () async {
                  final shouldExit = await _showExitDialog(context);
                  if (shouldExit && context.mounted) context.pop();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.kSurfaceVariant,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.kPrimary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${state.currentIndex} / ${state.cards.length}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
            ],
          ),
        ),

        // Card area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _FlipCard(
              card: card,
              isFlipped: state.isFlipped,
              onTap: () =>
                  ref.read(sessionProvider(args).notifier).flip(),
            ),
          ),
        ),

        // Rating buttons (only visible after flip)
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: state.isFlipped
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Tap the card to reveal the answer',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          secondChild: _RatingButtons(
            onRate: (r) =>
                ref.read(sessionProvider(args).notifier).rate(r),
          ),
        ),
      ],
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.kSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            title: Text('Quit session?', style: AppTextStyles.headingSmall),
            content: Text(
              'Your progress for this session will be lost.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Keep going',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kPrimary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Quit',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kError)),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ---------------------------------------------------------------------------
// Flip card
// ---------------------------------------------------------------------------

class _FlipCard extends StatefulWidget {
  final FlashcardModel card;
  final bool isFlipped;
  final VoidCallback onTap;

  const _FlipCard({
    required this.card,
    required this.isFlipped,
    required this.onTap,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _FlipCard old) {
    super.didUpdateWidget(old);

    if (widget.isFlipped != old.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    // New card — reset without animation
    if (widget.card.id != old.card.id) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFront = angle < math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _CardFace(card: widget.card, isFront: true)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child:
                        _CardFace(card: widget.card, isFront: false),
                  ),
          );
        },
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final FlashcardModel card;
  final bool isFront;

  const _CardFace({required this.card, required this.isFront});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFront ? AppColors.kSurface : AppColors.kPrimaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isFront
              ? AppColors.kBorder
              : AppColors.kPrimary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: isFront ? _FrontContent(card: card) : _BackContent(card: card),
    );
  }
}

class _FrontContent extends StatelessWidget {
  final FlashcardModel card;

  const _FrontContent({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Card type badge
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.kSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            _typeLabel(card.type),
            style: AppTextStyles.labelSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Question
        Text(
          card.front,
          style: AppTextStyles.cardFront,
          textAlign: TextAlign.center,
        ),

        // MCQ options on the front
        if (card.type == 'mcq' && card.options.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          ...card.options.asMap().entries.map((e) {
            final letter = String.fromCharCode(65 + e.key); // A, B, C, D
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(letter,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.kTextPrimary)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(e.value,
                        style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: AppSpacing.xl),
        Text(
          'Tap to reveal',
          style: AppTextStyles.caption
              .copyWith(color: AppColors.kTextDisabled),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    return switch (type) {
      'mcq' => 'Multiple Choice',
      'fill_blank' => 'Fill in the Blank',
      'true_false' => 'True / False',
      _ => 'Flashcard',
    };
  }
}

class _BackContent extends StatelessWidget {
  final FlashcardModel card;

  const _BackContent({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Answer label
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.kSuccess, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text('Answer',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.kSuccess)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Answer text
        Text(
          card.back,
          style: AppTextStyles.cardBack,
          textAlign: TextAlign.center,
        ),

        // Explanation (optional)
        if (card.explanation != null &&
            card.explanation!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.kSurfaceHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explanation',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.kTextSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  card.explanation!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.kTextPrimary),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rating buttons
// ---------------------------------------------------------------------------

class _RatingButtons extends StatelessWidget {
  final void Function(String rating) onRate;

  const _RatingButtons({required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How well did you know this?',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _RatingBtn(
                label: 'Again',
                sublabel: '<1d',
                color: AppColors.kError,
                onTap: () => onRate('again'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RatingBtn(
                label: 'Hard',
                sublabel: '<1d',
                color: AppColors.kWarning,
                onTap: () => onRate('hard'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RatingBtn(
                label: 'Good',
                sublabel: '1d',
                color: AppColors.kPrimary,
                onTap: () => onRate('good'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _RatingBtn(
                label: 'Easy',
                sublabel: '4d',
                color: AppColors.kSuccess,
                onTap: () => onRate('easy'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingBtn extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _RatingBtn({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
              Text(
                sublabel,
                style: AppTextStyles.caption
                    .copyWith(color: color.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading / error / empty states
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.kPrimary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.kError, size: 56),
          const SizedBox(height: AppSpacing.lg),
          Text('Failed to load cards',
              style: AppTextStyles.headingSmall,
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(message,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimary),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📭', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.lg),
          Text('No cards in this chapter',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Generate cards first from the chapter screen',
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Go back',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kPrimary)),
          ),
        ],
      ),
    );
  }
}
