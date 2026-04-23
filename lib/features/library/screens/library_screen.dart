import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domainsAsync = ref.watch(domainsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Library',
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: domainsAsync.when(
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
                  'Failed to load library',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextPrimary),
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
        data: (domains) {
          if (domains.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text('No domains yet',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.kTextPrimary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Check back soon',
                      style: AppTextStyles.caption),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _DomainCard(domain: domains[index]),
                    childCount: domains.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final DomainModel domain;

  const _DomainCard({required this.domain});

  Color _domainColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('0xFF$h'));
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _domainColor(domain.colorHex);

    return GestureDetector(
      onTap: () => context.push('/home/library/${domain.id}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              baseColor.withValues(alpha: 0.15),
              baseColor.withValues(alpha: 0.30),
            ],
          ),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DomainIcon(domain: domain, color: baseColor),
            const Spacer(),
            Text(
              domain.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${domain.totalTopics} topics',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainIcon extends StatelessWidget {
  final DomainModel domain;
  final Color color;

  const _DomainIcon({required this.domain, required this.color});

  String _emojiForDomain(String id) {
    return switch (id) {
      'school' => '🏫',
      'competitive_exams' => '🎯',
      'it_certifications' => '💻',
      'finance_certifications' => '📈',
      'language_aptitude' => '🌐',
      _ => domain.name.isNotEmpty ? domain.name[0].toUpperCase() : '📚',
    };
  }

  bool _isEmoji(String value) =>
      value.runes.first > 127;

  @override
  Widget build(BuildContext context) {
    final label = _emojiForDomain(domain.id);
    final isEmoji = _isEmoji(label);

    if (isEmoji) {
      return Text(label, style: const TextStyle(fontSize: 32));
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.headingMedium.copyWith(color: color),
      ),
    );
  }
}
