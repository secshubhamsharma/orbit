import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

// ---------------------------------------------------------------------------
// Book screen — shows chapters list
// ---------------------------------------------------------------------------

class BookScreen extends ConsumerStatefulWidget {
  final String domainId;
  final String subjectId;
  final String bookId;

  const BookScreen({
    super.key,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
  });

  @override
  ConsumerState<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends ConsumerState<BookScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(
      bookProvider(
          (domainId: widget.domainId, subjectId: widget.subjectId, bookId: widget.bookId)),
    );
    final chaptersAsync = ref.watch(
      chaptersProvider(
          (domainId: widget.domainId, subjectId: widget.subjectId, bookId: widget.bookId)),
    );

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: bookAsync.when(
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
                  'Failed to load book',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (book) {
          if (book == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Book not found',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.kTextPrimary)),
                ],
              ),
            );
          }

          return _BookScroll(
            book: book,
            chaptersAsync: chaptersAsync,
            domainId: widget.domainId,
            subjectId: widget.subjectId,
            bookId: widget.bookId,
            ctrl: _ctrl,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full scrollable content
// ---------------------------------------------------------------------------

class _BookScroll extends StatelessWidget {
  final BookModel book;
  final AsyncValue<List<ChapterModel>> chaptersAsync;
  final String domainId;
  final String subjectId;
  final String bookId;
  final AnimationController ctrl;

  const _BookScroll({
    required this.book,
    required this.chaptersAsync,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Hero cover app bar
        _CoverSliverAppBar(book: book, ctrl: ctrl),

        // Book meta
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: CurvedAnimation(
              parent: ctrl,
              curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
            ),
            builder: (_, child) => Opacity(
              opacity: CurvedAnimation(
                      parent: ctrl,
                      curve: const Interval(0.1, 0.6, curve: Curves.easeOut))
                  .value,
              child: child,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: _BookMeta(book: book),
            ),
          ),
        ),

        // Chapters header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Chapters',
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(width: AppSpacing.sm),
                chaptersAsync.whenOrNull(
                      data: (chapters) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '${chapters.length}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
        ),

        // Chapters list
        chaptersAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, _) => _ChapterShimmer(),
                childCount: 5,
              ),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.kError, size: 40),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Failed to load chapters',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.kTextPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (chapters) {
            if (chapters.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📄', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No chapters yet',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.kTextPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Check back soon',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = 0.15 + index * 0.05;
                    final end = (delay + 0.35).clamp(0.0, 1.0);
                    final anim = CurvedAnimation(
                      parent: ctrl,
                      curve: Interval(delay, end, curve: Curves.easeOut),
                    );
                    return _AnimatedChapterTile(
                      chapter: chapters[index],
                      domainId: domainId,
                      subjectId: subjectId,
                      bookId: bookId,
                      animation: anim,
                      isLast: index == chapters.length - 1,
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cover sliver app bar
// ---------------------------------------------------------------------------

class _CoverSliverAppBar extends StatelessWidget {
  final BookModel book;
  final AnimationController ctrl;

  const _CoverSliverAppBar({required this.book, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.kBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.kTextPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding:
            const EdgeInsets.only(left: 56, right: AppSpacing.lg, bottom: 16),
        title: Text(
          book.title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.kTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: _CoverBackground(coverUrl: book.coverUrl),
      ),
    );
  }
}

class _CoverBackground extends StatelessWidget {
  final String coverUrl;

  const _CoverBackground({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background fill
        if (coverUrl.isNotEmpty)
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.kGradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

        // Centered crisp cover (book spine look)
        Center(
          child: Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(4, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => _FallbackCover(title: ''),
                      errorWidget: (ctx, url, err) =>
                          _FallbackCover(title: ''),
                    )
                  : _FallbackCover(title: ''),
            ),
          ),
        ),

        // Bottom gradient to background
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.kBackground],
              stops: [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackCover extends StatelessWidget {
  final String title;

  const _FallbackCover({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.kGradientPrimary,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Text('📚', style: TextStyle(fontSize: 40)),
    );
  }
}

// ---------------------------------------------------------------------------
// Book meta (authors, tags, description)
// ---------------------------------------------------------------------------

class _BookMeta extends StatefulWidget {
  final BookModel book;

  const _BookMeta({required this.book});

  @override
  State<_BookMeta> createState() => _BookMetaState();
}

class _BookMetaState extends State<_BookMeta> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Authors row
        if (book.authors.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: book.authors
                .map(
                  (author) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.kSurfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 12,
                            color: AppColors.kTextSecondary),
                        const SizedBox(width: 4),
                        Text(author, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Exam tags
        if (book.examTags.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: book.examTags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.kPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Description
        if (book.description.isNotEmpty) ...[
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.description,
                  style: AppTextStyles.bodySmall,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _expanded ? 'Show less' : 'Show more',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.kPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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
// Animated chapter tile
// ---------------------------------------------------------------------------

class _AnimatedChapterTile extends StatelessWidget {
  final ChapterModel chapter;
  final String domainId;
  final String subjectId;
  final String bookId;
  final Animation<double> animation;
  final bool isLast;

  const _AnimatedChapterTile({
    required this.chapter,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
    required this.animation,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: _ChapterTile(
        chapter: chapter,
        domainId: domainId,
        subjectId: subjectId,
        bookId: bookId,
        isLast: isLast,
      ),
    );
  }
}

class _ChapterTile extends StatefulWidget {
  final ChapterModel chapter;
  final String domainId;
  final String subjectId;
  final String bookId;
  final bool isLast;

  const _ChapterTile({
    required this.chapter,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
    required this.isLast,
  });

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

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
    final chapter = widget.chapter;
    final hasQuestions = chapter.totalCards > 0;
    final diffColor = _difficultyColor(chapter.difficulty);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.forward();
      },
      onTapUp: (_) {
        _press.reverse();
        context.push(
            '/home/library/${widget.domainId}/${widget.subjectId}/${widget.bookId}/${chapter.id}');
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          margin: EdgeInsets.only(
              bottom: widget.isLast ? 0 : AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: hasQuestions
                  ? AppColors.kBorder
                  : AppColors.kBorder.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Chapter number badge
                _ChapterBadge(
                  number: chapter.chapterNumber,
                  hasQuestions: hasQuestions,
                ),
                const SizedBox(width: AppSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          // Time
                          Icon(Icons.schedule_rounded,
                              size: 11, color: AppColors.kTextSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${chapter.estimatedMinutes}m',
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Difficulty dot
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: diffColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _capitalize(chapter.difficulty),
                            style: AppTextStyles.caption
                                .copyWith(color: diffColor),
                          ),
                        ],
                      ),
                      if (hasQuestions) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${chapter.totalCards} questions',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.kPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Trailing
                hasQuestions
                    ? const Icon(
                        Icons.play_circle_rounded,
                        color: AppColors.kSuccess,
                        size: 30,
                      )
                    : _GenerateTag(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ChapterBadge extends StatelessWidget {
  final int number;
  final bool hasQuestions;

  const _ChapterBadge({required this.number, required this.hasQuestions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: hasQuestions
            ? const LinearGradient(
                colors: AppColors.kGradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasQuestions ? null : AppColors.kSurfaceVariant,
        shape: BoxShape.circle,
        boxShadow: hasQuestions
            ? [
                BoxShadow(
                  color: AppColors.kPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyles.labelSmall.copyWith(
          color: hasQuestions ? Colors.white : AppColors.kTextSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GenerateTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.5)),
        color: AppColors.kPrimaryContainer,
      ),
      child: Text(
        'Generate',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.kPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter shimmer
// ---------------------------------------------------------------------------

class _ChapterShimmer extends StatefulWidget {
  @override
  State<_ChapterShimmer> createState() => _ChapterShimmerState();
}

class _ChapterShimmerState extends State<_ChapterShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        height: 76,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment(_anim.value * 3 - 1.5, 0),
            end: Alignment(_anim.value * 3 + 0.5, 0),
            colors: const [
              AppColors.kSurface,
              AppColors.kSurfaceVariant,
              AppColors.kSurface,
            ],
          ),
        ),
      ),
    );
  }
}
