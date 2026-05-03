import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/subject_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — category colours / emojis keyed by Firestore domain id
// ─────────────────────────────────────────────────────────────────────────────

Color _catColor(String id) => switch (id) {
      'school' => AppColors.kDomainSchool,
      'competitive_exams' => AppColors.kDomainCompetitive,
      'it_certifications' => AppColors.kDomainCertification,
      'finance_certifications' => AppColors.kDomainFinance,
      'language_aptitude' => AppColors.kDomainLanguage,
      _ => AppColors.kPrimary,
    };

String _catEmoji(String id) => switch (id) {
      'school' => '📚',
      'competitive_exams' => '🏆',
      'it_certifications' => '💻',
      'finance_certifications' => '💹',
      'language_aptitude' => '🌐',
      _ => '🎓',
    };

List<Color> _catGradient(String id) => switch (id) {
      'school' => const [Color(0xFF4ECDC4), Color(0xFF26A69A)],
      'competitive_exams' => const [Color(0xFFFF6B9D), Color(0xFFE0587F)],
      'it_certifications' => const [Color(0xFF7C6FE8), Color(0xFF5A4FBE)],
      'finance_certifications' => const [Color(0xFFFFD43B), Color(0xFFE0A800)],
      'language_aptitude' => const [Color(0xFF51CF66), Color(0xFF37B34D)],
      _ => const [Color(0xFF7C6FE8), Color(0xFF4ECDC4)],
    };

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  final _scrollCtrl = ScrollController();

  // 0 = "All", then index into domains list
  int _selectedCat = 0;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final domainsAsync = ref.watch(domainsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: domainsAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => _buildError(e),
        data: (domains) => _buildContent(domains),
      ),
    );
  }

  // ── skeleton ───────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: _ShimmerBox(height: 36, width: 180),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ShimmerBox(height: 48, radius: AppSpacing.radiusXl),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) =>
                  _ShimmerBox(height: 36, width: 80 + i * 12.0,
                      radius: AppSpacing.radiusFull),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _ShimmerBox(height: 20, width: 120),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (ctx, _) =>
                  _ShimmerBox(height: 200, width: 140),
            ),
          ),
        ],
      ),
    );
  }

  // ── error ──────────────────────────────────────────────────────────────────

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.kError, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load library',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(domainsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── main content ───────────────────────────────────────────────────────────

  Widget _buildContent(List<DomainModel> cats) {
    // "All" = index 0, then cats[0], cats[1], …
    final activeCat = _selectedCat == 0 ? null : cats[_selectedCat - 1];

    return CustomScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── fixed top bar ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: _TopBar(ctrl: _entranceCtrl),
          ),
        ),

        // ── search bar ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entranceCtrl,
              curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
              child: _SearchBar(),
            ),
          ),
        ),

        // ── category chips ─────────────────────────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _ChipBarDelegate(
            cats: cats,
            selected: _selectedCat,
            onSelect: (i) => setState(() => _selectedCat = i),
            ctrl: _entranceCtrl,
          ),
        ),

        // ── body ───────────────────────────────────────────────────────────
        if (activeCat == null)
          // "All" — one carousel section per category
          ..._buildAllSections(cats)
        else
          // Specific category — subjects with book carousels
          _buildCategorySection(activeCat),

        const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl)),
      ],
    );
  }

  // ── "All" view: one row per category ──────────────────────────────────────

  List<Widget> _buildAllSections(List<DomainModel> cats) {
    return [
      for (var i = 0; i < cats.length; i++)
        SliverToBoxAdapter(
          child: _CategoryRow(
            cat: cats[i],
            entrance: CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(
                0.15 + i * 0.07,
                (0.55 + i * 0.07).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
            onSeeAll: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedCat = i + 1);
              _scrollCtrl.animateTo(
                0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            },
          ),
        ),
    ];
  }

  // ── specific category: subjects → book carousels ───────────────────────────

  Widget _buildCategorySection(DomainModel cat) {
    return _SliverSubjectList(cat: cat);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final AnimationController ctrl;

  const _TopBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: ctrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.md, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Browse',
                    style: AppTextStyles.displayMedium,
                  ),
                  Text(
                    'Find your next subject to master',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.go('/home/search'),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.kBorder),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: AppColors.kTextPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search bar (tap → navigate, no shortcuts)
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) => GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/home/search');
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.kBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPrimary
                    .withValues(alpha: 0.06 + _glow.value * 0.08),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.search_rounded,
                  color: AppColors.kTextSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Search books, subjects…',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky category chip bar
// ─────────────────────────────────────────────────────────────────────────────

class _ChipBarDelegate extends SliverPersistentHeaderDelegate {
  final List<DomainModel> cats;
  final int selected;
  final ValueChanged<int> onSelect;
  final AnimationController ctrl;

  const _ChipBarDelegate({
    required this.cats,
    required this.selected,
    required this.onSelect,
    required this.ctrl,
  });

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  bool shouldRebuild(_ChipBarDelegate o) =>
      o.selected != selected || o.cats.length != cats.length;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.kBackground.withValues(
            alpha: (shrinkOffset / maxExtent).clamp(0.0, 1.0) * 0.95 + 0.7),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: ctrl,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          itemCount: cats.length + 1,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, i) {
            final isAll = i == 0;
            final isSelected = selected == i;
            final catId = isAll ? '' : cats[i - 1].id;
            final label = isAll ? 'All' : cats[i - 1].name;
            final color = isAll ? AppColors.kPrimary : _catColor(catId);

            return _CategoryChip(
              label: label,
              emoji: isAll ? null : _catEmoji(catId),
              color: color,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                onSelect(i);
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  final String? emoji;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.emoji,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)],
                  )
                : null,
            color: widget.isSelected ? null : AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : AppColors.kBorder,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.emoji != null) ...[
                Text(widget.emoji!,
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
              ],
              Text(
                widget.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.kTextSecondary,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "All" view — one category row with horizontal subject carousel
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryRow extends ConsumerWidget {
  final DomainModel cat;
  final Animation<double> entrance;
  final VoidCallback onSeeAll;

  const _CategoryRow({
    required this.cat,
    required this.entrance,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(cat.id));
    final color = _catColor(cat.id);
    final emoji = _catEmoji(cat.id);
    final gradient = _catGradient(cat.id);

    return FadeTransition(
      opacity: entrance,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(entrance),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  // Emoji badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: AppTextStyles.headingSmall,
                    ),
                  ),
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Text(
                      'See all',
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal carousel
            subjectsAsync.when(
              loading: () => _SubjectCarouselSkeleton(),
              error: (err, _) => const SizedBox.shrink(),
              data: (subjects) => subjects.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 195,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        itemCount: subjects.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (ctx, i) => _SubjectCard(
                          subject: subjects[i],
                          catId: cat.id,
                          color: color,
                          gradient: gradient,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Subject card in the "All" carousel — shows subject as a book-spine card
class _SubjectCard extends StatefulWidget {
  final SubjectModel subject;
  final String catId;
  final Color color;
  final List<Color> gradient;

  const _SubjectCard({
    required this.subject,
    required this.catId,
    required this.color,
    required this.gradient,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.reverse();
      },
      onTapUp: (_) {
        _press.forward();
        context.push('/home/library/${widget.catId}/${subject.id}');
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover card — book-spine style
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.color.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Radial highlight
                      Positioned(
                        top: -20,
                        left: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject.name,
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: Colors.white),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                              ),
                              child: Text(
                                '${subject.totalTopics} books',
                                style: AppTextStyles.caption
                                    .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subject.name,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subject.applicableExams.isNotEmpty)
                Text(
                  subject.applicableExams.take(2).join(' · '),
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectCarouselSkeleton extends StatefulWidget {
  @override
  State<_SubjectCarouselSkeleton> createState() =>
      _SubjectCarouselSkeletonState();
}

class _SubjectCarouselSkeletonState
    extends State<_SubjectCarouselSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a;

  @override
  void initState() {
    super.initState();
    _a = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 4,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, i) => AnimatedBuilder(
          animation: _a,
          builder: (_, child) => SizedBox(
            width: 140,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                gradient: LinearGradient(
                  begin:
                      Alignment(_a.value * 3 - 1.5, 0),
                  end: Alignment(
                      _a.value * 3 + 0.5, 0),
                  colors: const [
                    AppColors.kSurface,
                    AppColors.kSurfaceVariant,
                    AppColors.kSurface,
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

// ─────────────────────────────────────────────────────────────────────────────
// Specific category view — subjects each with a book carousel
// ─────────────────────────────────────────────────────────────────────────────

class _SliverSubjectList extends ConsumerWidget {
  final DomainModel cat;

  const _SliverSubjectList({required this.cat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(cat.id));

    return subjectsAsync.when(
      loading: () => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: const Center(
            child:
                CircularProgressIndicator(color: AppColors.kPrimary),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text('Could not load subjects',
                style: AppTextStyles.bodySmall),
          ),
        ),
      ),
      data: (subjects) {
        if (subjects.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📖', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text('No content yet',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.kTextPrimary)),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _SubjectSection(
              subject: subjects[i],
              catId: cat.id,
              catColor: _catColor(cat.id),
            ),
            childCount: subjects.length,
          ),
        );
      },
    );
  }
}

// Each subject becomes a book-carousel section
class _SubjectSection extends ConsumerWidget {
  final SubjectModel subject;
  final String catId;
  final Color catColor;

  const _SubjectSection({
    required this.subject,
    required this.catId,
    required this.catColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(
        booksProvider((domainId: catId, subjectId: subject.id)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject header
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: AppTextStyles.headingSmall),
                    if (subject.applicableExams.isNotEmpty)
                      Text(
                        subject.applicableExams.take(3).join(' · '),
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context
                    .push('/home/library/$catId/${subject.id}'),
                child: Text(
                  'See all',
                  style: AppTextStyles.caption.copyWith(
                    color: catColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Books carousel
        booksAsync.when(
          loading: () => _BookCarouselSkeleton(),
          error: (err, _) => const SizedBox.shrink(),
          data: (books) => books.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Text(
                    'No books yet — check back soon.',
                    style: AppTextStyles.caption,
                  ),
                )
              : SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount: books.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (ctx, i) => _BookCarouselCard(
                      book: books[i],
                      catId: catId,
                      subjectId: subject.id,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Book carousel card
// ─────────────────────────────────────────────────────────────────────────────

class _BookCarouselCard extends StatefulWidget {
  final BookModel book;
  final String catId;
  final String subjectId;

  const _BookCarouselCard({
    required this.book,
    required this.catId,
    required this.subjectId,
  });

  @override
  State<_BookCarouselCard> createState() => _BookCarouselCardState();
}

class _BookCarouselCardState extends State<_BookCarouselCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  // A deterministic gradient per book title
  static const _palettes = [
    [Color(0xFF7C6FE8), Color(0xFF4ECDC4)],
    [Color(0xFFFF6B9D), Color(0xFFFF9F43)],
    [Color(0xFF51CF66), Color(0xFF4ECDC4)],
    [Color(0xFFFFD43B), Color(0xFFFF6B9D)],
    [Color(0xFF4ECDC4), Color(0xFF7C6FE8)],
    [Color(0xFFFF9F43), Color(0xFF7C6FE8)],
  ];

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final palette = _palettes[
        book.title.isNotEmpty ? book.title.codeUnitAt(0) % _palettes.length : 0];

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.reverse();
      },
      onTapUp: (_) {
        _press.forward();
        context.push(
            '/home/library/${widget.catId}/${widget.subjectId}/${book.id}');
      },
      onTapCancel: () => _press.forward(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: _press.value, child: child),
        child: SizedBox(
          width: 130,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      book.coverUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) =>
                                  _GradCover(palette: palette, title: book.title),
                              errorWidget: (ctx, url, err) =>
                                  _GradCover(palette: palette, title: book.title),
                            )
                          : _GradCover(palette: palette, title: book.title),
                      // Subtle sheen border
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                book.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (book.authors.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  book.authors.first,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
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
      ),
    );
  }
}

class _GradCover extends StatelessWidget {
  final List<Color> palette;
  final String title;

  const _GradCover({required this.palette, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        title.isNotEmpty ? title[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BookCarouselSkeleton extends StatefulWidget {
  @override
  State<_BookCarouselSkeleton> createState() => _BookCarouselSkeletonState();
}

class _BookCarouselSkeletonState extends State<_BookCarouselSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a;

  @override
  void initState() {
    super.initState();
    _a = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: 4,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (ctx, _) => AnimatedBuilder(
          animation: _a,
          builder: (ctx2, child) => SizedBox(
            width: 130,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                gradient: LinearGradient(
                  begin: Alignment(_a.value * 3 - 1.5, 0),
                  end: Alignment(_a.value * 3 + 0.5, 0),
                  colors: const [
                    AppColors.kSurface,
                    AppColors.kSurfaceVariant,
                    AppColors.kSurface,
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared shimmer box
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    this.width,
    this.radius = AppSpacing.radiusMd,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _a;

  @override
  void initState() {
    super.initState();
    _a = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _a.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, child) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_a.value * 3 - 1.5, 0),
            end: Alignment(_a.value * 3 + 0.5, 0),
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
