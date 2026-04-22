import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'badge_model.freezed.dart';
part 'badge_model.g.dart';

class _NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const _NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  @override
  dynamic toJson(DateTime? d) => d?.toIso8601String();
}

@freezed
class BadgeModel with _$BadgeModel {
  const BadgeModel._();

  const factory BadgeModel({
    required String id,
    required String name,
    required String description,
    @Default('🏆') String iconEmoji,
    required String condition,
    @_NullableTimestampConverter() DateTime? earnedAt,
    @Default(0) int progress,
    @Default(0) int progressTarget,
  }) = _BadgeModel;

  factory BadgeModel.fromJson(Map<String, dynamic> json) =>
      _$BadgeModelFromJson(json);

  bool get isEarned => earnedAt != null;
  bool get hasProgress => progressTarget > 0;

  static List<BadgeModel> get allBadges => [
        const BadgeModel(
          id: 'first_review',
          name: 'First Launch',
          description: 'Complete your first review session',
          iconEmoji: '🚀',
          condition: 'Complete first review session',
        ),
        const BadgeModel(
          id: 'streak_7',
          name: 'Week Warrior',
          description: '7-day study streak',
          iconEmoji: '🔥',
          condition: '7-day streak',
          progressTarget: 7,
        ),
        const BadgeModel(
          id: 'streak_30',
          name: 'Month Master',
          description: '30-day study streak',
          iconEmoji: '🔥',
          condition: '30-day streak',
          progressTarget: 30,
        ),
        const BadgeModel(
          id: 'perfect_session',
          name: 'Perfect',
          description: '100% accuracy in a session',
          iconEmoji: '💯',
          condition: '100% accuracy in any session',
        ),
        const BadgeModel(
          id: 'first_upload',
          name: 'Uploader',
          description: 'Upload your first PDF',
          iconEmoji: '📤',
          condition: 'Upload first PDF',
        ),
        const BadgeModel(
          id: 'topic_master',
          name: 'Topic Master',
          description: 'Reach 85%+ mastery on any topic',
          iconEmoji: '🎯',
          condition: 'Mastery ≥ 85% on any topic',
        ),
        const BadgeModel(
          id: 'explorer',
          name: 'Explorer',
          description: 'Study in 3 different domains',
          iconEmoji: '🌐',
          condition: 'Study in 3 domains',
          progressTarget: 3,
        ),
        const BadgeModel(
          id: 'centurion',
          name: 'Centurion',
          description: 'Review 100 cards total',
          iconEmoji: '🏆',
          condition: '100 total cards reviewed',
          progressTarget: 100,
        ),
        const BadgeModel(
          id: 'ccna_starter',
          name: 'Network Nerd',
          description: 'Start any CCNA topic',
          iconEmoji: '🎓',
          condition: 'Start any CCNA topic',
        ),
        const BadgeModel(
          id: 'jee_challenger',
          name: 'JEE Challenger',
          description: 'Start any JEE topic',
          iconEmoji: '🎓',
          condition: 'Start any JEE topic',
        ),
      ];
}
