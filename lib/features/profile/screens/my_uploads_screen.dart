import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/pdf_upload_model.dart';
import 'package:orbitapp/providers/auth_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

final _userUploadsProvider = FutureProvider<List<PdfUploadModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return FirestoreService.instance.getUserUploads(user.uid);
});

class MyUploadsScreen extends ConsumerWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadsAsync = ref.watch(_userUploadsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('My Uploads', style: AppTextStyles.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.kTextSecondary, size: 20),
            onPressed: () => ref.invalidate(_userUploadsProvider),
          ),
        ],
      ),
      body: uploadsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kPrimary),
        ),
        error: (e, _) => _ErrorState(
          onRetry: () => ref.invalidate(_userUploadsProvider),
        ),
        data: (uploads) =>
            uploads.isEmpty ? const _EmptyState() : _UploadList(uploads),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List
// ---------------------------------------------------------------------------

class _UploadList extends StatelessWidget {
  final List<PdfUploadModel> uploads;
  const _UploadList(this.uploads);

  @override
  Widget build(BuildContext context) {
    final processing = uploads.where((u) => u.isProcessing).toList();
    final completed = uploads.where((u) => u.isCompleted).toList();
    final failed = uploads.where((u) => u.isFailed).toList();
    final sorted = [...processing, ...completed, ...failed];

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: sorted.length,
      separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _UploadCard(sorted[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

class _UploadCard extends StatelessWidget {
  final PdfUploadModel upload;
  const _UploadCard(this.upload);

  @override
  Widget build(BuildContext context) {
    final (color, label) = _statusInfo(upload.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.kSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                size: 22, color: AppColors.kError),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  upload.topicName.isNotEmpty
                      ? upload.topicName
                      : upload.fileName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                if (upload.topicName.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    upload.fileName,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Meta row
                Row(
                  children: [
                    if (upload.pageCount > 0) ...[
                      Text('${upload.pageCount} pages',
                          style: AppTextStyles.caption),
                      _dot(),
                    ],
                    if (upload.fileSizeMB > 0) ...[
                      Text(
                          '${upload.fileSizeMB.toStringAsFixed(1)} MB',
                          style: AppTextStyles.caption),
                      _dot(),
                    ],
                    Text(_timeAgo(upload.uploadedAt),
                        style: AppTextStyles.caption),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Status + cards
                Row(
                  children: [
                    _StatusBadge(color: color, label: label,
                        spinning: upload.isProcessing),
                    if (upload.isCompleted &&
                        upload.generatedCardCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${upload.generatedCardCount} cards generated',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.kSuccess),
                      ),
                    ],
                  ],
                ),

                if (upload.isFailed && upload.error != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    upload.error!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kError),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text('·', style: AppTextStyles.caption),
      );

  (Color, String) _statusInfo(String status) {
    return switch (status) {
      'completed' => (AppColors.kSuccess, 'Completed'),
      'failed' => (AppColors.kError, 'Failed'),
      'processing' => (AppColors.kWarning, 'Processing'),
      _ => (AppColors.kTextSecondary, 'Uploading'),
    };
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${m[dt.month - 1]}';
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String label;
  final bool spinning;

  const _StatusBadge({
    required this.color,
    required this.label,
    required this.spinning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (spinning)
            SizedBox(
              width: 9,
              height: 9,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: color),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / Error states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.upload_file_outlined,
                  size: 34, color: AppColors.kTextDisabled),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No uploads yet', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Upload a PDF to generate flashcards from your own notes.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => context.push('/upload'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.kPrimary,
                side: const BorderSide(color: AppColors.kPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd)),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              ),
              child: Text('Upload PDF',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.kError, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text('Failed to load uploads', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            ),
            child: Text('Retry',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kTextSecondary)),
          ),
        ],
      ),
    );
  }
}
