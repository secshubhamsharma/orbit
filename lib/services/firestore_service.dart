import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:orbitapp/models/card_schedule_model.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/flashcard_model.dart';
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
    return UserModel.fromJson(_clean(snap.data()!));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update(fields);
  }

  Stream<UserModel?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromJson(_clean(snap.data()!));
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
    return ProgressModel.fromJson(_clean(snap.data()!));
  }

  Future<void> saveTopicProgress(String uid, ProgressModel progress) async {
    await _userProgress(uid)
        .doc(progress.topicId)
        .set(progress.toJson(), SetOptions(merge: true));
  }

  Future<List<ProgressModel>> getAllProgress(String uid) async {
    final snap = await _userProgress(uid).get();
    return snap.docs
        .map((d) => ProgressModel.fromJson(_clean(d.data())))
        .toList();
  }

  Future<List<ProgressModel>> getWeakTopics(String uid,
      {int limit = 3}) async {
    final snap = await _userProgress(uid)
        .where('accuracy', isLessThan: 0.70)
        .orderBy('accuracy')
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => ProgressModel.fromJson(_clean(d.data())))
        .toList();
  }
}
