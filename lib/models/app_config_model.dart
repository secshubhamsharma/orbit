import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_config_model.freezed.dart';
part 'app_config_model.g.dart';

/// Feature flags nested inside [AppConfigModel].
@freezed
class FeatureFlags with _$FeatureFlags {
  const factory FeatureFlags({
    @Default(true) bool leaderboardEnabled,
    @Default(true) bool pdfUploadEnabled,
    @Default(true) bool quickQuizEnabled,
  }) = _FeatureFlags;

  factory FeatureFlags.fromJson(Map<String, dynamic> json) =>
      _$FeatureFlagsFromJson(json);
}

/// The single `appConfig/global` document — read once on app start.
@freezed
class AppConfigModel with _$AppConfigModel {
  const factory AppConfigModel({
    @Default(false) bool maintenanceMode,
    @Default('1.0.0') String minimumAppVersion,
    @Default(false) bool forceUpdateRequired,
    @Default(30) int freeUserDailyCardLimit,
    @Default(70) int masteryThresholdPercent,
    @Default('Monday') String weeklyLeaderboardResetDay,
    @Default(AppConfigModel._defaultFlags) FeatureFlags featureFlags,
  }) = _AppConfigModel;

  factory AppConfigModel.fromJson(Map<String, dynamic> json) =>
      _$AppConfigModelFromJson(json);

  /// Default flags used when the Firestore doc has no `featureFlags` field.
  static const _defaultFlags = FeatureFlags();
}
