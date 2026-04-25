import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    ref.read(searchProvider.notifier).setQuery(v);
  }

  void _onSubmitted(String v) {
    ref.read(searchProvider.notifier).submitSearch(v);
    _focusNode.unfocus();
  }

  void _onClear() {
    _controller.clear();
    ref.read(searchProvider.notifier).clearQuery();
    _focusNode.requestFocus();
  }

  void _onRecentTap(String query) {
    _controller.text = query;
    _controller.selection =
        TextSelection.collapsed(offset: query.length);
    ref.read(searchProvider.notifier).setQuery(query);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.kBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Text('Search', style: AppTextStyles.headingLarge),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Search bar ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: _SearchBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  hasText: state.query.isNotEmpty,
                  onChanged: _onChanged,
                  onSubmitted: _onSubmitted,
                  onClear: _onClear,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Filter chips (only when results exist) ────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: state.hasQuery && state.hasResults
                    ? _FilterChips(
                        selected: state.filter,
                        bookCount: state.bookResults.length,
                        chapterCount: state.chapterResults.length,
                        onSelect: (f) =>
                            ref.read(searchProvider.notifier).setFilter(f),
                      )
                    : const SizedBox.shrink(),
              ),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _buildBody(state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (!state.hasQuery) {
      return _IdleView(
        key: const ValueKey('idle'),
        recentSearches: state.recentSearches,
        onRecentTap: _onRecentTap,
        onRecentRemove: (q) =>
            ref.read(searchProvider.notifier).removeRecent(q),
        onClearRecent: () =>
            ref.read(searchProvider.notifier).clearRecent(),
      );
    }

    if (state.isLoading) {
      return const _LoadingView(key: ValueKey('loading'));
    }

    if (state.error != null) {
      return _ErrorView(
        key: const ValueKey('error'),
        message: state.error!,
        onRetry: () =>
            ref.read(searchProvider.notifier).setQuery(state.query),
      );
    }

    if (!state.hasResults) {
      return _EmptyResultsView(
        key: const ValueKey('empty'),
        query: state.query,
      );
    }

    return _ResultsView(
      key: ValueKey('results_${state.filter.name}'),
      state: state,
    );
  }
}

// ---------------------------------------------------------------------------
// Search bar
// ---------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.md),
          const Icon(Icons.search_rounded,
              size: 20, color: AppColors.kTextSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: AppTextStyles.bodyMedium,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Books, chapters, topics…',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextDisabled),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.kTextDisabled,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 13, color: AppColors.kBackground),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('no-clear'), width: AppSpacing.md),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips
// ---------------------------------------------------------------------------

class _FilterChips extends StatelessWidget {
  final SearchFilter selected;
  final int bookCount;
  final int chapterCount;
  final ValueChanged<SearchFilter> onSelect;

  const _FilterChips({
    required this.selected,
    required this.bookCount,
    required this.chapterCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      (SearchFilter.all, 'All', bookCount + chapterCount),
      (SearchFilter.books, 'Books', bookCount),
      (SearchFilter.chapters, 'Chapters', chapterCount),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg),
          itemCount: options.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final (filter, label, count) = options[i];
            final isSelected = selected == filter;
            return GestureDetector(
              onTap: () => onSelect(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.kPrimary
                      : AppColors.kSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.kPrimary
                        : AppColors.kBorder,
                  ),
                ),
                child: Text(
                  count > 0 ? '$label  $count' : label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.kTextSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Idle view — recent searches + category tiles
// ---------------------------------------------------------------------------

class _IdleView extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onRecentTap;
  final ValueChanged<String> onRecentRemove;
  final VoidCallback onClearRecent;

  const _IdleView({
    super.key,
    required this.recentSearches,
    required this.onRecentTap,
    required this.onRecentRemove,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      children: [
        // Recent searches
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: AppTextStyles.headingSmall),
              GestureDetector(
                onTap: onClearRecent,
                child: Text('Clear all',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: recentSearches
                .map((q) => _RecentChip(
                      query: q,
                      onTap: () => onRecentTap(q),
                      onRemove: () => onRecentRemove(q),
                    ))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Browse by category
        Text('Browse by category', style: AppTextStyles.headingSmall),
        const SizedBox(height: AppSpacing.md),
        _CategoryGrid(),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentChip({
    required this.query,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded,
                size: 14, color: AppColors.kTextDisabled),
            const SizedBox(width: 6),
            Text(query,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.kTextPrimary)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 13, color: AppColors.kTextDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  static const _categories = [
    (
      'School',
      Icons.school_rounded,
      AppColors.kDomainSchool,
      'school',
    ),
    (
      'Competitive',
      Icons.emoji_events_rounded,
      AppColors.kDomainCompetitive,
      'competitive_exams',
    ),
    (
      'IT Certs',
      Icons.computer_rounded,
      AppColors.kDomainCertification,
      'it_certifications',
    ),
    (
      'Finance',
      Icons.account_balance_rounded,
      AppColors.kDomainFinance,
      'finance_certifications',
    ),
    (
      'Language',
      Icons.translate_rounded,
      AppColors.kDomainLanguage,
      'language_aptitude',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 2.6,
      children: _categories
          .map((c) => _CategoryTile(
                label: c.$1,
                icon: c.$2,
                color: c.$3,
                domainId: c.$4,
              ))
          .toList(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String domainId;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.domainId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/library/$domainId'),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kTextPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading view — shimmer skeletons
// ---------------------------------------------------------------------------

class _LoadingView extends StatefulWidget {
  const _LoadingView({super.key});

  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final shimmerColor = Color.lerp(
          AppColors.kSurface,
          AppColors.kSurfaceVariant,
          (0.5 - (_shimmer.value - 0.5).abs()) * 2,
        )!;
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: 6,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) => _ShimmerTile(color: shimmerColor),
        );
      },
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  final Color color;
  const _ShimmerTile({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 140,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
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

// ---------------------------------------------------------------------------
// Results view
// ---------------------------------------------------------------------------

class _ResultsView extends StatelessWidget {
  final SearchState state;
  const _ResultsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final books = state.filteredBooks;
    final chapters = state.filteredChapters;

    final items = <_ResultItem>[
      if (books.isNotEmpty) ...[
        _ResultItem.sectionHeader('Books  ${books.length}'),
        ...books.map(_ResultItem.book),
      ],
      if (chapters.isNotEmpty) ...[
        _ResultItem.sectionHeader('Chapters  ${chapters.length}'),
        ...chapters.map(_ResultItem.chapter),
      ],
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.xl),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _AnimatedResultItem(
          index: index,
          child: item.isSectionHeader
              ? _SectionHeader(label: item.label!)
              : item.book != null
                  ? _BookTile(book: item.book!)
                  : _ChapterTile(chapter: item.chapter!),
        );
      },
    );
  }
}

class _ResultItem {
  final String? label;
  final BookModel? book;
  final ChapterModel? chapter;

  const _ResultItem._({this.label, this.book, this.chapter});

  factory _ResultItem.sectionHeader(String label) =>
      _ResultItem._(label: label);
  factory _ResultItem.book(BookModel b) => _ResultItem._(book: b);
  factory _ResultItem.chapter(ChapterModel c) => _ResultItem._(chapter: c);

  bool get isSectionHeader => label != null;
}

class _AnimatedResultItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedResultItem({required this.index, required this.child});

  @override
  State<_AnimatedResultItem> createState() => _AnimatedResultItemState();
}

class _AnimatedResultItemState extends State<_AnimatedResultItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger each item by 40ms
    Future.delayed(
      Duration(milliseconds: widget.index * 40),
      () { if (mounted) _ctrl.forward(); },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Book tile
// ---------------------------------------------------------------------------

class _BookTile extends StatelessWidget {
  final BookModel book;
  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
          '/home/library/${book.domainId}/${book.subjectId}/${book.id}'),
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
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: book.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      width: 46,
                      height: 62,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _BookCoverPlaceholder(),
                      errorWidget: (_, __, ___) => _BookCoverPlaceholder(),
                    )
                  : _BookCoverPlaceholder(),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.authors.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.authors.join(', '),
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      _Tag(
                        label: 'Book',
                        color: AppColors.kPrimary,
                      ),
                      if (book.totalChapters > 0) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _Tag(
                          label: '${book.totalChapters} chapters',
                          color: AppColors.kTextDisabled,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.kTextDisabled),
          ],
        ),
      ),
    );
  }
}

class _BookCoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 62,
      color: AppColors.kSurfaceVariant,
      child: const Icon(Icons.menu_book_rounded,
          size: 22, color: AppColors.kTextDisabled),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapter tile
// ---------------------------------------------------------------------------

class _ChapterTile extends StatelessWidget {
  final ChapterModel chapter;
  const _ChapterTile({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(chapter.difficulty);

    return GestureDetector(
      onTap: () => context.push(
        '/home/library/${chapter.domainId}/${chapter.subjectId}/${chapter.bookId}/${chapter.id}',
      ),
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
            // Chapter number badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.kPrimaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Center(
                child: chapter.chapterNumber > 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${chapter.chapterNumber}',
                            style: AppTextStyles.headingSmall
                                .copyWith(color: AppColors.kPrimary),
                          ),
                          Text(
                            'Ch',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.kPrimary, fontSize: 9),
                          ),
                        ],
                      )
                    : const Icon(Icons.article_outlined,
                        size: 20, color: AppColors.kPrimary),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Tag(
                        label: 'Chapter',
                        color: AppColors.kSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _Tag(
                        label: chapter.difficulty,
                        color: diffColor,
                      ),
                      if (chapter.totalCards > 0) ...[
                        const SizedBox(width: AppSpacing.xs),
                        _Tag(
                          label: '${chapter.totalCards} cards',
                          color: AppColors.kTextDisabled,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.kTextDisabled),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String d) {
    return switch (d) {
      'intermediate' => AppColors.kDifficultyMedium,
      'advanced' => AppColors.kDifficultyHard,
      _ => AppColors.kDifficultyEasy,
    };
  }
}

// ---------------------------------------------------------------------------
// Shared tag chip
// ---------------------------------------------------------------------------

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty results
// ---------------------------------------------------------------------------

class _EmptyResultsView extends StatelessWidget {
  final String query;
  const _EmptyResultsView({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(Icons.search_off_rounded,
                  size: 36, color: AppColors.kTextDisabled),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No results for', style: AppTextStyles.headingSmall),
            const SizedBox(height: 4),
            Text(
              '"$query"',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a different keyword, or browse the library to find what you need.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => context.go('/home/library'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.kPrimary,
                side: const BorderSide(color: AppColors.kPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md),
              ),
              child: Text('Browse Library',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.kTextDisabled),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('Try again',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kTextSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
