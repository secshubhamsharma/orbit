// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeatureFlags _$FeatureFlagsFromJson(Map<String, dynamic> json) {
  return _FeatureFlags.fromJson(json);
}

/// @nodoc
mixin _$FeatureFlags {
  bool get leaderboardEnabled => throw _privateConstructorUsedError;
  bool get pdfUploadEnabled => throw _privateConstructorUsedError;
  bool get quickQuizEnabled => throw _privateConstructorUsedError;

  /// Serializes this FeatureFlags to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeatureFlagsCopyWith<FeatureFlags> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureFlagsCopyWith<$Res> {
  factory $FeatureFlagsCopyWith(
    FeatureFlags value,
    $Res Function(FeatureFlags) then,
  ) = _$FeatureFlagsCopyWithImpl<$Res, FeatureFlags>;
  @useResult
  $Res call({
    bool leaderboardEnabled,
    bool pdfUploadEnabled,
    bool quickQuizEnabled,
  });
}

/// @nodoc
class _$FeatureFlagsCopyWithImpl<$Res, $Val extends FeatureFlags>
    implements $FeatureFlagsCopyWith<$Res> {
  _$FeatureFlagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaderboardEnabled = null,
    Object? pdfUploadEnabled = null,
    Object? quickQuizEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            leaderboardEnabled: null == leaderboardEnabled
                ? _value.leaderboardEnabled
                : leaderboardEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            pdfUploadEnabled: null == pdfUploadEnabled
                ? _value.pdfUploadEnabled
                : pdfUploadEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            quickQuizEnabled: null == quickQuizEnabled
                ? _value.quickQuizEnabled
                : quickQuizEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeatureFlagsImplCopyWith<$Res>
    implements $FeatureFlagsCopyWith<$Res> {
  factory _$$FeatureFlagsImplCopyWith(
    _$FeatureFlagsImpl value,
    $Res Function(_$FeatureFlagsImpl) then,
  ) = __$$FeatureFlagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool leaderboardEnabled,
    bool pdfUploadEnabled,
    bool quickQuizEnabled,
  });
}

/// @nodoc
class __$$FeatureFlagsImplCopyWithImpl<$Res>
    extends _$FeatureFlagsCopyWithImpl<$Res, _$FeatureFlagsImpl>
    implements _$$FeatureFlagsImplCopyWith<$Res> {
  __$$FeatureFlagsImplCopyWithImpl(
    _$FeatureFlagsImpl _value,
    $Res Function(_$FeatureFlagsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? leaderboardEnabled = null,
    Object? pdfUploadEnabled = null,
    Object? quickQuizEnabled = null,
  }) {
    return _then(
      _$FeatureFlagsImpl(
        leaderboardEnabled: null == leaderboardEnabled
            ? _value.leaderboardEnabled
            : leaderboardEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        pdfUploadEnabled: null == pdfUploadEnabled
            ? _value.pdfUploadEnabled
            : pdfUploadEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        quickQuizEnabled: null == quickQuizEnabled
            ? _value.quickQuizEnabled
            : quickQuizEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureFlagsImpl implements _FeatureFlags {
  const _$FeatureFlagsImpl({
    this.leaderboardEnabled = true,
    this.pdfUploadEnabled = true,
    this.quickQuizEnabled = true,
  });

  factory _$FeatureFlagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureFlagsImplFromJson(json);

  @override
  @JsonKey()
  final bool leaderboardEnabled;
  @override
  @JsonKey()
  final bool pdfUploadEnabled;
  @override
  @JsonKey()
  final bool quickQuizEnabled;

  @override
  String toString() {
    return 'FeatureFlags(leaderboardEnabled: $leaderboardEnabled, pdfUploadEnabled: $pdfUploadEnabled, quickQuizEnabled: $quickQuizEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureFlagsImpl &&
            (identical(other.leaderboardEnabled, leaderboardEnabled) ||
                other.leaderboardEnabled == leaderboardEnabled) &&
            (identical(other.pdfUploadEnabled, pdfUploadEnabled) ||
                other.pdfUploadEnabled == pdfUploadEnabled) &&
            (identical(other.quickQuizEnabled, quickQuizEnabled) ||
                other.quickQuizEnabled == quickQuizEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    leaderboardEnabled,
    pdfUploadEnabled,
    quickQuizEnabled,
  );

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureFlagsImplCopyWith<_$FeatureFlagsImpl> get copyWith =>
      __$$FeatureFlagsImplCopyWithImpl<_$FeatureFlagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureFlagsImplToJson(this);
  }
}

abstract class _FeatureFlags implements FeatureFlags {
  const factory _FeatureFlags({
    final bool leaderboardEnabled,
    final bool pdfUploadEnabled,
    final bool quickQuizEnabled,
  }) = _$FeatureFlagsImpl;

  factory _FeatureFlags.fromJson(Map<String, dynamic> json) =
      _$FeatureFlagsImpl.fromJson;

  @override
  bool get leaderboardEnabled;
  @override
  bool get pdfUploadEnabled;
  @override
  bool get quickQuizEnabled;

  /// Create a copy of FeatureFlags
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeatureFlagsImplCopyWith<_$FeatureFlagsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AppConfigModel _$AppConfigModelFromJson(Map<String, dynamic> json) {
  return _AppConfigModel.fromJson(json);
}

/// @nodoc
mixin _$AppConfigModel {
  bool get maintenanceMode => throw _privateConstructorUsedError;
  String get minimumAppVersion => throw _privateConstructorUsedError;
  bool get forceUpdateRequired => throw _privateConstructorUsedError;
  int get freeUserDailyCardLimit => throw _privateConstructorUsedError;
  int get masteryThresholdPercent => throw _privateConstructorUsedError;
  String get weeklyLeaderboardResetDay => throw _privateConstructorUsedError;
  FeatureFlags get featureFlags => throw _privateConstructorUsedError;

  /// Serializes this AppConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppConfigModelCopyWith<AppConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppConfigModelCopyWith<$Res> {
  factory $AppConfigModelCopyWith(
    AppConfigModel value,
    $Res Function(AppConfigModel) then,
  ) = _$AppConfigModelCopyWithImpl<$Res, AppConfigModel>;
  @useResult
  $Res call({
    bool maintenanceMode,
    String minimumAppVersion,
    bool forceUpdateRequired,
    int freeUserDailyCardLimit,
    int masteryThresholdPercent,
    String weeklyLeaderboardResetDay,
    FeatureFlags featureFlags,
  });

  $FeatureFlagsCopyWith<$Res> get featureFlags;
}

/// @nodoc
class _$AppConfigModelCopyWithImpl<$Res, $Val extends AppConfigModel>
    implements $AppConfigModelCopyWith<$Res> {
  _$AppConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maintenanceMode = null,
    Object? minimumAppVersion = null,
    Object? forceUpdateRequired = null,
    Object? freeUserDailyCardLimit = null,
    Object? masteryThresholdPercent = null,
    Object? weeklyLeaderboardResetDay = null,
    Object? featureFlags = null,
  }) {
    return _then(
      _value.copyWith(
            maintenanceMode: null == maintenanceMode
                ? _value.maintenanceMode
                : maintenanceMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            minimumAppVersion: null == minimumAppVersion
                ? _value.minimumAppVersion
                : minimumAppVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            forceUpdateRequired: null == forceUpdateRequired
                ? _value.forceUpdateRequired
                : forceUpdateRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            freeUserDailyCardLimit: null == freeUserDailyCardLimit
                ? _value.freeUserDailyCardLimit
                : freeUserDailyCardLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            masteryThresholdPercent: null == masteryThresholdPercent
                ? _value.masteryThresholdPercent
                : masteryThresholdPercent // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyLeaderboardResetDay: null == weeklyLeaderboardResetDay
                ? _value.weeklyLeaderboardResetDay
                : weeklyLeaderboardResetDay // ignore: cast_nullable_to_non_nullable
                      as String,
            featureFlags: null == featureFlags
                ? _value.featureFlags
                : featureFlags // ignore: cast_nullable_to_non_nullable
                      as FeatureFlags,
          )
          as $Val,
    );
  }

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeatureFlagsCopyWith<$Res> get featureFlags {
    return $FeatureFlagsCopyWith<$Res>(_value.featureFlags, (value) {
      return _then(_value.copyWith(featureFlags: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppConfigModelImplCopyWith<$Res>
    implements $AppConfigModelCopyWith<$Res> {
  factory _$$AppConfigModelImplCopyWith(
    _$AppConfigModelImpl value,
    $Res Function(_$AppConfigModelImpl) then,
  ) = __$$AppConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool maintenanceMode,
    String minimumAppVersion,
    bool forceUpdateRequired,
    int freeUserDailyCardLimit,
    int masteryThresholdPercent,
    String weeklyLeaderboardResetDay,
    FeatureFlags featureFlags,
  });

  @override
  $FeatureFlagsCopyWith<$Res> get featureFlags;
}

/// @nodoc
class __$$AppConfigModelImplCopyWithImpl<$Res>
    extends _$AppConfigModelCopyWithImpl<$Res, _$AppConfigModelImpl>
    implements _$$AppConfigModelImplCopyWith<$Res> {
  __$$AppConfigModelImplCopyWithImpl(
    _$AppConfigModelImpl _value,
    $Res Function(_$AppConfigModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maintenanceMode = null,
    Object? minimumAppVersion = null,
    Object? forceUpdateRequired = null,
    Object? freeUserDailyCardLimit = null,
    Object? masteryThresholdPercent = null,
    Object? weeklyLeaderboardResetDay = null,
    Object? featureFlags = null,
  }) {
    return _then(
      _$AppConfigModelImpl(
        maintenanceMode: null == maintenanceMode
            ? _value.maintenanceMode
            : maintenanceMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        minimumAppVersion: null == minimumAppVersion
            ? _value.minimumAppVersion
            : minimumAppVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        forceUpdateRequired: null == forceUpdateRequired
            ? _value.forceUpdateRequired
            : forceUpdateRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        freeUserDailyCardLimit: null == freeUserDailyCardLimit
            ? _value.freeUserDailyCardLimit
            : freeUserDailyCardLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        masteryThresholdPercent: null == masteryThresholdPercent
            ? _value.masteryThresholdPercent
            : masteryThresholdPercent // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyLeaderboardResetDay: null == weeklyLeaderboardResetDay
            ? _value.weeklyLeaderboardResetDay
            : weeklyLeaderboardResetDay // ignore: cast_nullable_to_non_nullable
                  as String,
        featureFlags: null == featureFlags
            ? _value.featureFlags
            : featureFlags // ignore: cast_nullable_to_non_nullable
                  as FeatureFlags,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppConfigModelImpl implements _AppConfigModel {
  const _$AppConfigModelImpl({
    this.maintenanceMode = false,
    this.minimumAppVersion = '1.0.0',
    this.forceUpdateRequired = false,
    this.freeUserDailyCardLimit = 30,
    this.masteryThresholdPercent = 70,
    this.weeklyLeaderboardResetDay = 'Monday',
    this.featureFlags = AppConfigModel._defaultFlags,
  });

  factory _$AppConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppConfigModelImplFromJson(json);

  @override
  @JsonKey()
  final bool maintenanceMode;
  @override
  @JsonKey()
  final String minimumAppVersion;
  @override
  @JsonKey()
  final bool forceUpdateRequired;
  @override
  @JsonKey()
  final int freeUserDailyCardLimit;
  @override
  @JsonKey()
  final int masteryThresholdPercent;
  @override
  @JsonKey()
  final String weeklyLeaderboardResetDay;
  @override
  @JsonKey()
  final FeatureFlags featureFlags;

  @override
  String toString() {
    return 'AppConfigModel(maintenanceMode: $maintenanceMode, minimumAppVersion: $minimumAppVersion, forceUpdateRequired: $forceUpdateRequired, freeUserDailyCardLimit: $freeUserDailyCardLimit, masteryThresholdPercent: $masteryThresholdPercent, weeklyLeaderboardResetDay: $weeklyLeaderboardResetDay, featureFlags: $featureFlags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppConfigModelImpl &&
            (identical(other.maintenanceMode, maintenanceMode) ||
                other.maintenanceMode == maintenanceMode) &&
            (identical(other.minimumAppVersion, minimumAppVersion) ||
                other.minimumAppVersion == minimumAppVersion) &&
            (identical(other.forceUpdateRequired, forceUpdateRequired) ||
                other.forceUpdateRequired == forceUpdateRequired) &&
            (identical(other.freeUserDailyCardLimit, freeUserDailyCardLimit) ||
                other.freeUserDailyCardLimit == freeUserDailyCardLimit) &&
            (identical(
                  other.masteryThresholdPercent,
                  masteryThresholdPercent,
                ) ||
                other.masteryThresholdPercent == masteryThresholdPercent) &&
            (identical(
                  other.weeklyLeaderboardResetDay,
                  weeklyLeaderboardResetDay,
                ) ||
                other.weeklyLeaderboardResetDay == weeklyLeaderboardResetDay) &&
            (identical(other.featureFlags, featureFlags) ||
                other.featureFlags == featureFlags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    maintenanceMode,
    minimumAppVersion,
    forceUpdateRequired,
    freeUserDailyCardLimit,
    masteryThresholdPercent,
    weeklyLeaderboardResetDay,
    featureFlags,
  );

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppConfigModelImplCopyWith<_$AppConfigModelImpl> get copyWith =>
      __$$AppConfigModelImplCopyWithImpl<_$AppConfigModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppConfigModelImplToJson(this);
  }
}

abstract class _AppConfigModel implements AppConfigModel {
  const factory _AppConfigModel({
    final bool maintenanceMode,
    final String minimumAppVersion,
    final bool forceUpdateRequired,
    final int freeUserDailyCardLimit,
    final int masteryThresholdPercent,
    final String weeklyLeaderboardResetDay,
    final FeatureFlags featureFlags,
  }) = _$AppConfigModelImpl;

  factory _AppConfigModel.fromJson(Map<String, dynamic> json) =
      _$AppConfigModelImpl.fromJson;

  @override
  bool get maintenanceMode;
  @override
  String get minimumAppVersion;
  @override
  bool get forceUpdateRequired;
  @override
  int get freeUserDailyCardLimit;
  @override
  int get masteryThresholdPercent;
  @override
  String get weeklyLeaderboardResetDay;
  @override
  FeatureFlags get featureFlags;

  /// Create a copy of AppConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppConfigModelImplCopyWith<_$AppConfigModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
