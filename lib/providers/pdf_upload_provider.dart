import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:orbitapp/core/errors/app_exception.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/models/pdf_chapter_model.dart';
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

  /// Creates the Firestore upload doc, then fires the server processing call
  /// in the background. Returns the uploadId immediately so the UI can navigate
  /// to the preview screen without waiting for the server.
  ///
  /// Returns null if preconditions fail (no file, not signed in, Firestore error).
  Future<String?> startUpload({
    required String topicName,
    required String domainId,
  }) async {
    if (!state.hasFile) return null;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
          step: UploadStep.failed, error: 'Not signed in.');
      return null;
    }

    final uploadId = _uuid.v4();
    final filePath = state.filePath!;
    final fileName = state.fileName!;
    final sizeMB = state.fileSizeMB;

    // ── 1. Create Firestore upload document (status = 'uploading') ───────────
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
      fileSizeMB: sizeMB,
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
          error: 'Could not create upload record. Check your connection.');
      return null;
    }

    // ── 2. Mark as processing and return uploadId to trigger navigation ───────
    // The server call runs in the background. The preview screen listens to
    // the Firestore stream and will update automatically when the server
    // finishes (status → 'completed' or 'failed').
    try {
      await FirestoreService.instance.updateUploadStatus(uploadId, 'processing');
    } catch (_) {
      // Non-fatal — Firestore offline persistence will sync later
    }

    state = state.copyWith(step: UploadStep.done, uploadId: uploadId);

    // ── 3. Fire server call without awaiting — background processing ──────────
    _sendToServer(
      uploadId: uploadId,
      filePath: filePath,
      topicName: topicName,
      domainId: domainId,
    );

    return uploadId;
  }

  /// Background method — sends the PDF to the AI server.
  /// Updates Firestore on success or failure.
  Future<void> _sendToServer({
    required String uploadId,
    required String filePath,
    required String topicName,
    required String domainId,
  }) async {
    try {
      await ApiService.instance.processPdf(
        uploadId: uploadId,
        filePath: filePath,
        topicName: topicName,
        domainId: domainId,
      );
      // Server is responsible for writing status='completed' and creating
      // the chapters subcollection. If it doesn't (old server version),
      // mark completed here as a fallback so the preview screen isn't stuck.
    } catch (e) {
      final rawMessage = switch (e) {
        AppException() => e.message,
        _ => e.toString(),
      };
      final message = _friendlyError(rawMessage);
      // Keep a visible trace in debug logs so upload failures are diagnosable
      // without attaching a debugger.
      print(
        '[PDF_UPLOAD] uploadId=$uploadId failed: '
        'type=${e.runtimeType} raw="$rawMessage" mapped="$message"',
      );

      try {
        await FirestoreService.instance.updateUploadStatus(
          uploadId,
          'failed',
          error: message,
        );
      } catch (_) {}
    }
  }

  /// Reset so the screen can start a fresh upload.
  void reset() => state = const UploadState();

  String _friendlyError(String raw) {
    final message = raw.trim();
    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    // ── Server-generated clean messages (pass through as-is) ──────────────────
    // These come from our updated server and are already user-friendly.
    if (raw.contains('AI service account is restricted')) {
      return 'AI service is unavailable. Please contact support.';
    }
    if (raw.contains('AI is overloaded') || raw.contains('try again in a few minutes')) {
      return 'The AI is busy right now. Please wait a moment and try again.';
    }
    if (raw.contains('AI could not process this PDF')) {
      return 'AI could not process this PDF. Please try again.';
    }
    if (raw.contains('File is too large') || raw.contains('under 20 MB')) {
      return 'File is too large. Please upload a PDF under 20 MB.';
    }
    if (raw.contains('No study content') || raw.contains('readable text')) {
      return raw; // already user-friendly
    }

    // ── Fallback patterns for unexpected raw messages ─────────────────────────
    if (raw.contains('rate') ||
        raw.contains('429') ||
        raw.contains('TPM') ||
        raw.contains('Too Many Requests')) {
      return 'The AI is processing too many requests. Please wait and try again.';
    }
    if (raw.contains('restricted') || raw.contains('forbidden') || raw.contains('403')) {
      return 'AI service is unavailable. Please contact support.';
    }
    if (raw.contains('timeout')) {
      return 'The request timed out. The server may be busy — try again.';
    }
    if (raw.contains('connection') || raw.contains('SocketException')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (raw.contains('Cleartext HTTP traffic')) {
      return 'The app could not reach the server over HTTP on this device.';
    }
    if (raw.contains('LIMIT_FILE_SIZE') || raw.contains('413')) {
      return 'File is too large. Please upload a PDF under 20 MB.';
    }

    return message;
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
    FutureProvider.family<List<PdfChapterModel>, String>((ref, uploadId) async {
  return FirestoreService.instance.getUploadChapters(uploadId);
});

/// Cards for a specific chapter within an upload.
final chapterCardsProvider = FutureProvider.family<List<FlashcardModel>,
    ({String uploadId, String chapterId})>((ref, args) async {
  final cards = await FirestoreService.instance
      .getUploadChapterCards(args.uploadId, args.chapterId);

  // Fallback: if no chapter-level cards, load from top-level flashcards
  if (cards.isEmpty) {
    return FirestoreService.instance.getUploadAllCards(args.uploadId);
  }
  return cards;
});
