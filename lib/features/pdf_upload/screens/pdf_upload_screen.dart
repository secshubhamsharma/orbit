import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/providers/pdf_upload_provider.dart';

// ---------------------------------------------------------------------------
// Domain options
// ---------------------------------------------------------------------------

const _domains = [
  ('school', 'School'),
  ('competitive_exams', 'Competitive Exams'),
  ('it_certifications', 'IT Certifications'),
  ('finance_certifications', 'Finance & Certifications'),
  ('language_aptitude', 'Language & Aptitude'),
  ('other', 'Other'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PdfUploadScreen extends ConsumerStatefulWidget {
  const PdfUploadScreen({super.key});

  @override
  ConsumerState<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends ConsumerState<PdfUploadScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _selectedDomain = _domains.first.$1;

  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── File picking ─────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final sizeMB = (file.size / (1024 * 1024));
    if (sizeMB > 20) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File is too large (${sizeMB.toStringAsFixed(1)} MB). Max allowed is 20 MB.',
                style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.kError,
          ),
        );
      }
      return;
    }

    ref.read(uploadNotifierProvider.notifier).filePicked(
          file.path!,
          file.name,
          sizeMB,
        );
  }

  // ── Upload ────────────────────────────────────────────────────────────────

  Future<void> _startUpload(UploadState state) async {
    if (!_formKey.currentState!.validate()) return;
    if (!state.hasFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a PDF file first.',
              style: AppTextStyles.bodyMedium),
          backgroundColor: AppColors.kError,
        ),
      );
      return;
    }

    await ref.read(uploadNotifierProvider.notifier).startUpload(
          topicName: _nameCtrl.text.trim(),
          domainId: _selectedDomain,
        );

    final newState = ref.read(uploadNotifierProvider);
    if (newState.step == UploadStep.done && mounted) {
      context.push('/upload/preview/${newState.uploadId}');
      ref.read(uploadNotifierProvider.notifier).reset();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);

    // Show error snackbar
    ref.listen(uploadNotifierProvider, (prev, next) {
      if (next.step == UploadStep.failed && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(next.error!, style: AppTextStyles.bodyMedium),
            backgroundColor: AppColors.kError,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(uploadNotifierProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: uploadState.isBusy
                  ? _buildProcessingView(uploadState)
                  : _buildForm(uploadState),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
          Text('Upload PDF', style: AppTextStyles.headingSmall),
        ],
      ),
    );
  }

  // ── Main form ─────────────────────────────────────────────────────────────

  Widget _buildForm(UploadState uploadState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Hero heading
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upload your PDF',
                      style: AppTextStyles.displayMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Our AI will read it, extract chapters, and generate flashcards for each one.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.kTextSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // File picker zone
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
              ),
              child: _FileDropZone(
                state: uploadState,
                onPick: _pickFile,
                onClear: () =>
                    ref.read(uploadNotifierProvider.notifier).clearFile(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Book/topic name
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Book / Topic Name',
                      style: AppTextStyles.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _nameCtrl,
                    style: AppTextStyles.bodyMedium,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Organic Chemistry Part 1',
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.kTextDisabled),
                      filled: true,
                      fillColor: AppColors.kSurface,
                      counterStyle: AppTextStyles.caption,
                      prefixIcon: const Icon(Icons.book_outlined,
                          size: 18, color: AppColors.kTextSecondary),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide:
                            const BorderSide(color: AppColors.kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide:
                            const BorderSide(color: AppColors.kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide:
                            const BorderSide(color: AppColors.kPrimary, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide:
                            const BorderSide(color: AppColors.kError),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        borderSide:
                            const BorderSide(color: AppColors.kError, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a name for this material.';
                      }
                      if (v.trim().length < 3) {
                        return 'Name must be at least 3 characters.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Domain picker
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category', style: AppTextStyles.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.kBorder),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDomain,
                        isExpanded: true,
                        dropdownColor: AppColors.kSurfaceVariant,
                        style: AppTextStyles.bodyMedium,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.kTextSecondary),
                        items: _domains
                            .map((d) => DropdownMenuItem(
                                  value: d.$1,
                                  child: Text(d.$2,
                                      style: AppTextStyles.bodyMedium),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedDomain = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Info chips
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
              ),
              child: _InfoRow(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Upload button
            _FadeSlide(
              animation: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: uploadState.isBusy
                      ? null
                      : () => _startUpload(uploadState),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                    disabledBackgroundColor:
                        AppColors.kPrimary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: Colors.white),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Generate Flashcards',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ── Processing view ───────────────────────────────────────────────────────

  Widget _buildProcessingView(UploadState uploadState) {
    final isUploading = uploadState.step == UploadStep.uploading;
    final progress = uploadState.uploadProgress;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing icon
          _PulsingIcon(isUploading: isUploading),

          const SizedBox(height: AppSpacing.xl),

          Text(
            isUploading ? 'Uploading PDF...' : 'Generating flashcards...',
            style: AppTextStyles.headingMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isUploading
                ? 'Sending your PDF to the AI server.'
                : 'The AI is reading your PDF and creating chapter-wise flashcards. This may take a minute.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.kTextSecondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Progress bar
          if (isUploading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: AppColors.kSurfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.kPrimary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.kPrimaryLight),
            ),
          ] else ...[
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.kPrimary,
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Steps
          _ProcessingSteps(step: uploadState.step),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File Drop Zone
// ---------------------------------------------------------------------------

class _FileDropZone extends StatelessWidget {
  const _FileDropZone({
    required this.state,
    required this.onPick,
    required this.onClear,
  });

  final UploadState state;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (state.hasFile) {
      return _FilePicked(state: state, onClear: onClear);
    }
    return _DropZoneEmpty(onPick: onPick);
  }
}

class _DropZoneEmpty extends StatelessWidget {
  const _DropZoneEmpty({required this.onPick});
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.kPrimaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: const Icon(Icons.upload_file_rounded,
                  size: 30, color: AppColors.kPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Tap to select a PDF',
                style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text('Max file size: 20 MB',
                style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _FilePicked extends StatelessWidget {
  const _FilePicked({required this.state, required this.onClear});
  final UploadState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
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
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded,
                size: 24, color: AppColors.kError),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.fileName!,
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.fileSizeMB.toStringAsFixed(1)} MB',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kSuccess),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.kTextSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row
// ---------------------------------------------------------------------------

class _InfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InfoChip(Icons.auto_awesome_rounded, 'AI-powered'),
        const SizedBox(width: AppSpacing.sm),
        _InfoChip(Icons.layers_rounded, 'Chapter-wise'),
        const SizedBox(width: AppSpacing.sm),
        _InfoChip(Icons.style_rounded, 'Instant cards'),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.kPrimaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.kPrimaryLight),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.kPrimaryLight)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Processing steps widget
// ---------------------------------------------------------------------------

class _ProcessingSteps extends StatelessWidget {
  const _ProcessingSteps({required this.step});
  final UploadStep step;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (UploadStep.uploading, Icons.upload_rounded, 'Sending PDF to server'),
      (UploadStep.processing, Icons.auto_awesome_rounded, 'AI reading chapters'),
      (UploadStep.done, Icons.style_rounded, 'Generating flashcards'),
    ];

    return Column(
      children: steps.map((s) {
        final isDone = step.index > s.$1.index;
        final isActive = step == s.$1;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
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
                    strokeWidth: 2,
                    color: AppColors.kPrimary,
                  ),
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
// Pulsing icon animation
// ---------------------------------------------------------------------------

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.isUploading});
  final bool isUploading;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
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
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isUploading
                ? [AppColors.kPrimary, AppColors.kPrimaryDark]
                : AppColors.kGradientPrimary,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimary.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          widget.isUploading
              ? Icons.cloud_upload_rounded
              : Icons.auto_awesome_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable fade+slide entrance
// ---------------------------------------------------------------------------

class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
