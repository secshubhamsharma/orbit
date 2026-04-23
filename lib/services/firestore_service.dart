import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:orbitapp/models/app_config_model.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/models/card_schedule_model.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/models/leaderboard_model.dart';
import 'package:orbitapp/models/pdf_upload_model.dart';
import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/models/review_session_model.dart';
import 'package:orbitapp/models/subject_model.dart';
import 'package:orbitapp/models/topic_model.dart';
import 'package:orbitapp/models/user_model.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Recursively converts Firestore [Timestamp] values to ISO-8601 strings so
  /// the freezed fromJson converters receive types they understand.
  Map<String, dynamic> _clean(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _clean(value));
      }
      return MapEntry(key, value);
    });
  }

  /// Cleans and fills in safe defaults for every non-nullable [UserModel]
  /// field. Prevents "null is not a subtype of String" when a document was
  /// created by a partial merge or when required fields are explicitly null.
  ///
  /// Strategy: spread Firestore values first so optional fields (e.g.
  /// photoUrl: null) are preserved, then force-apply null-safe values for
  /// the five required non-nullable fields so they can never be null.
  Map<String, dynamic> _sanitizeUser(Map<String, dynamic> raw) {
    final now = DateTime.now().toIso8601String();
    final cleaned = _clean(raw);
    return {
      ...cleaned,                               // all Firestore fields (may contain nulls for optional fields)
      'uid': cleaned['uid'] ?? '',              // required — never null
      'displayName': cleaned['displayName'] ?? '',
      'email': cleaned['email'] ?? '',
      'createdAt': cleaned['createdAt'] ?? now,
      'lastActiveAt': cleaned['lastActiveAt'] ?? now,
    };
  }

  // ---------------------------------------------------------------------------
  // Collection references
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _domains =>
      _db.collection('domains');

  CollectionReference<Map<String, dynamic>> _subjects(String domainId) =>
      _domains.doc(domainId).collection('subjects');

  CollectionReference<Map<String, dynamic>> _topics(
          String domainId, String subjectId) =>
      _subjects(domainId).doc(subjectId).collection('topics');

  CollectionReference<Map<String, dynamic>> _flashcards(
          String domainId, String subjectId, String topicId) =>
      _topics(domainId, subjectId).doc(topicId).collection('flashcards');

  CollectionReference<Map<String, dynamic>> _books(String domainId, String subjectId) =>
      _subjects(domainId).doc(subjectId).collection('books');

  CollectionReference<Map<String, dynamic>> _chapters(String domainId, String subjectId, String bookId) =>
      _books(domainId, subjectId).doc(bookId).collection('chapters');

  CollectionReference<Map<String, dynamic>> _chapterFlashcards(
          String domainId, String subjectId, String bookId, String chapterId) =>
      _chapters(domainId, subjectId, bookId).doc(chapterId).collection('flashcards');

  CollectionReference<Map<String, dynamic>> _schedules(String uid) =>
      _users.doc(uid).collection('schedules');

  CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _users.doc(uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> _userProgress(String uid) =>
      _db.collection('userProgress').doc(uid).collection('topics');

  // ---------------------------------------------------------------------------
  // User
  // ---------------------------------------------------------------------------

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toJson(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserModel.fromJson(_sanitizeUser(snap.data()!));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    // Always persist uid so a partial merge never produces a uid-less document.
    final data = {'uid': uid, ...fields};
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<UserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromJson(_sanitizeUser(snap.data()!));
    });
  }

  // ---------------------------------------------------------------------------
  // Domains / Subjects / Topics
  // ---------------------------------------------------------------------------

  Future<List<DomainModel>> getDomains() async {
    final snap = await _domains.orderBy('order').get();
    return snap.docs
        .map((d) => DomainModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<List<SubjectModel>> getSubjects(String domainId) async {
    final snap = await _subjects(domainId).orderBy('order').get();
    return snap.docs
        .map((d) => SubjectModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<List<TopicModel>> getTopics(
      String domainId, String subjectId) async {
    // Try ordering by `order` first; fall back to `name` if the field is absent
    // (Firestore will throw if no index exists for a missing field).
    try {
      final snap =
          await _topics(domainId, subjectId).orderBy('order').get();
      return snap.docs
          .map((d) => TopicModel.fromJson(_clean(d.data())))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' || e.code == 'invalid-argument') {
        final snap =
            await _topics(domainId, subjectId).orderBy('name').get();
        return snap.docs
            .map((d) => TopicModel.fromJson(_clean(d.data())))
            .toList();
      }
      rethrow;
    }
  }

  Future<TopicModel?> getTopic(
      String domainId, String subjectId, String topicId) async {
    final snap =
        await _topics(domainId, subjectId).doc(topicId).get();
    if (!snap.exists || snap.data() == null) return null;
    return TopicModel.fromJson(_clean(snap.data()!));
  }

  // ---------------------------------------------------------------------------
  // Flashcards
  // ---------------------------------------------------------------------------

  Future<List<FlashcardModel>> getFlashcards(
      String domainId, String subjectId, String topicId) async {
    final snap =
        await _flashcards(domainId, subjectId, topicId).orderBy('order').get();
    return snap.docs
        .map((d) => FlashcardModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<int> getFlashcardCount(
      String domainId, String subjectId, String topicId) async {
    final snap =
        await _flashcards(domainId, subjectId, topicId).count().get();
    return snap.count ?? 0;
  }

  // ---------------------------------------------------------------------------
  // Card Schedules (SRS)
  // ---------------------------------------------------------------------------

  Future<List<CardScheduleModel>> getDueCards(
      String uid, String topicId) async {
    final now = Timestamp.now();
    final snap = await _schedules(uid)
        .where('topicId', isEqualTo: topicId)
        .where('nextReviewDate', isLessThanOrEqualTo: now)
        .orderBy('nextReviewDate')
        .get();
    return snap.docs
        .map((d) => CardScheduleModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<List<CardScheduleModel>> getAllSchedules(
      String uid, String topicId) async {
    final snap = await _schedules(uid)
        .where('topicId', isEqualTo: topicId)
        .get();
    return snap.docs
        .map((d) => CardScheduleModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<void> saveSchedule(String uid, CardScheduleModel schedule) async {
    await _schedules(uid)
        .doc(schedule.cardId)
        .set(schedule.toJson(), SetOptions(merge: true));
  }

  Future<void> saveScheduleBatch(
      String uid, List<CardScheduleModel> schedules) async {
    if (schedules.isEmpty) return;

    // Firestore batch limit is 500 writes; chunk if needed.
    const chunkSize = 400;
    for (var i = 0; i < schedules.length; i += chunkSize) {
      final chunk = schedules.sublist(
          i, i + chunkSize > schedules.length ? schedules.length : i + chunkSize);
      final batch = _db.batch();
      for (final s in chunk) {
        final ref = _schedules(uid).doc(s.cardId);
        batch.set(ref, s.toJson(), SetOptions(merge: true));
      }
      await batch.commit();
    }
  }

  // ---------------------------------------------------------------------------
  // Sessions
  // ---------------------------------------------------------------------------

  Future<void> saveSession(String uid, ReviewSessionModel session) async {
    await _sessions(uid)
        .doc(session.sessionId)
        .set(session.toJson(), SetOptions(merge: true));
  }

  Future<List<ReviewSessionModel>> getSessions(String uid,
      {int limit = 20}) async {
    final snap = await _sessions(uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => ReviewSessionModel.fromJson(_clean(d.data())))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Progress
  // ---------------------------------------------------------------------------

  Future<ProgressModel?> getTopicProgress(
      String uid, String topicId) async {
    final snap = await _userProgress(uid).doc(topicId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = _clean(snap.data()!);
    data['topicId'] ??= snap.id;
    return ProgressModel.fromJson(data);
  }

  Future<void> saveTopicProgress(String uid, ProgressModel progress) async {
    await _userProgress(uid)
        .doc(progress.topicId)
        .set(progress.toJson(), SetOptions(merge: true));
  }

  Future<List<ProgressModel>> getAllProgress(String uid) async {
    final snap = await _userProgress(uid).get();
    return snap.docs.map((d) {
      final data = _clean(d.data());
      data['topicId'] ??= d.id;
      return ProgressModel.fromJson(data);
    }).toList();
  }

  Future<List<ProgressModel>> getWeakTopics(String uid,
      {int limit = 3}) async {
    final snap = await _userProgress(uid)
        .where('accuracy', isLessThan: 0.70)
        .orderBy('accuracy')
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final data = _clean(d.data());
      data['topicId'] ??= d.id;
      return ProgressModel.fromJson(data);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Books
  // ---------------------------------------------------------------------------

  Future<List<BookModel>> getBooks(String domainId, String subjectId) async {
    final snap = await _books(domainId, subjectId).orderBy('order').get();
    return snap.docs.map((d) => BookModel.fromJson(_clean(d.data()))).toList();
  }

  Future<BookModel?> getBook(String domainId, String subjectId, String bookId) async {
    final snap = await _books(domainId, subjectId).doc(bookId).get();
    if (!snap.exists || snap.data() == null) return null;
    return BookModel.fromJson(_clean(snap.data()!));
  }

  // ---------------------------------------------------------------------------
  // Chapters
  // ---------------------------------------------------------------------------

  Future<List<ChapterModel>> getChapters(String domainId, String subjectId, String bookId) async {
    final snap = await _chapters(domainId, subjectId, bookId).orderBy('chapterNumber').get();
    return snap.docs.map((d) => ChapterModel.fromJson(_clean(d.data()))).toList();
  }

  Future<ChapterModel?> getChapter(String domainId, String subjectId, String bookId, String chapterId) async {
    final snap = await _chapters(domainId, subjectId, bookId).doc(chapterId).get();
    if (!snap.exists || snap.data() == null) return null;
    return ChapterModel.fromJson(_clean(snap.data()!));
  }

  // ---------------------------------------------------------------------------
  // Search — client-side filtering via collectionGroup
  // ---------------------------------------------------------------------------

  /// Searches all books across every domain/subject.
  /// No composite index required — filtering is done in memory.
  Future<List<BookModel>> searchBooks(String query) async {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return [];
    final snap = await _db.collectionGroup('books').get();
    return snap.docs.map((d) {
      final data = _clean(d.data());
      data['id'] ??= d.id;
      return BookModel.fromJson(data);
    }).where((b) {
      return b.title.toLowerCase().contains(lower) ||
          b.authors.any((a) => a.toLowerCase().contains(lower)) ||
          b.description.toLowerCase().contains(lower) ||
          b.examTags.any((t) => t.toLowerCase().contains(lower));
    }).toList();
  }

  /// Searches all chapters across every book.
  /// Falls back gracefully when createdAt is missing from a doc.
  Future<List<ChapterModel>> searchChapters(String query) async {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return [];
    final snap = await _db.collectionGroup('chapters').get();
    final now = DateTime.now().toIso8601String();
    final results = <ChapterModel>[];
    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        data['id'] ??= d.id;
        data['createdAt'] ??= now; // guard against missing timestamp
        final chapter = ChapterModel.fromJson(data);
        final hit = chapter.name.toLowerCase().contains(lower) ||
            chapter.description.toLowerCase().contains(lower) ||
            chapter.tags.any((t) => t.toLowerCase().contains(lower));
        if (hit) results.add(chapter);
      } catch (_) {
        // Skip malformed documents rather than crashing the whole search
      }
    }
    return results;
  }

  // ---------------------------------------------------------------------------
  // Chapter flashcards
  // ---------------------------------------------------------------------------

  Future<List<FlashcardModel>> getChapterFlashcards(
      String domainId, String subjectId, String bookId, String chapterId) async {
    final snap = await _chapterFlashcards(domainId, subjectId, bookId, chapterId)
        .orderBy('order')
        .get();
    return snap.docs.map((d) => FlashcardModel.fromJson(_clean(d.data()))).toList();
  }

  Future<int> getChapterFlashcardCount(
      String domainId, String subjectId, String bookId, String chapterId) async {
    final snap = await _chapterFlashcards(domainId, subjectId, bookId, chapterId).count().get();
    return snap.count ?? 0;
  }

  Future<void> updateChapterCardCount(
      String domainId, String subjectId, String bookId, String chapterId, int count) async {
    await _chapters(domainId, subjectId, bookId).doc(chapterId).update({'totalCards': count});
  }

  // ---------------------------------------------------------------------------
  // PDF Uploads
  // ---------------------------------------------------------------------------

  Future<void> createUpload(PdfUploadModel upload) async {
    await _db
        .collection('uploads')
        .doc(upload.id)
        .set(upload.toJson(), SetOptions(merge: true));
  }

  Future<void> updateUploadStatus(
      String uploadId, String status, {String? error, int? cardCount}) async {
    final fields = <String, dynamic>{'status': status};
    if (error != null) fields['error'] = error;
    if (cardCount != null) fields['generatedCardCount'] = cardCount;
    if (status == 'completed') {
      fields['completedAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection('uploads').doc(uploadId).update(fields);
  }

  Future<PdfUploadModel?> getUpload(String uploadId) async {
    final snap = await _db.collection('uploads').doc(uploadId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = _clean(snap.data()!);
    data['id'] ??= snap.id;
    return PdfUploadModel.fromJson(data);
  }

  Stream<PdfUploadModel?> uploadStream(String uploadId) {
    return _db.collection('uploads').doc(uploadId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = _clean(snap.data()!);
      data['id'] ??= snap.id;
      return PdfUploadModel.fromJson(data);
    });
  }

  Future<List<PdfUploadModel>> getUserUploads(String userId) async {
    // Avoid a composite index requirement by not using orderBy in the query.
    // We sort the results in memory instead.
    final snap = await _db
        .collection('uploads')
        .where('userId', isEqualTo: userId)
        .get();
    final models = snap.docs.map((d) {
      // Merge the document ID so PdfUploadModel.id is never null even when
      // the 'id' field was not written inside the document body.
      final data = _clean(d.data());
      if (!data.containsKey('id') || data['id'] == null) {
        data['id'] = d.id;
      }
      return PdfUploadModel.fromJson(data);
    }).toList();

    // Sort newest-first in memory — equivalent to orderBy('uploadedAt', descending: true)
    models.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return models;
  }

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------

  Future<List<LeaderboardEntryModel>> getWeeklyLeaderboard(
      String weekId, {int limit = 50}) async {
    final snap = await _db
        .collection('leaderboard')
        .doc('weekly')
        .collection(weekId)
        .orderBy('rank')
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => LeaderboardEntryModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<LeaderboardEntryModel?> getUserLeaderboardEntry(
      String weekId, String userId) async {
    final snap = await _db
        .collection('leaderboard')
        .doc('weekly')
        .collection(weekId)
        .doc(userId)
        .get();
    if (!snap.exists || snap.data() == null) return null;
    return LeaderboardEntryModel.fromJson(_clean(snap.data()!));
  }

  // ---------------------------------------------------------------------------
  // App Config
  // ---------------------------------------------------------------------------

  Future<AppConfigModel> getAppConfig() async {
    try {
      final snap =
          await _db.collection('appConfig').doc('global').get();
      if (!snap.exists || snap.data() == null) return const AppConfigModel();
      return AppConfigModel.fromJson(_clean(snap.data()!));
    } catch (_) {
      // Return safe defaults if the doc doesn't exist yet.
      return const AppConfigModel();
    }
  }

  Stream<AppConfigModel> appConfigStream() {
    return _db.collection('appConfig').doc('global').snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return const AppConfigModel();
      return AppConfigModel.fromJson(_clean(snap.data()!));
    });
  }
}
