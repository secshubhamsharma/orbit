import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../core/errors/app_exception.dart';

/// Dio client that calls the private Orbit Node.js server.
///
/// Every request automatically attaches a fresh Firebase ID token so the
/// server can verify the caller is an authenticated Orbit user.
class ApiService {
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['SERVER_BASE_URL'] ?? '',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60), // Gemini can be slow
    ));

    // Interceptor: attach fresh Firebase ID token to every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await FirebaseAuth.instance.currentUser
              ?.getIdToken(true); // force refresh if near expiry
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // If token fetch fails, let the request go — server will reject it
        }
        handler.next(options);
      },
      onError: (err, handler) {
        print(
          '[API] ${err.requestOptions.method} ${err.requestOptions.baseUrl}'
          '${err.requestOptions.path} failed: '
          'status=${err.response?.statusCode} '
          'type=${err.type} '
          'data=${err.response?.data} '
          'message=${err.message}',
        );
        handler.next(err);
      },
    ));
  }

  static final ApiService instance = ApiService._();

  late final Dio _dio;

  // ---------------------------------------------------------------------------
  // Health check
  // ---------------------------------------------------------------------------

  Future<bool> isServerReachable() async {
    try {
      final res = await _dio.get('/health',
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
            validateStatus: (_) => true,
          ));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Flashcard generation
  // ---------------------------------------------------------------------------

  /// Asks the server to generate flashcards for [topicId].
  ///
  /// Returns the number of cards generated. Throws [ApiException] on failure.
  Future<int> generateFlashcards({
    required String topicId,
    required String topicName,
    required String domainId,
    required String subjectId,
    List<String> examTags = const [],
    String difficulty = 'mixed',
  }) async {
    try {
      final res = await _dio.post('/flashcards/generate', data: {
        'topicId': topicId,
        'topicName': topicName,
        'domainId': domainId,
        'subjectId': subjectId,
        'examTags': examTags,
        'difficulty': difficulty,
      });

      final body = res.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
            body['message'] as String? ?? 'Flashcard generation failed');
      }
      return (body['cardCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // PDF processing
  // ---------------------------------------------------------------------------

  /// Sends a PDF to the server for OCR + AI card generation.
  ///
  /// [onProgress] receives upload progress from 0.0 to 1.0.
  Future<int> processPdf({
    required String uploadId,
    required String filePath,
    required String topicName,
    required String domainId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'uploadId': uploadId,
        'topicName': topicName,
        'domainId': domainId,
        'pdf': await MultipartFile.fromFile(filePath,
            filename: filePath.split('/').last),
      });

      final res = await _dio.post('/pdf/process',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
            receiveTimeout: const Duration(minutes: 3),
          ),
          onSendProgress: (sent, total) {
            if (total > 0 && onProgress != null) {
              onProgress(sent / total);
            }
          });

      final body = res.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
            body['message'] as String? ?? 'PDF processing failed');
      }
      return (body['cardCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Leaderboard update (trigger server recalculation)
  // ---------------------------------------------------------------------------

  Future<void> updateLeaderboard() async {
    try {
      await _dio.post('/leaderboard/update');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  ApiException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
          'Request timed out. Please check your connection and try again.',
          code: 'timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      final message = e.message ?? '';
      if (message.contains('Cleartext HTTP traffic')) {
        return const ApiException(
          'The app cannot reach the server over HTTP on this device.',
          code: 'cleartext_blocked',
        );
      }
      return ApiException(
        message.isNotEmpty
            ? 'Cannot reach the server: $message'
            : 'Cannot reach the server. Please check your connection.',
        code: 'no_connection',
      );
    }

    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final serverMessage = responseData is Map
        ? responseData['message'] as String?
        : null;
    final dioMessage = e.message?.trim();

    return switch (statusCode) {
      401 => const ApiException('Session expired. Please sign in again.',
          code: 'unauthorized'),
      403 =>
        const ApiException('Access denied.', code: 'forbidden'),
      429 => const ApiException(
          'Too many requests. Please wait a moment and try again.',
          code: 'rate_limited'),
      500 => ApiException(
          // Use the human-friendly message from the server, not the raw
          // technical details (which leak Groq error text to _friendlyError).
          serverMessage ?? 'Server error. Please try again later.',
          code: 'server_error'),
      _ => ApiException(
          serverMessage ??
              dioMessage ??
              'Something went wrong. Please try again.',
          code: 'unknown'),
    };
  }
}
