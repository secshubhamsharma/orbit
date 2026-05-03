import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:orbitapp/models/app_config_model.dart';
import 'package:orbitapp/models/book_model.dart';
import 'package:orbitapp/models/chapter_model.dart';
import 'package:orbitapp/models/card_schedule_model.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/flashcard_model.dart';
import 'package:orbitapp/models/leaderboard_model.dart';
import 'package:orbitapp/models/pdf_chapter_model.dart';
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
    final results = <ReviewSessionModel>[];
    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        data['sessionId'] ??= d.id;
        data['topicId'] ??= '';
        results.add(ReviewSessionModel.fromJson(data));
      } catch (_) {}
    }
    return results;
  }

  /// Real-time stream of recent sessions — auto-updates after each session.
  Stream<List<ReviewSessionModel>> sessionsStream(String uid, {int limit = 10}) {
    return _sessions(uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      final results = <ReviewSessionModel>[];
      for (final d in snap.docs) {
        try {
          final data = _clean(d.data());
          data['sessionId'] ??= d.id;
          data['topicId'] ??= '';
          results.add(ReviewSessionModel.fromJson(data));
        } catch (_) {}
      }
      return results;
    });
  }

  /// Returns cards-reviewed counts indexed by ISO weekday (0 = Mon … 6 = Sun)
  /// for the **current calendar week**. Matches the Mon-Sun bar chart labels.
  Future<List<int>> getWeeklyActivity(String uid, {int days = 7}) async {
    final now = DateTime.now();
    // Monday of the current ISO week
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final snap = await _sessions(uid).get();
    final counts = List<int>.filled(days, 0);

    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        final raw = data['startedAt'];
        DateTime? dt;
        if (raw is String) dt = DateTime.tryParse(raw);
        if (dt == null) continue;
        final dayIndex = DateTime(dt.year, dt.month, dt.day)
            .difference(monday)
            .inDays;
        if (dayIndex >= 0 && dayIndex < days) {
          counts[dayIndex] +=
              (data['cardsReviewed'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {}
    }
    return counts;
  }

  /// Returns a map of `"yyyy-MM-dd"` → cards-reviewed for the last [days] days.
  /// Used to render the 5-week activity calendar on the progress screen.
  Future<Map<String, int>> getActivityCalendar(
      String uid, {int days = 35}) async {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final snap = await _sessions(uid).get();
    final result = <String, int>{};

    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        final raw = data['startedAt'];
        DateTime? dt;
        if (raw is String) dt = DateTime.tryParse(raw);
        if (dt == null) continue;
        final day = DateTime(dt.year, dt.month, dt.day);
        if (day.isBefore(cutoff)) continue;
        final key =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        result[key] =
            (result[key] ?? 0) + ((data['cardsReviewed'] as num?)?.toInt() ?? 0);
      } catch (_) {}
    }
    return result;
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

  /// Real-time stream for a single topic's progress doc.
  /// Emits `null` when the user has not yet studied this topic.
  Stream<ProgressModel?> topicProgressStream(String uid, String topicId) {
    return _userProgress(uid).doc(topicId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = _clean(snap.data()!);
      data['topicId'] ??= snap.id;
      return ProgressModel.fromJson(data);
    });
  }

  /// Real-time stream of sessions for a specific topic (client-side filter).
  /// No composite index required.
  Stream<List<ReviewSessionModel>> topicSessionsStream(
      String uid, String topicId) {
    return _sessions(uid)
        .orderBy('startedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
      final results = <ReviewSessionModel>[];
      for (final d in snap.docs) {
        try {
          final data = _clean(d.data());
          data['sessionId'] ??= d.id;
          data['topicId'] ??= '';
          final session = ReviewSessionModel.fromJson(data);
          if (session.topicId == topicId) results.add(session);
        } catch (_) {}
      }
      return results;
    });
  }

  Future<void> saveTopicProgress(String uid, ProgressModel progress) async {
    await _userProgress(uid)
        .doc(progress.topicId)
        .set(progress.toJson(), SetOptions(merge: true));
  }

  /// Upserts per-topic progress after a review session completes.
  ///
  /// Runs inside a Firestore transaction so concurrent sessions can't corrupt
  /// the running totals.
  Future<void> updateTopicProgress({
    required String uid,
    required String topicId,
    required String topicName,
    required String domainId,
    required int cardsReviewed,
    required int correctCount,
    required int durationSeconds,
    List<CardScheduleModel> updatedSchedules = const [],
  }) async {
    final progressRef = _userProgress(uid).doc(topicId);
    final userRef     = _users.doc(uid);
    final now         = DateTime.now();

    await _db.runTransaction((tx) async {
      // Read both docs before any writes (Firestore transaction requirement)
      final progressSnap = await tx.get(progressRef);
      final userSnap     = await tx.get(userRef);

      int prevSessions  = 0;
      int prevCards     = 0;
      int prevCorrect   = 0;
      int prevIncorrect = 0;
      int prevMinutes   = 0;
      double prevMastery = 0.0;
      DateTime? firstStudied;

      if (progressSnap.exists && progressSnap.data() != null) {
        final d = _clean(progressSnap.data()!);
        prevSessions      = (d['totalSessions']      as num?)?.toInt() ?? 0;
        prevCards         = (d['totalCardsReviewed'] as num?)?.toInt() ?? 0;
        prevCorrect       = (d['totalCorrect']       as num?)?.toInt() ?? 0;
        prevIncorrect     = (d['totalIncorrect']     as num?)?.toInt() ?? 0;
        prevMinutes       = (d['totalStudyMinutes']  as num?)?.toInt() ?? 0;
        prevMastery       = (d['masteryPercent']     as num?)?.toDouble() ?? 0.0;
        final fs = d['firstStudied'];
        if (fs is String) firstStudied = DateTime.tryParse(fs);
      }

      // A topic is "new" if the user has never completed a session on it before.
      final isNewTopic = prevSessions == 0;

      final newCards     = prevCards + cardsReviewed;
      final newCorrect   = prevCorrect + correctCount;
      final newIncorrect = prevIncorrect + (cardsReviewed - correctCount);
      final newAccuracy  = newCards > 0 ? newCorrect / newCards : 0.0;

      // Mastery: cards whose SRS interval has reached ≥ 7 days.
      // If no SM-2 schedules are provided (e.g. PDF quiz), derive from accuracy
      // using a convergence formula so mastery improves with repeated sessions.
      double masteryPct;
      int cardsDue      = 0;
      int cardsMastered = 0;
      String masteryLevel;

      if (updatedSchedules.isNotEmpty) {
        // SM-2 path (library topics)
        final nowTs = DateTime.now();
        cardsDue      = updatedSchedules.where((s) => !s.nextReviewDate.isAfter(nowTs)).length;
        cardsMastered = updatedSchedules.where((s) => s.interval >= 21).length;
        final masteredCount = updatedSchedules.where((s) => s.interval >= 7).length;
        masteryPct = (masteredCount / updatedSchedules.length) * 100;
      } else {
        // No SM-2 data (PDF quiz path): pull mastery toward session accuracy each time.
        final sessionAcc = cardsReviewed > 0 ? correctCount / cardsReviewed : 0.0;
        if (prevCards == 0) {
          // First session — seed mastery from session accuracy, cap at 70
          // so a single perfect attempt cannot instantly show "mastered".
          masteryPct = (sessionAcc * 70).clamp(0.0, 70.0);
        } else {
          // Convergence: each session moves mastery 40% toward session performance.
          masteryPct = prevMastery + (sessionAcc * 100 - prevMastery) * 0.4;
          masteryPct = masteryPct.clamp(0.0, 95.0);
        }
      }

      masteryLevel = masteryPct >= 75
          ? 'mastered'
          : masteryPct >= 40
              ? 'reviewing'
              : 'learning';

      // Session-level accuracy — used by the "Needs attention" query so that
      // a single good retry immediately removes a topic from the list, rather
      // than waiting for the cumulative average to cross the threshold.
      final sessionAcc = cardsReviewed > 0 ? correctCount / cardsReviewed : 0.0;

      // ── Write topic progress ──────────────────────────────────────────────
      tx.set(progressRef, {
        'topicId':              topicId,
        'topicName':            topicName,
        'domainId':             domainId,
        'firstStudied':         firstStudied?.toIso8601String() ?? now.toIso8601String(),
        'lastStudied':          now.toIso8601String(),
        'totalSessions':        prevSessions + 1,
        'totalCardsReviewed':   newCards,
        'totalCorrect':         newCorrect,
        'totalIncorrect':       newIncorrect,
        'accuracy':             newAccuracy,
        'lastSessionAccuracy':  sessionAcc,   // ← most-recent session; drives weak-topic filter
        'masteryPercent':       masteryPct,
        'masteryLevel':         masteryLevel,
        'totalStudyMinutes':    prevMinutes + (durationSeconds / 60).round(),
        // Only write SRS-derived fields when schedules are available;
        // merge:true preserves previously stored values for PDF-quiz topics.
        if (updatedSchedules.isNotEmpty) 'cardsDue':      cardsDue,
        if (updatedSchedules.isNotEmpty) 'cardsMastered': cardsMastered,
      }, SetOptions(merge: true));

      // ── Increment topicsStarted on user doc for brand-new topics ─────────
      if (isNewTopic) {
        final userRaw = userSnap.exists && userSnap.data() != null
            ? _clean(userSnap.data()!)
            : <String, dynamic>{};
        final prevTopicsStarted = (userRaw['topicsStarted'] as num?)?.toInt() ?? 0;
        tx.set(userRef, {
          'topicsStarted': prevTopicsStarted + 1,
        }, SetOptions(merge: true));
      }
    });
  }

  /// Updates the global user-level stats and streak after a review session.
  ///
  /// Streak rules:
  ///   - First session ever           → streak = 1
  ///   - Last session was yesterday   → streak += 1
  ///   - Last session was today       → streak unchanged
  ///   - Last session was ≥ 2 days ago → streak = 1 (reset)
  Future<void> updateUserStats({
    required String uid,
    required int cardsReviewed,
    required double sessionAccuracy,
    required int durationSeconds,
    String? displayName,  // used to keep leaderboard entry in sync
    String? photoUrl,
  }) async {
    final userRef        = _users.doc(uid);
    final leaderboardRef = _db.collection('leaderboard').doc(uid);
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final raw  = snap.exists && snap.data() != null
          ? _clean(snap.data()!)
          : <String, dynamic>{};

      // ── Streak ─────────────────────────────────────────────────────────────
      DateTime? lastDay;
      final lastStudiedRaw = raw['lastStudiedDate'];
      if (lastStudiedRaw is String) {
        final dt = DateTime.tryParse(lastStudiedRaw);
        if (dt != null) lastDay = DateTime(dt.year, dt.month, dt.day);
      }

      int currentStreak = (raw['currentStreak'] as num?)?.toInt() ?? 0;
      int longestStreak = (raw['longestStreak'] as num?)?.toInt() ?? 0;

      if (lastDay == null) {
        currentStreak = 1; // very first session
      } else {
        final diff = today.difference(lastDay).inDays;
        if (diff == 0) {
          // already studied today — keep streak unchanged
        } else if (diff == 1) {
          currentStreak += 1; // consecutive day
        } else {
          currentStreak = 1; // streak broken
        }
      }
      if (currentStreak > longestStreak) longestStreak = currentStreak;

      // ── Running weighted accuracy ──────────────────────────────────────────
      final prevTotal    = (raw['totalCardsReviewed']  as num?)?.toInt()    ?? 0;
      final prevAccuracy = (raw['overallAccuracy']     as num?)?.toDouble() ?? 0.0;
      final prevMinutes  = (raw['totalStudyMinutes']   as num?)?.toInt()    ?? 0;
      final prevWeekly   = (raw['weeklyCardsReviewed'] as num?)?.toInt()    ?? 0;

      final newTotal    = prevTotal + cardsReviewed;
      final newAccuracy = newTotal > 0
          ? (prevAccuracy * prevTotal + sessionAccuracy * cardsReviewed) / newTotal
          : 0.0;

      // ── Write user document ────────────────────────────────────────────────
      tx.set(userRef, {
        'totalCardsReviewed':  newTotal,
        'weeklyCardsReviewed': prevWeekly + cardsReviewed,
        'overallAccuracy':     newAccuracy,
        'totalStudyMinutes':   prevMinutes + (durationSeconds / 60).round(),
        'currentStreak':       currentStreak,
        'longestStreak':       longestStreak,
        'lastStudiedDate':     today.toIso8601String(),
        'lastActiveAt':        now.toIso8601String(),
      }, SetOptions(merge: true));

      // ── Atomically mirror key stats to leaderboard/{uid} ──────────────────
      // Score = totalCardsReviewed × overallAccuracy (rewards volume + quality).
      if (displayName != null && displayName.isNotEmpty) {
        tx.set(leaderboardRef, {
          'userId':              uid,
          'displayName':         displayName,
          if (photoUrl != null) 'photoUrl': photoUrl,
          'totalCardsReviewed':  newTotal,
          'overallAccuracy':     newAccuracy,
          'currentStreak':       currentStreak,
          'score':               newTotal * newAccuracy,
          'updatedAt':           now.toIso8601String(),
        }, SetOptions(merge: true));
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Leaderboard helpers (new flat collection)
  // ---------------------------------------------------------------------------

  /// Real-time stream of top [limit] leaderboard entries ordered by score.
  /// Rank is assigned client-side (1 = highest score).
  Stream<List<LeaderboardEntryModel>> leaderboardStream({int limit = 50}) {
    return _db
        .collection('leaderboard')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      final entries = <LeaderboardEntryModel>[];
      for (int i = 0; i < snap.docs.length; i++) {
        try {
          final data = _clean(snap.docs[i].data());
          data['userId'] ??= snap.docs[i].id;
          data['rank']   = i + 1;
          entries.add(LeaderboardEntryModel.fromJson(data));
        } catch (_) {}
      }
      return entries;
    });
  }

  /// One-time fetch of a single user's leaderboard entry.
  Future<LeaderboardEntryModel?> getLeaderboardEntry(String userId) async {
    final snap =
        await _db.collection('leaderboard').doc(userId).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = _clean(snap.data()!);
    data['userId'] ??= userId;
    return LeaderboardEntryModel.fromJson(data);
  }

  Future<List<ProgressModel>> getAllProgress(String uid) async {
    final snap = await _userProgress(uid).get();
    return snap.docs.map((d) {
      final data = _clean(d.data());
      data['topicId'] ??= d.id;
      return ProgressModel.fromJson(data);
    }).toList();
  }

  /// Real-time stream of all topic progress docs — auto-updates after each session.
  Stream<List<ProgressModel>> allProgressStream(String uid) {
    return _userProgress(uid).snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = _clean(d.data());
        data['topicId'] ??= d.id;
        return ProgressModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<ProgressModel>> getWeakTopics(String uid,
      {int limit = 3}) async {
    // Query by lastSessionAccuracy so a single good retry immediately removes
    // the topic from "Needs attention". Falls back to cumulative accuracy for
    // documents written before this field was introduced.
    final snap = await _userProgress(uid)
        .where('lastSessionAccuracy', isLessThan: 0.70)
        .orderBy('lastSessionAccuracy')
        .limit(limit)
        .get();
    return snap.docs.map((d) {
      final data = _clean(d.data());
      data['topicId'] ??= d.id;
      return ProgressModel.fromJson(data);
    }).toList();
  }

  /// Real-time stream of weak topics — auto-updates after each session.
  /// Uses lastSessionAccuracy so an immediate good retry clears the topic.
  Stream<List<ProgressModel>> weakTopicsStream(String uid, {int limit = 3}) {
    return _userProgress(uid)
        .where('lastSessionAccuracy', isLessThan: 0.70)
        .orderBy('lastSessionAccuracy')
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = _clean(d.data());
              data['topicId'] ??= d.id;
              return ProgressModel.fromJson(data);
            }).toList());
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
  // PDF Chapters (extracted by the AI server from uploaded PDFs)
  // Stored at: uploads/{uploadId}/chapters/{chapterId}
  //            uploads/{uploadId}/chapters/{chapterId}/cards/{cardId}
  // ---------------------------------------------------------------------------

  Future<List<PdfChapterModel>> getUploadChapters(String uploadId) async {
    final snap = await _db
        .collection('uploads')
        .doc(uploadId)
        .collection('chapters')
        .get();

    final chapters = snap.docs.map((d) {
      final data = _clean(d.data());
      return PdfChapterModel.fromJson(d.id, data);
    }).toList();

    // Sort by order field ascending
    chapters.sort((a, b) => a.order.compareTo(b.order));
    return chapters;
  }

  Future<List<FlashcardModel>> getUploadChapterCards(
      String uploadId, String chapterId) async {
    final snap = await _db
        .collection('uploads')
        .doc(uploadId)
        .collection('chapters')
        .doc(chapterId)
        .collection('cards')
        .get();

    final cards = <FlashcardModel>[];
    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        data['id'] ??= d.id;
        data['topicId'] ??= chapterId;
        data['createdAt'] ??= DateTime.now().toIso8601String();
        cards.add(FlashcardModel.fromJson(data));
      } catch (_) {
        // Skip malformed cards
      }
    }
    return cards;
  }

  /// Fallback: load all cards from uploads/{uploadId}/flashcards/ when the
  /// server has not created per-chapter subcollections.
  Future<List<FlashcardModel>> getUploadAllCards(String uploadId) async {
    final snap = await _db
        .collection('uploads')
        .doc(uploadId)
        .collection('flashcards')
        .get();

    final cards = <FlashcardModel>[];
    for (final d in snap.docs) {
      try {
        final data = _clean(d.data());
        data['id'] ??= d.id;
        data['topicId'] ??= uploadId;
        data['createdAt'] ??= DateTime.now().toIso8601String();
        cards.add(FlashcardModel.fromJson(data));
      } catch (_) {
        // Skip malformed cards
      }
    }
    return cards;
  }

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------

  // getWeeklyLeaderboard and getUserLeaderboardEntry removed —
  // replaced by leaderboardStream and getLeaderboardEntry (flat collection).

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
