import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/providers/library_provider.dart';
import 'package:orbitapp/services/api_service.dart';
import 'package:orbitapp/services/firestore_service.dart';
import 'package:orbitapp/shared/widgets/orbit_button.dart';

class ChapterScreen extends ConsumerStatefulWidget {
  final String domainId;
  final String subjectId;
  final String bookId;
  final String chapterId;

  const ChapterScreen({
    super.key,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  bool _isGenerating = false;
  String? _errorMessage;

  Future<void> _generateCards(ChapterModel chapter, BookModel book) async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final count = await ApiService.instance.generateFlashcards(
        topicId: chapter.id,
        topicName: '${book.title} — ${chapter.name}',
        domainId: widget.domainId,
        subjectId: widget.subjectId,
        examTags: book.examTags,
      );

      await FirestoreService.instance.updateChapterCardCount(
        widget.domainId,
        widget.subjectId,
        widget.bookId,
        widget.chapterId,
        count,
      );

      ref.invalidate(chapterProvider((
        domainId: widget.domainId,
        subjectId: widget.subjectId,
        bookId: widget.bookId,
        chapterId: widget.chapterId,
      )));
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterProvider((
      domainId: widget.domainId,
      subjectId: widget.subjectId,
      bookId: widget.bookId,
      chapterId: widget.chapterId,
    )));

    final bookAsync = ref.watch(bookProvider((
      domainId: widget.domainId,
      subjectId: widget.subjectId,
      bookId: widget.bookId,
    )));

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.kTextPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: chapterAsync.whenOrNull(
          data: (chapter) => chapter != null
              ? Text(chapter.name, style: AppTextStyles.headingSmall)
              : null,
        ),
      ),
      body: chapterAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kPrimary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.kError, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Failed to load chapter',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (chapter) {
          if (chapter == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📄', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chapter not found',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.kTextPrimary),
                  ),
                ],
              ),
            );
          }

          final book = bookAsync.whenOrNull(data: (b) => b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: _ChapterBody(
              chapter: chapter,
              book: book,
              isGenerating: _isGenerating,
              errorMessage: _errorMessage,
              onGenerate: () {
                if (book != null) _generateCards(chapter, book);
              },
              onStudy: () => context.push('/review/${chapter.id}'),
              onRegenerate: () {
                if (book != null) _generateCards(chapter, book);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChapterBody extends StatelessWidget {
  final ChapterModel chapter;
  final BookModel? book;
  final bool isGenerating;
  final String? errorMessage;
  final VoidCallback onGenerate;
  final VoidCallback onStudy;
  final VoidCallback onRegenerate;

  const _ChapterBody({
    required this.chapter,
    required this.book,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
    required this.onStudy,
    required this.onRegenerate,
  });

  Color _difficultyColor(String difficulty) {
    return switch (difficulty.toLowerCase()) {
      'beginner' || 'easy' => AppColors.kDifficultyEasy,
      'intermediate' || 'medium' => AppColors.kDifficultyMedium,
      'advanced' || 'hard' => AppColors.kDifficultyHard,
      _ => AppColors.kTextSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter number chip
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.kPrimaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            'Chapter ${chapter.chapterNumber}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.kPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Chapter title
        Text(chapter.name, style: AppTextStyles.headingLarge),

        const SizedBox(height: AppSpacing.sm),

        // Difficulty + time row
        Row(
          children: [
            _InfoChip(
              label: _capitalize(chapter.difficulty),
              color: _difficultyColor(chapter.difficulty),
            ),
            const SizedBox(width: AppSpacing.sm),
            _InfoChip(
              label: '${chapter.estimatedMinutes} min',
              icon: Icons.schedule_rounded,
              color: AppColors.kTextSecondary,
            ),
          ],
        ),

        // Description
        if (chapter.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(chapter.description, style: AppTextStyles.bodySmall),
        ],

        // Stats row (only when cards exist)
        if (chapter.totalCards > 0) ...[
          const SizedBox(height: AppSpacing.xl),
          _StatsRow(chapter: chapter),
        ],

        // Tags
        if (chapter.tags.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: chapter.tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(tag, style: AppTextStyles.caption),
                  ),
                )
                .toList(),
          ),
        ],

        // Error banner
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _ErrorBanner(message: errorMessage!),
        ],

        const SizedBox(height: AppSpacing.xxl),

        // Action button
        _ActionButton(
          chapter: chapter,
          isGenerating: isGenerating,
          onGenerate: onGenerate,
          onStudy: onStudy,
        ),

        // Regenerate option
        if (chapter.totalCards > 0) ...[
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: isGenerating ? null : onRegenerate,
              child: Text(
                'Regenerate cards',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _ActionButton extends StatelessWidget {
  final ChapterModel chapter;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final VoidCallback onStudy;

  const _ActionButton({
    required this.chapter,
    required this.isGenerating,
    required this.onGenerate,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    if (isGenerating) {
      return OrbitButton(
        label: 'Generating...',
        isLoading: true,
        onTap: null,
      );
    }

    if (chapter.totalCards == 0) {
      return OrbitButton(
        label: 'Generate Flashcards with AI',
        icon: Icons.auto_awesome_rounded,
        onTap: onGenerate,
      );
    }

    return _StudyButton(chapter: chapter, onTap: onStudy);
  }
}

class _StudyButton extends StatelessWidget {
  final ChapterModel chapter;
  final VoidCallback onTap;

  const _StudyButton({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.kGradientSuccess,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.kSuccess.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Start Studying · ${chapter.totalCards} cards',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ChapterModel chapter;

  const _StatsRow({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(label: 'Total Cards', value: '${chapter.totalCards}'),
        const SizedBox(width: AppSpacing.sm),
        _StatBox(
            label: 'Est. Time', value: '${chapter.estimatedMinutes} min'),
        const SizedBox(width: AppSpacing.sm),
        _StatBox(
          label: 'Difficulty',
          value: _capitalize(chapter.difficulty),
        ),
      ],
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _InfoChip({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kErrorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
            color: AppColors.kError.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.kError, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.kError),
            ),
          ),
        ],
      ),
    );
  }
}
