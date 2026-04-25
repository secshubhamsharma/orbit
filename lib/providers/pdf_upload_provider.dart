import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:orbitapp/models/pdf_upload_model.dart';
import 'package:orbitapp/services/api_service.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Upload state
// ---------------------------------------------------------------------------

enum UploadStep { idle, picked, uploading, processing, done, failed }

class UploadState {
  final UploadStep step;
  final String? filePath;
  final String? fileName;
  final double fileSizeMB;
  final double uploadProgress; // 0.0 – 1.0
  final String? uploadId;
  final String? error;

  const UploadState({
    this.step = UploadStep.idle,
    this.filePath,
    this.fileName,
    this.fileSizeMB = 0,
    this.uploadProgress = 0,
    this.uploadId,
    this.error,
  });

  bool get hasFile => filePath != null && fileName != null;
  bool get isBusy =>
      step == UploadStep.uploading || step == UploadStep.processing;

  UploadState copyWith({
    UploadStep? step,
    String? filePath,
    String? fileName,
    double? fileSizeMB,
    double? uploadProgress,
    String? uploadId,
    String? error,
  }) {
    return UploadState(
      step: step ?? this.step,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSizeMB: fileSizeMB ?? this.fileSizeMB,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadId: uploadId ?? this.uploadId,
      error: error ?? this.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier() : super(const UploadState());

  static const _uuid = Uuid();

  /// Called when the user picks a file from the device.
  void filePicked(String path, String name, double sizeMB) {
    state = UploadState(
      step: UploadStep.picked,
      filePath: path,
      fileName: name,
      fileSizeMB: sizeMB,
    );
  }

  void clearFile() {
    state = const UploadState();
  }

  void clearError() {
    state = state.copyWith(step: UploadStep.picked, error: null);
  }

  /// Kick off the full upload → server processing pipeline.
  Future<void> startUpload({
    required String topicName,
    required String domainId,
  }) async {
    if (!state.hasFile) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
          step: UploadStep.failed, error: 'Not signed in.');
      return;
    }

    final uploadId = _uuid.v4();
    final filePath = state.filePath!;
    final fileName = state.fileName!;

    // ── 1. Create upload document ────────────────────────────────────────────
    state = state.copyWith(
      step: UploadStep.uploading,
      uploadId: uploadId,
      uploadProgress: 0,
    );

    final uploadDoc = PdfUploadModel(
      id: uploadId,
      userId: uid,
      fileName: fileName,
      storagePath: 'uploads/$uid/$uploadId.pdf',
      fileSizeMB: state.fileSizeMB,
      status: 'uploading',
      uploadedAt: DateTime.now(),
      topicName: topicName,
      domainId: domainId,
    );

    try {
      await FirestoreService.instance.createUpload(uploadDoc);
    } catch (e) {
      state = state.copyWith(
          step: UploadStep.failed,
          error: 'Could not create upload record: $e');
      return;
    }

    // ── 2. Send PDF to server (multipart) ────────────────────────────────────
    try {
      await FirestoreService.instance
          .updateUploadStatus(uploadId, 'processing');

      state = state.copyWith(step: UploadStep.processing, uploadProgress: 1.0);

      await ApiService.instance.processPdf(
        uploadId: uploadId,
        filePath: filePath,
        topicName: topicName,
        domainId: domainId,
        onProgress: (p) {
          state = state.copyWith(uploadProgress: p);
        },
      );

      // Server updates Firestore status to 'completed' itself.
      // We just flag done locally so the UI navigates.
      state = state.copyWith(step: UploadStep.done, uploadId: uploadId);
    } on Exception catch (e) {
      // Mark failed in Firestore
      try {
        await FirestoreService.instance.updateUploadStatus(
          uploadId,
          'failed',
          error: e.toString(),
        );
      } catch (_) {}

      state = state.copyWith(
        step: UploadStep.failed,
        error: _friendlyError(e.toString()),
      );
    }
  }

  /// Reset so the screen can start a fresh upload.
  void reset() => state = const UploadState();

  String _friendlyError(String raw) {
    if (raw.contains('timeout')) {
      return 'The request timed out. The server may be busy — try again.';
    }
    if (raw.contains('connection') || raw.contains('SocketException')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (raw.contains('20MB') || raw.contains('size')) {
      return 'File is too large. Please upload a PDF under 20 MB.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final uploadNotifierProvider =
    StateNotifierProvider<UploadNotifier, UploadState>(
  (_) => UploadNotifier(),
);

/// Streams the upload document for real-time status updates on the preview screen.
final uploadStreamProvider =
    StreamProvider.family<PdfUploadModel?, String>((ref, uploadId) {
  return FirestoreService.instance.uploadStream(uploadId);
});

/// Chapters for a completed upload.
final uploadChaptersProvider =
    FutureProvider.family<List<dynamic>, String>((ref, uploadId) async {
  return FirestoreService.instance.getUploadChapters(uploadId);
});

/// Cards for a specific chapter within an upload.
final chapterCardsProvider = FutureProvider.family<List<dynamic>,
    ({String uploadId, String chapterId})>((ref, args) async {
  final cards = await FirestoreService.instance
      .getUploadChapterCards(args.uploadId, args.chapterId);

  // Fallback: if no chapter-level cards, load from top-level flashcards
  if (cards.isEmpty) {
    return FirestoreService.instance.getUploadAllCards(args.uploadId);
  }
  return cards;
});
