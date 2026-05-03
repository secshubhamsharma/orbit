import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/pdf_chapter_model.dart';
import 'package:orbitapp/models/pdf_upload_model.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';
import 'package:orbitapp/providers/quiz_progress_provider.dart';

class PdfPreviewScreen extends ConsumerWidget {
  final String uploadId;
  const PdfPreviewScreen({super.key, required this.uploadId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadAsync = ref.watch(uploadStreamProvider(uploadId));

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: uploadAsync.when(
          loading: () => const _CenteredLoader(),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(uploadStreamProvider(uploadId)),
          ),
          data: (upload) {
            if (upload == null) return const _CenteredLoader();
            return _UploadBody(upload: upload, uploadId: uploadId, ref: ref);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body — decides which view to show based on upload status
// ---------------------------------------------------------------------------

class _UploadBody extends StatelessWidget {
  const _UploadBody({
    required this.upload,
    required this.uploadId,
    required this.ref,
  });
  final PdfUploadModel upload;
  final String uploadId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AppBar(upload: upload),
        Expanded(
          child: switch (upload.status) {
            'completed' => _ChaptersView(uploadId: uploadId, upload: upload),
            'failed' => _FailedView(upload: upload),
            _ => _ProcessingView(upload: upload),
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// App bar
// ---------------------------------------------------------------------------

class _AppBar extends StatelessWidget {
  const _AppBar({required this.upload});
  final PdfUploadModel upload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/home/profile/uploads'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.kSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.kTextPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upload.topicName.isNotEmpty
                      ? upload.topicName
                      : upload.fileName,
                  style: AppTextStyles.headingSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (upload.topicName.isNotEmpty)
                  Text(upload.fileName,
                      style: AppTextStyles.caption, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Processing view (while status is uploading/processing)
// ---------------------------------------------------------------------------

class _ProcessingView extends StatefulWidget {
  const _ProcessingView({required this.upload});
  final PdfUploadModel upload;

  @override
  State<_ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<_ProcessingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = widget.upload.status == 'uploading';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.kGradientPrimary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kPrimary.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isUploading
                    ? Icons.cloud_upload_rounded
                    : Icons.auto_awesome_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          Text(
            isUploading
                ? 'Sending to server...'
                : 'AI is reading your PDF',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            isUploading
                ? 'Your PDF is being uploaded to the AI server.'
                : 'Detecting chapters, understanding content,\nand creating flashcards for each section.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.kTextSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Indeterminate progress
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: const LinearProgressIndicator(
              backgroundColor: AppColors.kSurfaceVariant,
              valueColor: AlwaysStoppedAnimation(AppColors.kPrimary),
              minHeight: 5,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          _StepsList(status: widget.upload.status),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  const _StepsList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('uploading', Icons.upload_rounded, 'PDF uploaded'),
      ('processing', Icons.search_rounded, 'Chapters detected'),
      ('processing', Icons.auto_awesome_rounded, 'Flashcards generated'),
      ('completed', Icons.check_circle_rounded, 'Ready to study'),
    ];

    bool passedCurrent = false;

    return Column(
      children: steps.map((s) {
        final bool isDone;
        final bool isActive;

        if (status == 'uploading') {
          isDone = s.$1 == 'uploading' && steps.indexOf(s) == 0;
          isActive = s.$1 == 'processing' && steps.indexOf(s) == 1;
        } else if (status == 'processing') {
          isDone = s.$1 == 'uploading';
          isActive = !passedCurrent && s.$1 == 'processing';
          if (isActive) passedCurrent = true;
        } else {
          isDone = true;
          isActive = false;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.kSuccess
                      : isActive
                          ? AppColors.kPrimary
                          : AppColors.kSurfaceVariant,
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : s.$2,
                  size: 14,
                  color: isDone || isActive
                      ? Colors.white
                      : AppColors.kTextDisabled,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                s.$3,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDone
                      ? AppColors.kSuccess
                      : isActive
                          ? AppColors.kTextPrimary
                          : AppColors.kTextDisabled,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: AppSpacing.sm),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.kPrimary),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Chapters view (completed)
// ---------------------------------------------------------------------------

class _ChaptersView extends ConsumerStatefulWidget {
  const _ChaptersView({required this.uploadId, required this.upload});
  final String uploadId;
  final PdfUploadModel upload;

  @override
  ConsumerState<_ChaptersView> createState() => _ChaptersViewState();
}

class _ChaptersViewState extends ConsumerState<_ChaptersView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync =
        ref.watch(uploadChaptersProvider(widget.uploadId));

    return chaptersAsync.when(
      loading: () => const _CenteredLoader(),
      error: (e, _) => _ErrorView(
        message: 'Could not load chapters.',
        onRetry: () =>
            ref.invalidate(uploadChaptersProvider(widget.uploadId)),
      ),
      data: (chapters) {

        if (chapters.isEmpty) {
          return _NoChaptersView(
            uploadId: widget.uploadId,
            upload: widget.upload,
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Success banner
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
                child: _SuccessBanner(
                  upload: widget.upload,
                  chapterCount: chapters.length,
                ),
              ),
            ),

            // Chapters header
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pagePadding,
                      AppSpacing.lg, AppSpacing.pagePadding, AppSpacing.sm),
                  child: Text(
                    'Select a chapter to study',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kTextSecondary),
                  ),
                ),
              ),
            ),

            // Chapter tiles
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final chapter = chapters[i];
                  final start = 0.25 + i * 0.06;
                  final end = (start + 0.35).clamp(0.0, 1.0);
                  final anim = CurvedAnimation(
                    parent: _ctrl,
                    curve: Interval(start, end, curve: Curves.easeOutCubic),
                  );
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.1), end: Offset.zero)
                          .animate(anim),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePadding, 0,
                            AppSpacing.pagePadding, AppSpacing.sm),
                        child: _ChapterTile(
                          chapter: chapter,
                          index: i,
                          uploadId: widget.uploadId,
                        ),
                      ),
                    ),
                  );
                },
                childCount: chapters.length,
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.huge),
            ),
          ],
        );
      },
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.upload, required this.chapterCount});
  final PdfUploadModel upload;
  final int chapterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2F1A), Color(0xFF12141F)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.kSuccess.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.kSuccessContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.check_circle_rounded,
                size: 26, color: AppColors.kSuccess),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flashcards ready!',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.kSuccess)),
                const SizedBox(height: 2),
                Text(
                  '$chapterCount chapters · ${upload.generatedCardCount} cards generated',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends ConsumerStatefulWidget {
  const _ChapterTile({
    required this.chapter,
    required this.index,
    required this.uploadId,
  });
  final PdfChapterModel chapter;
  final int index;
  final String uploadId;

  @override
  ConsumerState<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends ConsumerState<_ChapterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context) {
    context.push(
      '/upload/result/${widget.uploadId}',
      extra: {
        'chapterId': widget.chapter.id,
        'chapterTitle': widget.chapter.title,
        'uploadName': '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.kPrimary,
      AppColors.kSecondary,
      AppColors.kAccent,
      AppColors.kWarning,
      AppColors.kSuccess,
    ];
    final color = colors[widget.index % colors.length];

    // Read chapter progress (null if never attempted)
    final progress = ref.watch(chapterProgressProvider.select(
      (map) => map['${widget.uploadId}:${widget.chapter.id}'],
    ));
    final hasProgress = progress != null;

    // Determine accent color based on accuracy
    Color progressColor = AppColors.kError;
    if (hasProgress) {
      if (progress.accuracyPercent >= 75) {
        progressColor = AppColors.kSuccess;
      } else if (progress.accuracyPercent >= 50) {
        progressColor = AppColors.kWarning;
      }
    }

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _navigate(context);
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: hasProgress
                  ? progressColor.withValues(alpha: 0.35)
                  : AppColors.kBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main row ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Chapter number badge (checkmark when perfect)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: hasProgress
                            ? progressColor.withValues(alpha: 0.15)
                            : color.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: hasProgress && progress.isPerfect
                          ? Icon(Icons.star_rounded,
                              size: 22, color: progressColor)
                          : hasProgress
                              ? Text(
                                  '${progress.accuracyPercent}%',
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: progressColor),
                                )
                              : Text(
                                  '${widget.index + 1}',
                                  style: AppTextStyles.headingSmall
                                      .copyWith(color: color),
                                ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Chapter info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.chapter.title,
                            style: AppTextStyles.labelLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.style_rounded,
                                  size: 12,
                                  color: AppColors.kTextSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.chapter.cardCount} cards',
                                style: AppTextStyles.caption,
                              ),
                              if (hasProgress) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.kTextDisabled,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${progress.correctCount}/${progress.totalCards} correct',
                                  style: AppTextStyles.caption.copyWith(
                                    color: progressColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Right side: progress ring or plain arrow
                    hasProgress
                        ? _MiniProgressRing(
                            accuracy: progress.accuracy,
                            color: progressColor,
                            label: '${progress.accuracyPercent}%',
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: color),
                          ),
                  ],
                ),
              ),

              // ── Accuracy progress bar (only when attempted) ───────────────
              if (hasProgress)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusLg),
                    bottomRight: Radius.circular(AppSpacing.radiusLg),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress.accuracy),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor:
                          AppColors.kSurfaceVariant,
                      valueColor:
                          AlwaysStoppedAnimation(progressColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mini donut progress ring used inside a chapter tile
// ---------------------------------------------------------------------------

class _MiniProgressRing extends StatelessWidget {
  const _MiniProgressRing({
    required this.accuracy,
    required this.color,
    required this.label,
  });
  final double accuracy;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: accuracy),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => CustomPaint(
              size: const Size(44, 44),
              painter: _MiniRingPainter(
                progress: value,
                color: color,
                trackColor: AppColors.kSurfaceVariant,
              ),
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  const _MiniRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });
  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 3.5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -1.5707963267948966; // -π/2

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      6.283185307179586 * progress, // 2π * progress
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// No chapters fallback (server didn't create chapters)
// ---------------------------------------------------------------------------

class _NoChaptersView extends StatelessWidget {
  const _NoChaptersView({required this.uploadId, required this.upload});
  final String uploadId;
  final PdfUploadModel upload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.kSurfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(Icons.style_rounded,
                size: 34, color: AppColors.kPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Flashcards ready', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${upload.generatedCardCount} flashcards were generated from your PDF.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.kTextSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push(
                '/upload/result/$uploadId',
                extra: {
                  'chapterId': '',
                  'chapterTitle': upload.topicName,
                  'uploadName': upload.topicName,
                },
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kPrimary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text('Practise All Questions',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Failed view
// ---------------------------------------------------------------------------

class _FailedView extends StatelessWidget {
  const _FailedView({required this.upload});
  final PdfUploadModel upload;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.kErrorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    size: 34, color: AppColors.kError),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Processing failed', style: AppTextStyles.headingSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                upload.error ?? 'An error occurred while processing your PDF.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: () => context.go('/upload'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.kPrimary,
                  side: const BorderSide(color: AppColors.kPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                ),
                child: Text('Try Again',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.kPrimary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.kTextDisabled),
            const SizedBox(height: AppSpacing.lg),
            Text(message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.kPrimary),
              child:
                  Text('Retry', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
