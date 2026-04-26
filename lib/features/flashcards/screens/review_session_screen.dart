import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/providers/session_provider.dart';

// ---------------------------------------------------------------------------
// Screen entry point
// ---------------------------------------------------------------------------

class ReviewSessionScreen extends ConsumerWidget {
  final SessionArgs args;
  const ReviewSessionScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider(args));

    // Navigate to result when session completes
    ref.listen(sessionProvider(args), (prev, next) {
      if (prev != null && !prev.isComplete && next.isComplete) {
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
        final exit = await _confirmExit(context);
        if (exit && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: SafeArea(
          child: state.isLoading
              ? const _LoadingView()
              : state.error != null
                  ? _ErrorView(
                      message: state.error!,
                      onRetry: () => ref.invalidate(sessionProvider(args)),
                    )
                  : !state.hasCards
                      ? const _EmptyView()
                      : _McqSession(args: args, state: state),
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
            title:
                Text('Quit quiz?', style: AppTextStyles.headingSmall),
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
// MCQ session wrapper
// ---------------------------------------------------------------------------

class _McqSession extends StatelessWidget {
  final SessionArgs args;
  final SessionState state;
  const _McqSession({required this.args, required this.state});

  @override
  Widget build(BuildContext context) {
    final card     = state.currentCard!;
    final progress = (state.currentIndex) / state.cards.length;

    return Column(
      children: [
        // ── Header: progress bar + counter + close ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.lg, 0),
          child: Row(
            children: [
              Consumer(
                builder: (_, ref, __) => IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.kTextSecondary,
                  ),
                  onPressed: () async {
                    final exit = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.kSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        title: Text('Quit quiz?',
                            style: AppTextStyles.headingSmall),
                        content: Text(
                          'Your progress for this session will be lost.',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.kTextSecondary),
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
                    );
                    if ((exit ?? false) && context.mounted) context.pop();
                  },
                ),
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
                        minHeight: 6,
                        backgroundColor: AppColors.kSurfaceVariant,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.kPrimary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.currentIndex + 1} / ${state.cards.length}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),

        // ── MCQ card (keyed so state resets on each new card) ───────────────
        Expanded(
          child: _McqCard(
            key: ValueKey(card.id),
            card: card,
            args: args,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual MCQ card
// ---------------------------------------------------------------------------

enum _OptionState { idle, correct, wrong, dimmed }

class _McqCard extends ConsumerStatefulWidget {
  final FlashcardModel card;
  final SessionArgs args;
  const _McqCard({super.key, required this.card, required this.args});

  @override
  ConsumerState<_McqCard> createState() => _McqCardState();
}

class _McqCardState extends ConsumerState<_McqCard>
    with TickerProviderStateMixin {
  int? _chosenIndex;
  bool _isAnswered = false;

  // Shuffled once per card in initState so the correct answer is never
  // predictable even for cards already stored in Firestore.
  late List<String> _shuffledOptions;
  late int          _shuffledCorrectIndex;

  late final AnimationController _cardCtrl;
  late final Animation<Offset>   _cardSlide;
  late final Animation<double>   _cardFade;
  late final AnimationController _optCtrl;

  @override
  void initState() {
    super.initState();
    _initShuffle();

    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardCtrl.forward();

    _optCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _optCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _optCtrl.dispose();
    super.dispose();
  }

  // ── Shuffle (called once in initState) ────────────────────────────────────

  void _initShuffle() {
    final raw = widget.card.options.isNotEmpty
        ? widget.card.options
        : ['True', 'False', 'Cannot be determined', 'None of the above'];
    final correctText = raw[widget.card.correctOption?.clamp(0, raw.length - 1) ?? 0];
    final shuffled    = List<String>.from(raw)..shuffle();
    _shuffledOptions      = shuffled;
    _shuffledCorrectIndex = shuffled.indexOf(correctText).clamp(0, shuffled.length - 1);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<String> get _options          => _shuffledOptions;
  int          get _correctIndex     => _shuffledCorrectIndex;

  _OptionState _stateFor(int i) {
    if (!_isAnswered) return _OptionState.idle;
    if (i == _correctIndex) return _OptionState.correct;
    if (i == _chosenIndex) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  // ── Interaction ────────────────────────────────────────────────────────────

  Future<void> _onTap(int index) async {
    if (_isAnswered) return;
    final isCorrect = index == _correctIndex;

    HapticFeedback.lightImpact();
    if (!isCorrect) HapticFeedback.heavyImpact();

    setState(() {
      _chosenIndex  = index;
      _isAnswered   = true;
    });

    // Show feedback for 700 ms, then advance
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    ref.read(sessionProvider(widget.args).notifier).rate(
          isCorrect ? 'good' : 'again',
        );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final opts = _options;

    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Question card ─────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.kBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MCQ badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        'Multiple Choice',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.kPrimary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      widget.card.front,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.kTextPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Options ────────────────────────────────────────────────────
              ...opts.asMap().entries.map((entry) {
                final i     = entry.key;
                final label = entry.value;
                final st    = _stateFor(i);
                final delay = i * 0.12;

                return AnimatedBuilder(
                  animation: _optCtrl,
                  builder: (_, __) {
                    final t = (((_optCtrl.value - delay) / (1 - delay))
                            .clamp(0.0, 1.0));
                    final curve = Curves.easeOutCubic.transform(t);
                    return Opacity(
                      opacity: curve,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - curve)),
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _OptionTile(
                            letter: String.fromCharCode(65 + i),
                            label:  label,
                            state:  st,
                            onTap:  () => _onTap(i),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              // ── Explanation after answering ────────────────────────────────
              if (_isAnswered &&
                  widget.card.explanation != null &&
                  widget.card.explanation!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AnimatedOpacity(
                  opacity: _isAnswered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                          color: AppColors.kBorder.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explanation',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.kTextSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.card.explanation!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.kTextPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Option tile
// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  final String letter;
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg, border, letterBg, letterFg, textColor;

    switch (state) {
      case _OptionState.correct:
        bg       = AppColors.kSuccess.withValues(alpha: 0.10);
        border   = AppColors.kSuccess.withValues(alpha: 0.6);
        letterBg = AppColors.kSuccess;
        letterFg = Colors.white;
        textColor = AppColors.kSuccess;
      case _OptionState.wrong:
        bg       = AppColors.kError.withValues(alpha: 0.10);
        border   = AppColors.kError.withValues(alpha: 0.6);
        letterBg = AppColors.kError;
        letterFg = Colors.white;
        textColor = AppColors.kError;
      case _OptionState.dimmed:
        bg       = AppColors.kBackground;
        border   = AppColors.kBorder.withValues(alpha: 0.4);
        letterBg = AppColors.kSurfaceVariant;
        letterFg = AppColors.kTextDisabled;
        textColor = AppColors.kTextDisabled;
      case _OptionState.idle:
        bg       = AppColors.kSurface;
        border   = AppColors.kBorder;
        letterBg = AppColors.kSurfaceVariant;
        letterFg = AppColors.kTextPrimary;
        textColor = AppColors.kTextPrimary;
    }

    final icon = state == _OptionState.correct
        ? Icons.check_rounded
        : state == _OptionState.wrong
            ? Icons.close_rounded
            : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state == _OptionState.idle ? onTap : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                // Letter badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: icon != null
                      ? Icon(icon, size: 16, color: letterFg)
                      : Text(
                          letter,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: letterFg),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: textColor),
                    child: Text(label),
                  ),
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
// Loading / error / empty states
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.kPrimary),
      );
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
          Text('Failed to load questions',
              style: AppTextStyles.headingSmall, textAlign: TextAlign.center),
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
          Text('No questions in this chapter',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Generate questions first from the chapter screen',
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
