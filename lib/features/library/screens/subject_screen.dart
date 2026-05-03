import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

// ---------------------------------------------------------------------------
// Subject screen — shows the books grid within a subject
// ---------------------------------------------------------------------------

class SubjectScreen extends ConsumerStatefulWidget {
  final String domainId;
  final String subjectId;

  const SubjectScreen({
    super.key,
    required this.domainId,
    required this.subjectId,
  });

  @override
  ConsumerState<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends ConsumerState<SubjectScreen>
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
    final subjectsAsync = ref.watch(subjectsProvider(widget.domainId));
    final booksAsync = ref.watch(
        booksProvider((domainId: widget.domainId, subjectId: widget.subjectId)));

    final subjectName = subjectsAsync.whenOrNull(
      data: (subjects) {
        try {
          return subjects.firstWhere((s) => s.id == widget.subjectId).name;
        } catch (_) {
          return null;
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.kBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.kTextPrimary, size: 20),
              onPressed: () => context.pop(),
            ),
            title: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) => Opacity(opacity: _ctrl.value, child: child),
              child: Text(
                subjectName ?? 'Books',
                style: AppTextStyles.headingSmall,
              ),
            ),
            actions: [
              booksAsync.whenOrNull(
                    data: (books) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryContainer,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            '${books.length} books',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),

          // Content
          booksAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => _buildError(e),
            data: (books) {
              if (books.isEmpty) return _buildEmpty();
              return _BookGrid(
                books: books,
                domainId: widget.domainId,
                subjectId: widget.subjectId,
                ctrl: _ctrl,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, _) => _BookShimmer(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildError(Object e) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.kError, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load books',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.kTextPrimary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📚', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No books yet',
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.kTextPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Check back soon', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Book grid
// ---------------------------------------------------------------------------

class _BookGrid extends StatelessWidget {
  final List<BookModel> books;
  final String domainId;
  final String subjectId;
  final AnimationController ctrl;

  const _BookGrid({
    required this.books,
    required this.domainId,
    required this.subjectId,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final delay = 0.1 + (index % 4) * 0.05;
            final end = (delay + 0.4).clamp(0.0, 1.0);
            final anim = CurvedAnimation(
              parent: ctrl,
              curve: Interval(delay, end, curve: Curves.easeOut),
            );
            return _AnimatedBookCard(
              book: books[index],
              domainId: domainId,
              subjectId: subjectId,
              animation: anim,
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}

class _AnimatedBookCard extends StatelessWidget {
  final BookModel book;
  final String domainId;
  final String subjectId;
  final Animation<double> animation;

  const _AnimatedBookCard({
    required this.book,
    required this.domainId,
    required this.subjectId,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: _BookCard(book: book, domainId: domainId, subjectId: subjectId),
    );
  }
}

class _BookCard extends StatefulWidget {
  final BookModel book;
  final String domainId;
  final String subjectId;

  const _BookCard({
    required this.book,
    required this.domainId,
    required this.subjectId,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.forward();
      },
      onTapUp: (_) {
        _press.reverse();
        context.push(
            '/home/library/${widget.domainId}/${widget.subjectId}/${book.id}');
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover — 70% of height
            Expanded(
              flex: 7,
              child: _BookCover(book: book),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              book.title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Author
            if (book.authors.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                book.authors.first,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Chapter count chip
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    '${book.totalChapters} ch',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.kPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Book cover — gradient placeholder if no image
// ---------------------------------------------------------------------------

class _BookCover extends StatelessWidget {
  final BookModel book;

  const _BookCover({required this.book});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or gradient placeholder
          if (book.coverUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: book.coverUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, url) =>
                  _GradientPlaceholder(title: book.title),
              errorWidget: (ctx, url, err) =>
                  _GradientPlaceholder(title: book.title),
            )
          else
            _GradientPlaceholder(title: book.title),

          // Subtle border overlay
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientPlaceholder extends StatelessWidget {
  final String title;

  static final _palettes = [
    [const Color(0xFF7C6FE8), const Color(0xFF4ECDC4)],
    [const Color(0xFFFF6B9D), const Color(0xFFFF9F43)],
    [const Color(0xFF51CF66), const Color(0xFF4ECDC4)],
    [const Color(0xFFFFD43B), const Color(0xFFFF6B9D)],
    [const Color(0xFF4ECDC4), const Color(0xFF7C6FE8)],
  ];

  const _GradientPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[math.max(0, title.codeUnitAt(0)) % _palettes.length];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer book card placeholder
// ---------------------------------------------------------------------------

class _BookShimmer extends StatefulWidget {
  @override
  State<_BookShimmer> createState() => _BookShimmerState();
}

class _BookShimmerState extends State<_BookShimmer>
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

  Widget _box(double height, {double? width, double radius = AppSpacing.radiusMd}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _box(double.infinity, radius: AppSpacing.radiusMd)),
        const SizedBox(height: AppSpacing.sm),
        _box(12),
        const SizedBox(height: AppSpacing.xs),
        _box(10, width: 80),
        const SizedBox(height: AppSpacing.xs),
        _box(18, width: 50, radius: AppSpacing.radiusFull),
      ],
    );
  }
}
