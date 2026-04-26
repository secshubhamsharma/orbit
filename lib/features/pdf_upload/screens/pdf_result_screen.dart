import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';
import 'package:orbitapp/providers/quiz_progress_provider.dart';

// ─── Data ────────────────────────────────────────────────────────────────────

class _Answer {
  const _Answer({
    required this.cardId,
    required this.cardType,
    required this.correct,
  });
  final String cardId;
  final String cardType;
  final bool correct;
}

// ─── Entry widget ─────────────────────────────────────────────────────────────

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
  /// When non-null the quiz retries only these cards (wrong cards from last run).
  List<FlashcardModel>? _retryCards;

  void _handleRetry(List<FlashcardModel> wrongCards) =>
      setState(() => _retryCards = wrongCards);

  @override
  Widget build(BuildContext context) {
    final chapterId = widget.extra?['chapterId'] ?? '';
    final chapterTitle = widget.extra?['chapterTitle'] ?? 'Practice';

    final cardsAsync = ref.watch(
      chapterCardsProvider((uploadId: widget.uploadId, chapterId: chapterId)),
    );

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: cardsAsync.when(
        loading: () => const _LoadingView(),
        error: (_, __) => _ErrorView(
          onRetry: () => ref.invalidate(chapterCardsProvider(
            (uploadId: widget.uploadId, chapterId: chapterId),
          )),
        ),
        data: (allCards) {
          if (allCards.isEmpty) {
            return _EmptyView(chapterTitle: chapterTitle);
          }
          final activeCards = _retryCards ?? allCards;
          return _QuizSession(
            // Changing the key forces a full rebuild when retry cards change.
            key: ObjectKey(_retryCards),
            cards: activeCards,
            allCards: allCards,
            uploadId: widget.uploadId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
            onRetry: _handleRetry,
          );
        },
      ),
    );
  }
}

// ─── Quiz session ─────────────────────────────────────────────────────────────

class _QuizSession extends ConsumerStatefulWidget {
  const _QuizSession({
    super.key,
    required this.cards,
    required this.allCards,
    required this.uploadId,
    required this.chapterId,
    required this.chapterTitle,
    required this.onRetry,
  });

  final List<FlashcardModel> cards;
  final List<FlashcardModel> allCards;
  final String uploadId;
  final String chapterId;
  final String chapterTitle;
  final void Function(List<FlashcardModel> wrongCards) onRetry;

  @override
  ConsumerState<_QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends ConsumerState<_QuizSession>
    with TickerProviderStateMixin {
  // ── Phase ──────────────────────────────────────────────────────────────────
  bool _showResults = false;

  // ── Per-card state ─────────────────────────────────────────────────────────
  int _index = 0;
  final List<_Answer> _answers = [];
  int? _chosenIndex;   // selected option index (MCQ / True-False)
  bool _revealed = false; // answer shown (flashcard / fill_blank)
  bool _isAnswered = false;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _cardCtrl;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardSlide;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnOpacity;
  late final Animation<Offset> _btnSlide;

  // ── Derived ────────────────────────────────────────────────────────────────

  FlashcardModel get _card => widget.cards[_index];

  bool get _isMcqLike =>
      _card.type == 'mcq' || _card.type == 'true_false';

  List<String> get _options {
    if (_card.type == 'mcq') return _card.options;
    if (_card.type == 'true_false') return ['True', 'False'];
    return [];
  }

  int? get _correctIndex {
    if (_card.type == 'mcq') return _card.correctOption;
    if (_card.type == 'true_false') {
      return _card.back.trim().toLowerCase() == 'true' ? 0 : 1;
    }
    return null;
  }

  double get _progress =>
      widget.cards.isEmpty ? 0 : (_index + 1) / widget.cards.length;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _cardOpacity =
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _btnOpacity = CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOut);
    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  // ── Interaction ─────────────────────────────────────────────────────────────

  void _onOptionTap(int index) {
    if (_isAnswered) return;
    final correct = index == _correctIndex;
    correct
        ? HapticFeedback.lightImpact()
        : HapticFeedback.mediumImpact();

    setState(() {
      _chosenIndex = index;
      _isAnswered = true;
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _btnCtrl.forward();
    });
  }

  void _onReveal() {
    HapticFeedback.selectionClick();
    setState(() => _revealed = true);
  }

  void _onSelfRate(bool correct) {
    if (_isAnswered) return;
    correct
        ? HapticFeedback.lightImpact()
        : HapticFeedback.mediumImpact();

    _answers.add(_Answer(
      cardId: _card.id,
      cardType: _card.type,
      correct: correct,
    ));
    setState(() => _isAnswered = true);

    // Brief visual pause then advance
    Future.delayed(const Duration(milliseconds: 300), _advance);
  }

  Future<void> _goNext() async {
    // Record MCQ / T-F answer
    _answers.add(_Answer(
      cardId: _card.id,
      cardType: _card.type,
      correct: _chosenIndex != null && _chosenIndex == _correctIndex,
    ));
    await _advance();
  }

  Future<void> _advance() async {
    if (_index >= widget.cards.length - 1) {
      _finish();
      return;
    }

    await _cardCtrl.reverse();
    if (!mounted) return;

    setState(() {
      _index++;
      _chosenIndex = null;
      _isAnswered = false;
      _revealed = false;
    });
    _btnCtrl.reset();
    _cardCtrl.forward();
  }

  void _finish() {
    final correct = _answers.where((a) => a.correct).length;
    ref.read(chapterProgressProvider.notifier).save(
      uploadId: widget.uploadId,
      chapterId: widget.chapterId,
      totalCards: widget.allCards.length,
      correctCount: correct,
    );
    setState(() => _showResults = true);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _ResultsScreen(
        answers: _answers,
        allCards: widget.cards,
        chapterTitle: widget.chapterTitle,
        onRetry: () {
          final wrongIds = _answers
              .where((a) => !a.correct)
              .map((a) => a.cardId)
              .toSet();
          final wrongCards = widget.allCards
              .where((c) => wrongIds.contains(c.id))
              .toList();
          widget.onRetry(wrongCards);
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  AppSpacing.sm,
                  AppSpacing.pagePadding,
                  AppSpacing.lg,
                ),
                child: FadeTransition(
                  opacity: _cardOpacity,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: _QuizCard(
                      key: ValueKey('card_$_index'),
                      card: _card,
                      options: _options,
                      correctIndex: _correctIndex,
                      chosenIndex: _chosenIndex,
                      isAnswered: _isAnswered,
                      isRevealed: _revealed,
                      isMcqLike: _isMcqLike,
                      onOptionTap: _onOptionTap,
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
                child: Container(
                  width: 40,
                  height: 40,
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
                child: Text(
                  widget.chapterTitle,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.kSurfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${_index + 1} / ${widget.cards.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.kTextPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: _progress),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
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
    );
  }

  // ── Bottom action bar ────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    // Flashcard — before reveal
    if (!_isMcqLike && !_revealed) {
      return _BottomPad(
        child: _ActionButton(
          label: 'Show Answer',
          icon: Icons.expand_more_rounded,
          color: AppColors.kSurface,
          textColor: AppColors.kTextPrimary,
          borderColor: AppColors.kBorder,
          onTap: _onReveal,
        ),
      );
    }

    // Flashcard — after reveal, self-rate
    if (!_isMcqLike && _revealed && !_isAnswered) {
      return _BottomPad(
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: "Didn't know",
                icon: Icons.close_rounded,
                color: AppColors.kErrorContainer,
                textColor: AppColors.kError,
                borderColor: AppColors.kError.withValues(alpha: 0.3),
                onTap: () => _onSelfRate(false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ActionButton(
                label: 'Got it!',
                icon: Icons.check_rounded,
                color: AppColors.kSuccessContainer,
                textColor: AppColors.kSuccess,
                borderColor: AppColors.kSuccess.withValues(alpha: 0.3),
                onTap: () => _onSelfRate(true),
              ),
            ),
          ],
        ),
      );
    }

    // MCQ / T-F — after answering
    if (_isMcqLike && _isAnswered) {
      final wasCorrect = _chosenIndex == _correctIndex;
      return _BottomPad(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feedback banner
            FadeTransition(
              opacity: _btnOpacity,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: wasCorrect
                      ? AppColors.kSuccessContainer
                      : AppColors.kErrorContainer,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: wasCorrect
                        ? AppColors.kSuccess.withValues(alpha: 0.35)
                        : AppColors.kError.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      wasCorrect
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: wasCorrect
                          ? AppColors.kSuccess
                          : AppColors.kError,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      wasCorrect
                          ? 'Correct! Keep it up.'
                          : 'Not quite. Review the correct answer.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: wasCorrect
                            ? AppColors.kSuccess
                            : AppColors.kError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Continue button
            FadeTransition(
              opacity: _btnOpacity,
              child: SlideTransition(
                position: _btnSlide,
                child: _ActionButton(
                  label: _index < widget.cards.length - 1
                      ? 'Next Question'
                      : 'See Results',
                  icon: Icons.arrow_forward_rounded,
                  color: AppColors.kPrimary,
                  textColor: Colors.white,
                  onTap: _goNext,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Quiz card ────────────────────────────────────────────────────────────────

class _QuizCard extends StatefulWidget {
  const _QuizCard({
    super.key,
    required this.card,
    required this.options,
    required this.correctIndex,
    required this.chosenIndex,
    required this.isAnswered,
    required this.isRevealed,
    required this.isMcqLike,
    required this.onOptionTap,
  });

  final FlashcardModel card;
  final List<String> options;
  final int? correctIndex;
  final int? chosenIndex;
  final bool isAnswered;
  final bool isRevealed;
  final bool isMcqLike;
  final ValueChanged<int> onOptionTap;

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
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _optCtrl.dispose();
    super.dispose();
  }

  Animation<double> _optionAnim(int i) => CurvedAnimation(
        parent: _optCtrl,
        curve: Interval(i * 0.11, (i * 0.11 + 0.55).clamp(0, 1.0),
            curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionCard(),
        const SizedBox(height: AppSpacing.lg),
        if (widget.isMcqLike) _buildOptions(),
        if (!widget.isMcqLike) _buildFlashcardAnswer(),
      ],
    );
  }

  // ── Question card ──────────────────────────────────────────────────────────

  Widget _buildQuestionCard() {
    final accent = _accentColor(widget.card.type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent glow
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  accent.withValues(alpha: 0.22),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TypeBadge(type: widget.card.type),
                  const Spacer(),
                  _DifficultyBadge(difficulty: widget.card.difficulty),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                widget.card.front,
                style: AppTextStyles.headingSmall.copyWith(height: 1.5),
              ),
              if (widget.card.type == 'fill_blank') ...[
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  const Icon(Icons.edit_outlined,
                      size: 12, color: AppColors.kTextDisabled),
                  const SizedBox(width: 4),
                  Text('Fill in the blank',
                      style: AppTextStyles.caption),
                ]),
              ],
              if (!widget.isMcqLike && widget.isRevealed) ...[
                const SizedBox(height: AppSpacing.xl),
                _buildAnswerReveal(),
              ],
              if (widget.card.explanation != null &&
                  widget.card.explanation!.trim().isNotEmpty &&
                  widget.isAnswered) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildExplanation(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerReveal() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kSuccessContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: AppColors.kSuccess.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 14, color: AppColors.kSuccess),
              const SizedBox(width: 6),
              Text('Answer',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.kSuccess)),
            ]),
            const SizedBox(height: AppSpacing.sm),
            Text(widget.card.back,
                style: AppTextStyles.bodyLarge.copyWith(height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 14, color: AppColors.kTextSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.card.explanation!,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ── MCQ options ─────────────────────────────────────────────────────────────

  Widget _buildOptions() {
    final labels =
        widget.card.type == 'true_false' ? ['T', 'F'] : ['A', 'B', 'C', 'D'];

    if (widget.card.type == 'true_false') {
      return Row(
        children: List.generate(widget.options.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: i < widget.options.length - 1 ? AppSpacing.md : 0),
              child: FadeTransition(
                opacity: _optionAnim(i),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(_optionAnim(i)),
                  child: _OptionTile(
                    label: labels[i],
                    text: widget.options[i],
                    index: i,
                    isSelected: widget.chosenIndex == i,
                    isCorrect: widget.correctIndex == i,
                    isAnswered: widget.isAnswered,
                    isTrueFalse: true,
                    onTap: () => widget.onOptionTap(i),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Column(
      children: List.generate(widget.options.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: FadeTransition(
            opacity: _optionAnim(i),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(_optionAnim(i)),
              child: _OptionTile(
                label: labels[i],
                text: widget.options[i],
                index: i,
                isSelected: widget.chosenIndex == i,
                isCorrect: widget.correctIndex == i,
                isAnswered: widget.isAnswered,
                isTrueFalse: false,
                onTap: () => widget.onOptionTap(i),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Flashcard answer (before/after reveal) ──────────────────────────────────

  Widget _buildFlashcardAnswer() {
    if (widget.isRevealed) return const SizedBox.shrink();
    // Answer is shown inside the question card — nothing extra here
    return const SizedBox.shrink();
  }
}

// ─── Option tile ──────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswered,
    required this.isTrueFalse,
    required this.onTap,
  });

  final String label;
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final bool isTrueFalse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Compute visual state
    final bool showCorrect = isAnswered && isCorrect;
    final bool showWrong = isAnswered && isSelected && !isCorrect;
    final bool isDimmed = isAnswered && !isSelected && !isCorrect;

    final Color borderColor = showCorrect
        ? AppColors.kSuccess
        : showWrong
            ? AppColors.kError
            : isSelected
                ? AppColors.kPrimary
                : AppColors.kBorder;

    final Color bgColor = showCorrect
        ? AppColors.kSuccess.withValues(alpha: 0.12)
        : showWrong
            ? AppColors.kError.withValues(alpha: 0.12)
            : isSelected
                ? AppColors.kPrimary.withValues(alpha: 0.1)
                : AppColors.kSurface;

    final Color badgeBg = showCorrect
        ? AppColors.kSuccess
        : showWrong
            ? AppColors.kError
            : isSelected
                ? AppColors.kPrimary
                : AppColors.kSurfaceVariant;

    final Color textColor = isDimmed
        ? AppColors.kTextDisabled
        : AppColors.kTextPrimary;

    Widget badgeChild;
    if (showCorrect) {
      badgeChild = const Icon(Icons.check_rounded,
          size: 16, color: Colors.white);
    } else if (showWrong) {
      badgeChild = const Icon(Icons.close_rounded,
          size: 16, color: Colors.white);
    } else if (isTrueFalse) {
      badgeChild = Icon(
        index == 0 ? Icons.check_rounded : Icons.close_rounded,
        size: 16,
        color: (isSelected || showCorrect)
            ? Colors.white
            : AppColors.kTextSecondary,
      );
    } else {
      badgeChild = Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isSelected ? Colors.white : AppColors.kTextSecondary,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: borderColor,
          width: (isSelected || showCorrect) ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: AppColors.kPrimary.withValues(alpha: 0.1),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: isTrueFalse ? AppSpacing.xl : AppSpacing.lg,
            ),
            child: isTrueFalse
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeBg,
                          shape: BoxShape.circle,
                        ),
                        child: badgeChild,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        text,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: badgeChild,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          text,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: textColor, height: 1.4),
                        ),
                      ),
                      if (showCorrect)
                        const Padding(
                          padding: EdgeInsets.only(left: AppSpacing.sm),
                          child: Icon(Icons.check_circle_rounded,
                              size: 18, color: AppColors.kSuccess),
                        ),
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
    required this.answers,
    required this.allCards,
    required this.chapterTitle,
    required this.onRetry,
  });

  final List<_Answer> answers;
  final List<FlashcardModel> allCards;
  final String chapterTitle;
  final VoidCallback onRetry;

  @override
  State<_ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<_ResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) => CurvedAnimation(
        parent: _enterCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    final total = widget.answers.length;
    final correct = widget.answers.where((a) => a.correct).length;
    final wrong = total - correct;
    final accuracy = total > 0 ? correct / total : 0.0;
    final accColor = _accuracyColor(accuracy);
    final wrongAnswers = widget.answers.where((a) => !a.correct).toList();

    // Group by type
    final Map<String, ({int correct, int total})> byType = {};
    for (final ans in widget.answers) {
      final label = _typeLabel(ans.cardType);
      final prev = byType[label] ?? (correct: 0, total: 0);
      byType[label] = (
        correct: prev.correct + (ans.correct ? 1 : 0),
        total: prev.total + 1,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding, vertical: AppSpacing.lg),
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _stagger(0.0, 0.4),
                child: Column(
                  children: [
                    Text(
                      accuracy >= 0.75
                          ? '🎉 Excellent Work!'
                          : accuracy >= 0.5
                              ? '👍 Good Effort!'
                              : '💪 Keep Practising!',
                      style: AppTextStyles.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
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

              // ── Accuracy ring ────────────────────────────────────────────
              FadeTransition(
                opacity: _stagger(0.1, 0.5),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: accuracy),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return SizedBox(
                      width: 170,
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(170, 170),
                            painter: _RingPainter(
                              progress: value,
                              foreground:
                                  _accuracyColor(value),
                              background: AppColors.kSurfaceVariant,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(value * 100).round()}%',
                                style: AppTextStyles.displayMedium.copyWith(
                                  color: _accuracyColor(value),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text('Accuracy',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Score row ────────────────────────────────────────────────
              FadeTransition(
                opacity: _stagger(0.25, 0.65),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      value: '$correct',
                      label: 'Correct',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.kSuccess,
                    )),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _StatCard(
                      value: '$wrong',
                      label: 'Wrong',
                      icon: Icons.cancel_rounded,
                      color: AppColors.kError,
                    )),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _StatCard(
                      value: '$total',
                      label: 'Total',
                      icon: Icons.style_rounded,
                      color: AppColors.kTextSecondary,
                    )),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Breakdown by type ────────────────────────────────────────
              if (byType.length > 1) ...[
                FadeTransition(
                  opacity: _stagger(0.35, 0.75),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.lg,
                              AppSpacing.lg,
                              AppSpacing.sm),
                          child: Text('Breakdown by type',
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.kTextSecondary)),
                        ),
                        ...byType.entries.map((e) => _TypeRow(
                              typeName: e.key,
                              correct: e.value.correct,
                              total: e.value.total,
                            )),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ── Actions ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _stagger(0.5, 0.9),
                child: Column(
                  children: [
                    if (wrongAnswers.isNotEmpty)
                      _ActionButton(
                        label:
                            'Retry ${wrongAnswers.length} Wrong Question${wrongAnswers.length > 1 ? 's' : ''}',
                        icon: Icons.refresh_rounded,
                        color: AppColors.kPrimaryContainer,
                        textColor: AppColors.kPrimaryLight,
                        borderColor: AppColors.kPrimary.withValues(alpha: 0.3),
                        onTap: widget.onRetry,
                      ),
                    if (wrongAnswers.isNotEmpty)
                      const SizedBox(height: AppSpacing.md),
                    _ActionButton(
                      label: 'Back to Chapters',
                      icon: Icons.arrow_back_rounded,
                      color: AppColors.kSurface,
                      textColor: AppColors.kTextPrimary,
                      borderColor: AppColors.kBorder,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go('/home/profile/uploads'),
                      child: Text(
                        'My Uploads',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.kTextSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ring painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.foreground,
    required this.background,
  });

  final double progress;
  final Color foreground;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;
    const stroke = 14.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = background
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = foreground
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final color = _accentColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        _typeLabel(type).toUpperCase(),
        style: AppTextStyles.labelSmall
            .copyWith(color: color, letterSpacing: 0.8, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty.toLowerCase()) {
      'easy' => AppColors.kDifficultyEasy,
      'hard' => AppColors.kDifficultyHard,
      _ => AppColors.kDifficultyMedium,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        difficulty[0].toUpperCase() + difficulty.substring(1),
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.headingMedium.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.typeName,
    required this.correct,
    required this.total,
  });

  final String typeName;
  final int correct;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? correct / total : 0.0;
    final color = _accuracyColor(pct);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(typeName,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.kTextPrimary)),
          ),
          Text(
            '$correct / $total',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.kTextSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 46,
            child: Text(
              '${(pct * 100).round()}%',
              style: AppTextStyles.labelSmall.copyWith(
                  color: color, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: borderColor != null
                ? BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor!),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: AppSpacing.sm),
                Text(label,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(label,
                  style: AppTextStyles.labelLarge.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomPad extends StatelessWidget {
  const _BottomPad({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.sm,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        child: child,
      );
}

// ─── Empty / error / loading ──────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.kBackground,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.kPrimary)),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.chapterTitle});
  final String chapterTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.style_outlined,
                    size: 52, color: AppColors.kTextDisabled),
                const SizedBox(height: AppSpacing.lg),
                Text('No questions found',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No practice questions were generated for "$chapterTitle".',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
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
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Center(
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
                  backgroundColor: AppColors.kPrimary),
              child: Text('Retry',
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color _accentColor(String type) => switch (type) {
      'mcq' => AppColors.kPrimary,
      'true_false' => AppColors.kSecondary,
      'fill_blank' => AppColors.kWarning,
      _ => AppColors.kAccent,
    };

String _typeLabel(String type) => switch (type) {
      'mcq' => 'Multiple Choice',
      'true_false' => 'True / False',
      'fill_blank' => 'Fill in Blank',
      _ => 'Flashcard',
    };

Color _accuracyColor(double accuracy) {
  if (accuracy >= 0.75) return AppColors.kSuccess;
  if (accuracy >= 0.5) return AppColors.kWarning;
  return AppColors.kError;
}
