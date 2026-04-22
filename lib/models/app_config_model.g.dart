// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeatureFlagsImpl _$$FeatureFlagsImplFromJson(Map<String, dynamic> json) =>
    _$FeatureFlagsImpl(
      leaderboardEnabled: json['leaderboardEnabled'] as bool? ?? true,
      pdfUploadEnabled: json['pdfUploadEnabled'] as bool? ?? true,
      quickQuizEnabled: json['quickQuizEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$FeatureFlagsImplToJson(_$FeatureFlagsImpl instance) =>
    <String, dynamic>{
      'leaderboardEnabled': instance.leaderboardEnabled,
      'pdfUploadEnabled': instance.pdfUploadEnabled,
      'quickQuizEnabled': instance.quickQuizEnabled,
    };

_$AppConfigModelImpl _$$AppConfigModelImplFromJson(Map<String, dynamic> json) =>
    _$AppConfigModelImpl(
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      minimumAppVersion: json['minimumAppVersion'] as String? ?? '1.0.0',
      forceUpdateRequired: json['forceUpdateRequired'] as bool? ?? false,
      freeUserDailyCardLimit:
          (json['freeUserDailyCardLimit'] as num?)?.toInt() ?? 30,
      masteryThresholdPercent:
          (json['masteryThresholdPercent'] as num?)?.toInt() ?? 70,
      weeklyLeaderboardResetDay:
          json['weeklyLeaderboardResetDay'] as String? ?? 'Monday',
      featureFlags: json['featureFlags'] == null
          ? AppConfigModel._defaultFlags
          : FeatureFlags.fromJson(json['featureFlags'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AppConfigModelImplToJson(
  _$AppConfigModelImpl instance,
) => <String, dynamic>{
  'maintenanceMode': instance.maintenanceMode,
  'minimumAppVersion': instance.minimumAppVersion,
  'forceUpdateRequired': instance.forceUpdateRequired,
  'freeUserDailyCardLimit': instance.freeUserDailyCardLimit,
  'masteryThresholdPercent': instance.masteryThresholdPercent,
  'weeklyLeaderboardResetDay': instance.weeklyLeaderboardResetDay,
  'featureFlags': instance.featureFlags,
};
