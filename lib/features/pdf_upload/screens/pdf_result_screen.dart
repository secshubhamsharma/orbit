import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';

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
    final chapterTitle = extra?['chapterTitle'] ?? 'Practice';

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
          data: (cards) {
            if (cards.isEmpty) {
              return _EmptyView(chapterTitle: chapterTitle);
            }
            return _PracticeView(
              cards: cards,
              chapterTitle: chapterTitle,
            );
          },
        ),
      ),
    );
  }
}

class _PracticeView extends StatefulWidget {
  const _PracticeView({
    required this.cards,
    required this.chapterTitle,
  });

  final List<FlashcardModel> cards;
  final String chapterTitle;

  @override
  State<_PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<_PracticeView>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  int? _selectedOption;
  bool _revealed = false;
  final Map<String, String> _ratings = {};

  late final AnimationController _transitionCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
    _fade = CurvedAnimation(parent: _transitionCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionCtrl,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _transitionCtrl.dispose();
    super.dispose();
  }

  bool get _isDone => _index >= widget.cards.length;

  Future<void> _goNext(String rating) async {
    final card = widget.cards[_index];
    _ratings[card.id] = rating;

    if (_index >= widget.cards.length - 1) {
      setState(() => _index = widget.cards.length);
      return;
    }

    await _transitionCtrl.reverse();
    if (!mounted) return;

    setState(() {
      _index++;
      _selectedOption = null;
      _revealed = false;
    });

    _transitionCtrl.forward(from: 0);
  }

  void _selectMcq(int index) {
    if (_revealed) return;
    setState(() {
      _selectedOption = index;
      _revealed = true;
    });
  }

  void _revealAnswer() {
    if (_revealed) return;
    setState(() => _revealed = true);
  }

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
    final progress = (_index + 1) / widget.cards.length;

    return Column(
      children: [
        _Header(
          chapterTitle: widget.chapterTitle,
          current: _index + 1,
          total: widget.cards.length,
          progress: progress,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.lg,
              AppSpacing.pagePadding,
              AppSpacing.lg,
            ),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _QuestionPanel(
                  key: ValueKey(card.id),
                  card: card,
                  selectedOption: _selectedOption,
                  revealed: _revealed,
                  onSelectOption: _selectMcq,
                  onRevealAnswer: _revealAnswer,
                ),
              ),
            ),
          ),
        ),
        _ActionBar(
          card: card,
          selectedOption: _selectedOption,
          revealed: _revealed,
          onContinue: () {
            final rating = _ratingForCard(card);
            _goNext(rating);
          },
          onRevealAnswer: _revealAnswer,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  String _ratingForCard(FlashcardModel card) {
    if (card.type == 'mcq') {
      final isCorrect = _selectedOption != null &&
          _selectedOption == card.correctOption;
      return isCorrect ? 'good' : 'again';
    }

    return 'good';
  }
}

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
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.kSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.kTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterTitle,
                      style: AppTextStyles.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Question $current of $total',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.kTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.kSurfaceVariant,
              valueColor: const AlwaysStoppedAnimation(AppColors.kPrimary),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    super.key,
    required this.card,
    required this.selectedOption,
    required this.revealed,
    required this.onSelectOption,
    required this.onRevealAnswer,
  });

  final FlashcardModel card;
  final int? selectedOption;
  final bool revealed;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentForType(card.type).withValues(alpha: 0.22),
                    _accentForType(card.type).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accentForType(card.type).withValues(alpha: 0.22),
                            AppColors.kSecondary.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(
                          color: _accentForType(card.type)
                              .withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        _labelForType(card.type),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _accentForType(card.type),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor(card.difficulty)
                            .withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        _titleCase(card.difficulty),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _difficultyColor(card.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (card.type == 'mcq')
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _accentForType(card.type),
                              AppColors.kSecondary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(Icons.quiz_rounded,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Choose the best answer before continuing.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.kTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (card.type == 'mcq')
                  const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Text(
                          card.front,
                          style: AppTextStyles.cardFront.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.32,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (card.type == 'mcq' && card.options.isNotEmpty)
                          ...card.options.asMap().entries.map((entry) {
                            return _OptionTile(
                              index: entry.key,
                              text: entry.value,
                              selected: selectedOption == entry.key,
                              revealed: revealed,
                              isCorrect: card.correctOption == entry.key,
                              accent: _accentForType(card.type),
                              onTap: () => onSelectOption(entry.key),
                            );
                          })
                        else
                          _RevealAnswerPanel(
                            card: card,
                            revealed: revealed,
                            onRevealAnswer: onRevealAnswer,
                          ),
                        if (revealed &&
                            card.explanation != null &&
                            card.explanation!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.kBackground.withValues(alpha: 0.32),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusLg),
                              border: Border.all(color: AppColors.kBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: AppColors.kTextSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    card.explanation!,
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.revealed,
    required this.isCorrect,
    required this.accent,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool selected;
  final bool revealed;
  final bool isCorrect;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isWrongSelection = revealed && selected && !isCorrect;
    final borderColor = revealed
        ? isCorrect
            ? AppColors.kSuccess
            : isWrongSelection
                ? AppColors.kError
                : AppColors.kBorder
        : selected
            ? accent
            : AppColors.kBorder;

    final background = revealed
        ? isCorrect
            ? AppColors.kSuccessContainer.withValues(alpha: 0.55)
            : isWrongSelection
                ? AppColors.kErrorContainer.withValues(alpha: 0.55)
                : AppColors.kSurfaceVariant
        : selected
            ? accent.withValues(alpha: 0.12)
            : AppColors.kSurfaceVariant;

    final badgeGradient = revealed && isCorrect
        ? [AppColors.kSuccess, AppColors.kSecondary]
        : isWrongSelection
            ? [AppColors.kError, const Color(0xFFFF8A8A)]
            : [accent, AppColors.kSecondary];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + (index * 55)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 24, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: revealed ? null : onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Ink(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border:
                      Border.all(color: borderColor, width: selected ? 1.5 : 1),
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: badgeGradient),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: badgeGradient.first.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: revealed && isCorrect
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : revealed && isWrongSelection
                              ? const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 18)
                              : Text(
                                  String.fromCharCode(65 + index),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          text,
                          style:
                              AppTextStyles.bodyMedium.copyWith(height: 1.45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealAnswerPanel extends StatelessWidget {
  const _RevealAnswerPanel({
    required this.card,
    required this.revealed,
    required this.onRevealAnswer,
  });

  final FlashcardModel card;
  final bool revealed;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: revealed
          ? Container(
              key: const ValueKey('answer'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.kSuccessContainer.withValues(alpha: 0.72),
                    AppColors.kSurfaceVariant,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: AppColors.kSuccess.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.kSuccess),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Answer',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.kSuccess,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    card.back,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.55),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Container(
              key: const ValueKey('prompt'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Column(
                children: [
                  Text(
                    'Reveal the answer when you are ready.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: onRevealAnswer,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Show Answer',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.card,
    required this.selectedOption,
    required this.revealed,
    required this.onContinue,
    required this.onRevealAnswer,
  });

  final FlashcardModel card;
  final int? selectedOption;
  final bool revealed;
  final VoidCallback onContinue;
  final VoidCallback onRevealAnswer;

  @override
  Widget build(BuildContext context) {
    final canContinue =
        card.type == 'mcq' ? revealed && selectedOption != null : revealed;

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        children: [
          if (card.type == 'mcq' && revealed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                selectedOption == card.correctOption
                    ? 'Correct answer. Nice work.'
                    : 'Answer revealed. Review the explanation and continue.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: selectedOption == card.correctOption
                      ? AppColors.kSuccess
                      : AppColors.kTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (card.type != 'mcq' && !revealed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'No flip card here. Reveal the answer when you are ready.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.kTextDisabled),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: [
              if (card.type != 'mcq' && !revealed)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRevealAnswer,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.kPrimary,
                      side: const BorderSide(color: AppColors.kBorder),
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Reveal Answer',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.kPrimary),
                    ),
                  ),
                ),
              if (card.type != 'mcq' && !revealed)
                const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: canContinue ? onContinue : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                    disabledBackgroundColor:
                        AppColors.kSurfaceVariant,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: canContinue
                          ? Colors.white
                          : AppColors.kTextDisabled,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        .where((rating) => rating == 'good' || rating == 'easy')
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
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
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
                    size: 38,
                    color: accColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Practice Complete',
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
              curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
            ),
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
                    color: accColor,
                  ),
                  _StatCell(
                    label: 'Correct',
                    value: '$correct',
                    color: AppColors.kSuccess,
                  ),
                  _StatCell(
                    label: 'Total',
                    value: '$total',
                    color: AppColors.kTextSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
            ),
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
                    child: Text(
                      'Back to Chapters',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/home/profile/uploads'),
                  child: Text(
                    'Open My Uploads',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kTextSecondary),
                  ),
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
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingMedium.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

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
              'No practice questions were generated for "$chapterTitle" yet.',
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
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'Go Back',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kTextSecondary),
              ),
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
          Text('Failed to load questions',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.kPrimary,
            ),
            child: Text(
              'Retry',
              style:
                  AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

Color _accentForType(String type) {
  return switch (type) {
    'mcq' => AppColors.kPrimary,
    'fill_blank' => AppColors.kWarning,
    'true_false' => AppColors.kAccent,
    _ => AppColors.kPrimary,
  };
}

Color _difficultyColor(String difficulty) {
  return switch (difficulty) {
    'easy' => AppColors.kDifficultyEasy,
    'hard' => AppColors.kDifficultyHard,
    _ => AppColors.kDifficultyMedium,
  };
}

String _labelForType(String type) {
  return switch (type) {
    'mcq' => 'MULTIPLE CHOICE',
    'fill_blank' => 'FILL IN THE BLANK',
    'true_false' => 'TRUE / FALSE',
    _ => 'PRACTICE',
  };
}

String _titleCase(String value) {
  if (value.isEmpty) return value;
  return value[0].toUpperCase() + value.substring(1);
}
