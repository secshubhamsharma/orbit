import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

class SubjectScreen extends ConsumerWidget {
  final String domainId;
  final String subjectId;

  const SubjectScreen({
    super.key,
    required this.domainId,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider(domainId));
    final booksAsync =
        ref.watch(booksProvider((domainId: domainId, subjectId: subjectId)));

    final subjectName = subjectsAsync.whenOrNull(
      data: (subjects) {
        try {
          return subjects.firstWhere((s) => s.id == subjectId).name;
        } catch (_) {
          return null;
        }
      },
    );

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
        title: Text(
          subjectName ?? 'Books',
          style: AppTextStyles.headingSmall,
        ),
      ),
      body: booksAsync.when(
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
                  'Failed to load books',
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
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📚', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No books yet',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.kTextPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Check back soon', style: AppTextStyles.caption),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) => _BookCard(
              book: books[index],
              domainId: domainId,
              subjectId: subjectId,
            ),
          );
        },
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final String domainId;
  final String subjectId;

  const _BookCard({
    required this.book,
    required this.domainId,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('/home/library/$domainId/$subjectId/${book.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image — ~70% of height
          Expanded(
            flex: 7,
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
              child: book.coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (ctx, url) => _BookPlaceholder(),
                      errorWidget: (ctx, url, err) => _BookPlaceholder(),
                    )
                  : _BookPlaceholder(),
            ),
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

          // Chapter count
          const SizedBox(height: 2),
          Text(
            '${book.totalChapters} chapters',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.kPrimary),
          ),
        ],
      ),
    );
  }
}

class _BookPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.kSurfaceVariant,
      alignment: Alignment.center,
      child: const Text('📖', style: TextStyle(fontSize: 40)),
    );
  }
}
