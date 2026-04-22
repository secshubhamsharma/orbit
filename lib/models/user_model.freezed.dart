// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) {
  return _UserSettings.fromJson(json);
}

/// @nodoc
mixin _$UserSettings {
  bool get reminderEnabled => throw _privateConstructorUsedError;
  String get reminderTime => throw _privateConstructorUsedError;
  bool get streakAlertEnabled => throw _privateConstructorUsedError;
  bool get darkMode => throw _privateConstructorUsedError;
  String get fontSize => throw _privateConstructorUsedError;
  bool get hideFromLeaderboard => throw _privateConstructorUsedError;
  String get defaultCardOrder => throw _privateConstructorUsedError;

  /// Serializes this UserSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSettingsCopyWith<UserSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSettingsCopyWith<$Res> {
  factory $UserSettingsCopyWith(
    UserSettings value,
    $Res Function(UserSettings) then,
  ) = _$UserSettingsCopyWithImpl<$Res, UserSettings>;
  @useResult
  $Res call({
    bool reminderEnabled,
    String reminderTime,
    bool streakAlertEnabled,
    bool darkMode,
    String fontSize,
    bool hideFromLeaderboard,
    String defaultCardOrder,
  });
}

/// @nodoc
class _$UserSettingsCopyWithImpl<$Res, $Val extends UserSettings>
    implements $UserSettingsCopyWith<$Res> {
  _$UserSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reminderEnabled = null,
    Object? reminderTime = null,
    Object? streakAlertEnabled = null,
    Object? darkMode = null,
    Object? fontSize = null,
    Object? hideFromLeaderboard = null,
    Object? defaultCardOrder = null,
  }) {
    return _then(
      _value.copyWith(
            reminderEnabled: null == reminderEnabled
                ? _value.reminderEnabled
                : reminderEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            reminderTime: null == reminderTime
                ? _value.reminderTime
                : reminderTime // ignore: cast_nullable_to_non_nullable
                      as String,
            streakAlertEnabled: null == streakAlertEnabled
                ? _value.streakAlertEnabled
                : streakAlertEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            darkMode: null == darkMode
                ? _value.darkMode
                : darkMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            fontSize: null == fontSize
                ? _value.fontSize
                : fontSize // ignore: cast_nullable_to_non_nullable
                      as String,
            hideFromLeaderboard: null == hideFromLeaderboard
                ? _value.hideFromLeaderboard
                : hideFromLeaderboard // ignore: cast_nullable_to_non_nullable
                      as bool,
            defaultCardOrder: null == defaultCardOrder
                ? _value.defaultCardOrder
                : defaultCardOrder // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserSettingsImplCopyWith<$Res>
    implements $UserSettingsCopyWith<$Res> {
  factory _$$UserSettingsImplCopyWith(
    _$UserSettingsImpl value,
    $Res Function(_$UserSettingsImpl) then,
  ) = __$$UserSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool reminderEnabled,
    String reminderTime,
    bool streakAlertEnabled,
    bool darkMode,
    String fontSize,
    bool hideFromLeaderboard,
    String defaultCardOrder,
  });
}

/// @nodoc
class __$$UserSettingsImplCopyWithImpl<$Res>
    extends _$UserSettingsCopyWithImpl<$Res, _$UserSettingsImpl>
    implements _$$UserSettingsImplCopyWith<$Res> {
  __$$UserSettingsImplCopyWithImpl(
    _$UserSettingsImpl _value,
    $Res Function(_$UserSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reminderEnabled = null,
    Object? reminderTime = null,
    Object? streakAlertEnabled = null,
    Object? darkMode = null,
    Object? fontSize = null,
    Object? hideFromLeaderboard = null,
    Object? defaultCardOrder = null,
  }) {
    return _then(
      _$UserSettingsImpl(
        reminderEnabled: null == reminderEnabled
            ? _value.reminderEnabled
            : reminderEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        reminderTime: null == reminderTime
            ? _value.reminderTime
            : reminderTime // ignore: cast_nullable_to_non_nullable
                  as String,
        streakAlertEnabled: null == streakAlertEnabled
            ? _value.streakAlertEnabled
            : streakAlertEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        darkMode: null == darkMode
            ? _value.darkMode
            : darkMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        fontSize: null == fontSize
            ? _value.fontSize
            : fontSize // ignore: cast_nullable_to_non_nullable
                  as String,
        hideFromLeaderboard: null == hideFromLeaderboard
            ? _value.hideFromLeaderboard
            : hideFromLeaderboard // ignore: cast_nullable_to_non_nullable
                  as bool,
        defaultCardOrder: null == defaultCardOrder
            ? _value.defaultCardOrder
            : defaultCardOrder // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserSettingsImpl implements _UserSettings {
  const _$UserSettingsImpl({
    this.reminderEnabled = true,
    this.reminderTime = '20:00',
    this.streakAlertEnabled = true,
    this.darkMode = false,
    this.fontSize = 'medium',
    this.hideFromLeaderboard = false,
    this.defaultCardOrder = 'due_first',
  });

  factory _$UserSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool reminderEnabled;
  @override
  @JsonKey()
  final String reminderTime;
  @override
  @JsonKey()
  final bool streakAlertEnabled;
  @override
  @JsonKey()
  final bool darkMode;
  @override
  @JsonKey()
  final String fontSize;
  @override
  @JsonKey()
  final bool hideFromLeaderboard;
  @override
  @JsonKey()
  final String defaultCardOrder;

  @override
  String toString() {
    return 'UserSettings(reminderEnabled: $reminderEnabled, reminderTime: $reminderTime, streakAlertEnabled: $streakAlertEnabled, darkMode: $darkMode, fontSize: $fontSize, hideFromLeaderboard: $hideFromLeaderboard, defaultCardOrder: $defaultCardOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSettingsImpl &&
            (identical(other.reminderEnabled, reminderEnabled) ||
                other.reminderEnabled == reminderEnabled) &&
            (identical(other.reminderTime, reminderTime) ||
                other.reminderTime == reminderTime) &&
            (identical(other.streakAlertEnabled, streakAlertEnabled) ||
                other.streakAlertEnabled == streakAlertEnabled) &&
            (identical(other.darkMode, darkMode) ||
                other.darkMode == darkMode) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.hideFromLeaderboard, hideFromLeaderboard) ||
                other.hideFromLeaderboard == hideFromLeaderboard) &&
            (identical(other.defaultCardOrder, defaultCardOrder) ||
                other.defaultCardOrder == defaultCardOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    reminderEnabled,
    reminderTime,
    streakAlertEnabled,
    darkMode,
    fontSize,
    hideFromLeaderboard,
    defaultCardOrder,
  );

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      __$$UserSettingsImplCopyWithImpl<_$UserSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserSettingsImplToJson(this);
  }
}

abstract class _UserSettings implements UserSettings {
  const factory _UserSettings({
    final bool reminderEnabled,
    final String reminderTime,
    final bool streakAlertEnabled,
    final bool darkMode,
    final String fontSize,
    final bool hideFromLeaderboard,
    final String defaultCardOrder,
  }) = _$UserSettingsImpl;

  factory _UserSettings.fromJson(Map<String, dynamic> json) =
      _$UserSettingsImpl.fromJson;

  @override
  bool get reminderEnabled;
  @override
  String get reminderTime;
  @override
  bool get streakAlertEnabled;
  @override
  bool get darkMode;
  @override
  String get fontSize;
  @override
  bool get hideFromLeaderboard;
  @override
  String get defaultCardOrder;

  /// Create a copy of UserSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSettingsImplCopyWith<_$UserSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get lastActiveAt => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  String get fcmToken => throw _privateConstructorUsedError;
  List<String> get selectedDomains => throw _privateConstructorUsedError;
  int get dailyGoalMinutes => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get lastStudiedDate => throw _privateConstructorUsedError;
  int get streakFreezeAvailable => throw _privateConstructorUsedError;
  int get totalCardsReviewed => throw _privateConstructorUsedError;
  int get totalStudyMinutes => throw _privateConstructorUsedError;
  double get overallAccuracy => throw _privateConstructorUsedError;
  int get topicsStarted => throw _privateConstructorUsedError;
  int get weeklyCardsReviewed => throw _privateConstructorUsedError;
  List<String> get earnedBadges => throw _privateConstructorUsedError;
  UserSettings get settings => throw _privateConstructorUsedError;
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  bool get emailVerified => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String uid,
    String displayName,
    String email,
    String? photoUrl,
    @_TimestampConverter() DateTime createdAt,
    @_TimestampConverter() DateTime lastActiveAt,
    bool isPremium,
    String fcmToken,
    List<String> selectedDomains,
    int dailyGoalMinutes,
    int currentStreak,
    int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    int streakFreezeAvailable,
    int totalCardsReviewed,
    int totalStudyMinutes,
    double overallAccuracy,
    int topicsStarted,
    int weeklyCardsReviewed,
    List<String> earnedBadges,
    UserSettings settings,
    bool onboardingCompleted,
    bool emailVerified,
  });

  $UserSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? email = null,
    Object? photoUrl = freezed,
    Object? createdAt = null,
    Object? lastActiveAt = null,
    Object? isPremium = null,
    Object? fcmToken = null,
    Object? selectedDomains = null,
    Object? dailyGoalMinutes = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastStudiedDate = freezed,
    Object? streakFreezeAvailable = null,
    Object? totalCardsReviewed = null,
    Object? totalStudyMinutes = null,
    Object? overallAccuracy = null,
    Object? topicsStarted = null,
    Object? weeklyCardsReviewed = null,
    Object? earnedBadges = null,
    Object? settings = null,
    Object? onboardingCompleted = null,
    Object? emailVerified = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastActiveAt: null == lastActiveAt
                ? _value.lastActiveAt
                : lastActiveAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            fcmToken: null == fcmToken
                ? _value.fcmToken
                : fcmToken // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedDomains: null == selectedDomains
                ? _value.selectedDomains
                : selectedDomains // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dailyGoalMinutes: null == dailyGoalMinutes
                ? _value.dailyGoalMinutes
                : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            lastStudiedDate: freezed == lastStudiedDate
                ? _value.lastStudiedDate
                : lastStudiedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            streakFreezeAvailable: null == streakFreezeAvailable
                ? _value.streakFreezeAvailable
                : streakFreezeAvailable // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCardsReviewed: null == totalCardsReviewed
                ? _value.totalCardsReviewed
                : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalStudyMinutes: null == totalStudyMinutes
                ? _value.totalStudyMinutes
                : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            overallAccuracy: null == overallAccuracy
                ? _value.overallAccuracy
                : overallAccuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            topicsStarted: null == topicsStarted
                ? _value.topicsStarted
                : topicsStarted // ignore: cast_nullable_to_non_nullable
                      as int,
            weeklyCardsReviewed: null == weeklyCardsReviewed
                ? _value.weeklyCardsReviewed
                : weeklyCardsReviewed // ignore: cast_nullable_to_non_nullable
                      as int,
            earnedBadges: null == earnedBadges
                ? _value.earnedBadges
                : earnedBadges // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            settings: null == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as UserSettings,
            onboardingCompleted: null == onboardingCompleted
                ? _value.onboardingCompleted
                : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailVerified: null == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSettingsCopyWith<$Res> get settings {
    return $UserSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String displayName,
    String email,
    String? photoUrl,
    @_TimestampConverter() DateTime createdAt,
    @_TimestampConverter() DateTime lastActiveAt,
    bool isPremium,
    String fcmToken,
    List<String> selectedDomains,
    int dailyGoalMinutes,
    int currentStreak,
    int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    int streakFreezeAvailable,
    int totalCardsReviewed,
    int totalStudyMinutes,
    double overallAccuracy,
    int topicsStarted,
    int weeklyCardsReviewed,
    List<String> earnedBadges,
    UserSettings settings,
    bool onboardingCompleted,
    bool emailVerified,
  });

  @override
  $UserSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? email = null,
    Object? photoUrl = freezed,
    Object? createdAt = null,
    Object? lastActiveAt = null,
    Object? isPremium = null,
    Object? fcmToken = null,
    Object? selectedDomains = null,
    Object? dailyGoalMinutes = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastStudiedDate = freezed,
    Object? streakFreezeAvailable = null,
    Object? totalCardsReviewed = null,
    Object? totalStudyMinutes = null,
    Object? overallAccuracy = null,
    Object? topicsStarted = null,
    Object? weeklyCardsReviewed = null,
    Object? earnedBadges = null,
    Object? settings = null,
    Object? onboardingCompleted = null,
    Object? emailVerified = null,
  }) {
    return _then(
      _$UserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastActiveAt: null == lastActiveAt
            ? _value.lastActiveAt
            : lastActiveAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        fcmToken: null == fcmToken
            ? _value.fcmToken
            : fcmToken // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedDomains: null == selectedDomains
            ? _value._selectedDomains
            : selectedDomains // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dailyGoalMinutes: null == dailyGoalMinutes
            ? _value.dailyGoalMinutes
            : dailyGoalMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        lastStudiedDate: freezed == lastStudiedDate
            ? _value.lastStudiedDate
            : lastStudiedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        streakFreezeAvailable: null == streakFreezeAvailable
            ? _value.streakFreezeAvailable
            : streakFreezeAvailable // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCardsReviewed: null == totalCardsReviewed
            ? _value.totalCardsReviewed
            : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalStudyMinutes: null == totalStudyMinutes
            ? _value.totalStudyMinutes
            : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        overallAccuracy: null == overallAccuracy
            ? _value.overallAccuracy
            : overallAccuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        topicsStarted: null == topicsStarted
            ? _value.topicsStarted
            : topicsStarted // ignore: cast_nullable_to_non_nullable
                  as int,
        weeklyCardsReviewed: null == weeklyCardsReviewed
            ? _value.weeklyCardsReviewed
            : weeklyCardsReviewed // ignore: cast_nullable_to_non_nullable
                  as int,
        earnedBadges: null == earnedBadges
            ? _value._earnedBadges
            : earnedBadges // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        settings: null == settings
            ? _value.settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as UserSettings,
        onboardingCompleted: null == onboardingCompleted
            ? _value.onboardingCompleted
            : onboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailVerified: null == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    @_TimestampConverter() required this.createdAt,
    @_TimestampConverter() required this.lastActiveAt,
    this.isPremium = false,
    this.fcmToken = '',
    final List<String> selectedDomains = const [],
    this.dailyGoalMinutes = 10,
    this.currentStreak = 0,
    this.longestStreak = 0,
    @_NullableTimestampConverter() this.lastStudiedDate,
    this.streakFreezeAvailable = 1,
    this.totalCardsReviewed = 0,
    this.totalStudyMinutes = 0,
    this.overallAccuracy = 0.0,
    this.topicsStarted = 0,
    this.weeklyCardsReviewed = 0,
    final List<String> earnedBadges = const [],
    this.settings = const UserSettings(),
    this.onboardingCompleted = false,
    this.emailVerified = false,
  }) : _selectedDomains = selectedDomains,
       _earnedBadges = earnedBadges;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String email;
  @override
  final String? photoUrl;
  @override
  @_TimestampConverter()
  final DateTime createdAt;
  @override
  @_TimestampConverter()
  final DateTime lastActiveAt;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  @JsonKey()
  final String fcmToken;
  final List<String> _selectedDomains;
  @override
  @JsonKey()
  List<String> get selectedDomains {
    if (_selectedDomains is EqualUnmodifiableListView) return _selectedDomains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedDomains);
  }

  @override
  @JsonKey()
  final int dailyGoalMinutes;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;
  @override
  @_NullableTimestampConverter()
  final DateTime? lastStudiedDate;
  @override
  @JsonKey()
  final int streakFreezeAvailable;
  @override
  @JsonKey()
  final int totalCardsReviewed;
  @override
  @JsonKey()
  final int totalStudyMinutes;
  @override
  @JsonKey()
  final double overallAccuracy;
  @override
  @JsonKey()
  final int topicsStarted;
  @override
  @JsonKey()
  final int weeklyCardsReviewed;
  final List<String> _earnedBadges;
  @override
  @JsonKey()
  List<String> get earnedBadges {
    if (_earnedBadges is EqualUnmodifiableListView) return _earnedBadges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_earnedBadges);
  }

  @override
  @JsonKey()
  final UserSettings settings;
  @override
  @JsonKey()
  final bool onboardingCompleted;
  @override
  @JsonKey()
  final bool emailVerified;

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, email: $email, photoUrl: $photoUrl, createdAt: $createdAt, lastActiveAt: $lastActiveAt, isPremium: $isPremium, fcmToken: $fcmToken, selectedDomains: $selectedDomains, dailyGoalMinutes: $dailyGoalMinutes, currentStreak: $currentStreak, longestStreak: $longestStreak, lastStudiedDate: $lastStudiedDate, streakFreezeAvailable: $streakFreezeAvailable, totalCardsReviewed: $totalCardsReviewed, totalStudyMinutes: $totalStudyMinutes, overallAccuracy: $overallAccuracy, topicsStarted: $topicsStarted, weeklyCardsReviewed: $weeklyCardsReviewed, earnedBadges: $earnedBadges, settings: $settings, onboardingCompleted: $onboardingCompleted, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastActiveAt, lastActiveAt) ||
                other.lastActiveAt == lastActiveAt) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            const DeepCollectionEquality().equals(
              other._selectedDomains,
              _selectedDomains,
            ) &&
            (identical(other.dailyGoalMinutes, dailyGoalMinutes) ||
                other.dailyGoalMinutes == dailyGoalMinutes) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastStudiedDate, lastStudiedDate) ||
                other.lastStudiedDate == lastStudiedDate) &&
            (identical(other.streakFreezeAvailable, streakFreezeAvailable) ||
                other.streakFreezeAvailable == streakFreezeAvailable) &&
            (identical(other.totalCardsReviewed, totalCardsReviewed) ||
                other.totalCardsReviewed == totalCardsReviewed) &&
            (identical(other.totalStudyMinutes, totalStudyMinutes) ||
                other.totalStudyMinutes == totalStudyMinutes) &&
            (identical(other.overallAccuracy, overallAccuracy) ||
                other.overallAccuracy == overallAccuracy) &&
            (identical(other.topicsStarted, topicsStarted) ||
                other.topicsStarted == topicsStarted) &&
            (identical(other.weeklyCardsReviewed, weeklyCardsReviewed) ||
                other.weeklyCardsReviewed == weeklyCardsReviewed) &&
            const DeepCollectionEquality().equals(
              other._earnedBadges,
              _earnedBadges,
            ) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    uid,
    displayName,
    email,
    photoUrl,
    createdAt,
    lastActiveAt,
    isPremium,
    fcmToken,
    const DeepCollectionEquality().hash(_selectedDomains),
    dailyGoalMinutes,
    currentStreak,
    longestStreak,
    lastStudiedDate,
    streakFreezeAvailable,
    totalCardsReviewed,
    totalStudyMinutes,
    overallAccuracy,
    topicsStarted,
    weeklyCardsReviewed,
    const DeepCollectionEquality().hash(_earnedBadges),
    settings,
    onboardingCompleted,
    emailVerified,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String uid,
    required final String displayName,
    required final String email,
    final String? photoUrl,
    @_TimestampConverter() required final DateTime createdAt,
    @_TimestampConverter() required final DateTime lastActiveAt,
    final bool isPremium,
    final String fcmToken,
    final List<String> selectedDomains,
    final int dailyGoalMinutes,
    final int currentStreak,
    final int longestStreak,
    @_NullableTimestampConverter() final DateTime? lastStudiedDate,
    final int streakFreezeAvailable,
    final int totalCardsReviewed,
    final int totalStudyMinutes,
    final double overallAccuracy,
    final int topicsStarted,
    final int weeklyCardsReviewed,
    final List<String> earnedBadges,
    final UserSettings settings,
    final bool onboardingCompleted,
    final bool emailVerified,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  String get email;
  @override
  String? get photoUrl;
  @override
  @_TimestampConverter()
  DateTime get createdAt;
  @override
  @_TimestampConverter()
  DateTime get lastActiveAt;
  @override
  bool get isPremium;
  @override
  String get fcmToken;
  @override
  List<String> get selectedDomains;
  @override
  int get dailyGoalMinutes;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  @_NullableTimestampConverter()
  DateTime? get lastStudiedDate;
  @override
  int get streakFreezeAvailable;
  @override
  int get totalCardsReviewed;
  @override
  int get totalStudyMinutes;
  @override
  double get overallAccuracy;
  @override
  int get topicsStarted;
  @override
  int get weeklyCardsReviewed;
  @override
  List<String> get earnedBadges;
  @override
  UserSettings get settings;
  @override
  bool get onboardingCompleted;
  @override
  bool get emailVerified;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
