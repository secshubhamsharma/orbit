import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/subject_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

class DomainScreen extends ConsumerWidget {
  final String domainId;

  const DomainScreen({super.key, required this.domainId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainsAsync = ref.watch(domainsProvider);
    final subjectsAsync = ref.watch(subjectsProvider(domainId));

    final domainName = domainsAsync.whenOrNull(
      data: (domains) {
        try {
          return domains.firstWhere((d) => d.id == domainId).name;
        } catch (_) {
          return null;
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
                domainName ?? 'Domain',
                style: AppTextStyles.headingSmall,
              ),
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16),
              collapseMode: CollapseMode.pin,
            ),
          ),
          subjectsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                    color: AppColors.kPrimary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
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
                        'Failed to load subjects',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.kTextPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        e.toString(),
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
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
                        const Text('📖',
                            style: TextStyle(fontSize: 56)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No subjects yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.kTextPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Check back soon',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SubjectTile(
                      subject: subjects[index],
                      domainId: domainId,
                    ),
                    childCount: subjects.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final String domainId;

  const _SubjectTile({required this.subject, required this.domainId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/home/library/$domainId/${subject.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Row(
          children: [
            // Icon / avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.kPrimaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              alignment: Alignment.center,
              child: Text(
                subject.name.isNotEmpty
                    ? subject.name[0].toUpperCase()
                    : '?',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.kPrimary),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Name + exam tags
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                  ),
                  if (subject.applicableExams.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    _ExamTagRow(exams: subject.applicableExams),
                  ],
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Right side: count + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${subject.totalTopics} books',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.kTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamTagRow extends StatelessWidget {
  final List<String> exams;

  const _ExamTagRow({required this.exams});

  @override
  Widget build(BuildContext context) {
    final visible = exams.take(3).toList();

    return Row(
      children: visible
          .map(
            (tag) => Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                tag.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.kTextSecondary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
