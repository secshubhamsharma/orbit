import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

class BookScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(
      bookProvider((domainId: domainId, subjectId: subjectId, bookId: bookId)),
    );
    final chaptersAsync = ref.watch(
      chaptersProvider(
          (domainId: domainId, subjectId: subjectId, bookId: bookId)),
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

          return _BookContent(
            book: book,
            chaptersAsync: chaptersAsync,
            domainId: domainId,
            subjectId: subjectId,
            bookId: bookId,
          );
        },
      ),
    );
  }
}

class _BookContent extends StatelessWidget {
  final BookModel book;
  final AsyncValue<List<ChapterModel>> chaptersAsync;
  final String domainId;
  final String subjectId;
  final String bookId;

  const _BookContent({
    required this.book,
    required this.chaptersAsync,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero app bar with cover
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.kBackground,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              book.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            titlePadding:
                const EdgeInsets.only(left: 56, right: 16, bottom: 16),
            collapseMode: CollapseMode.pin,
            background: _CoverHero(coverUrl: book.coverUrl),
          ),
        ),

        // Book info section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _BookInfoSection(book: book),
          ),
        ),

        // Chapters header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: chaptersAsync.when(
              data: (chapters) => Text(
                'Chapters (${chapters.length})',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              loading: () => Text(
                'Chapters',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              error: (err, st) => const SizedBox.shrink(),
            ),
          ),
        ),

        // Chapters list
        chaptersAsync.when(
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.kPrimary),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.kTextPrimary),
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
                  (context, index) => _ChapterTile(
                    chapter: chapters[index],
                    domainId: domainId,
                    subjectId: subjectId,
                    bookId: bookId,
                  ),
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

class _CoverHero extends StatelessWidget {
  final String coverUrl;

  const _CoverHero({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover image
        coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (ctx, url) => Container(
                  color: AppColors.kSurfaceVariant,
                ),
                errorWidget: (ctx, url, err) => Container(
                  color: AppColors.kSurfaceVariant,
                  alignment: Alignment.center,
                  child: const Text('📚', style: TextStyle(fontSize: 64)),
                ),
              )
            : Container(
                color: AppColors.kSurfaceVariant,
                alignment: Alignment.center,
                child: const Text('📚', style: TextStyle(fontSize: 64)),
              ),

        // Gradient overlay: transparent → kBackground
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.kBackground,
              ],
              stops: [0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookInfoSection extends StatefulWidget {
  final BookModel book;

  const _BookInfoSection({required this.book});

  @override
  State<_BookInfoSection> createState() => _BookInfoSectionState();
}

class _BookInfoSectionState extends State<_BookInfoSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Authors
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
                            size: 12, color: AppColors.kTextSecondary),
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
                      color:
                          AppColors.kPrimary.withValues(alpha: 0.15),
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
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final ChapterModel chapter;
  final String domainId;
  final String subjectId;
  final String bookId;

  const _ChapterTile({
    required this.chapter,
    required this.domainId,
    required this.subjectId,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
          '/home/library/$domainId/$subjectId/$bookId/${chapter.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Row(
          children: [
            // Chapter number avatar
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.kPrimary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${chapter.chapterNumber}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Title + subtitle
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
                  const SizedBox(height: 2),
                  Text(
                    '${chapter.estimatedMinutes} min · '
                    '${chapter.totalCards > 0 ? '${chapter.totalCards} cards' : 'Not generated'}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Trailing action
            chapter.totalCards == 0
                ? _GenerateChip()
                : const Icon(
                    Icons.play_circle_rounded,
                    color: AppColors.kPrimary,
                    size: 28,
                  ),
          ],
        ),
      ),
    );
  }
}

class _GenerateChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.kPrimary),
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
