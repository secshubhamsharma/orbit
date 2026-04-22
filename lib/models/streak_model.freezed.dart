// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StreakModel _$StreakModelFromJson(Map<String, dynamic> json) {
  return _StreakModel.fromJson(json);
}

/// @nodoc
mixin _$StreakModel {
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get lastStudiedDate => throw _privateConstructorUsedError;
  int get streakFreezeAvailable => throw _privateConstructorUsedError;
  Map<String, int> get weeklyActivity => throw _privateConstructorUsedError;

  /// Serializes this StreakModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakModelCopyWith<StreakModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakModelCopyWith<$Res> {
  factory $StreakModelCopyWith(
    StreakModel value,
    $Res Function(StreakModel) then,
  ) = _$StreakModelCopyWithImpl<$Res, StreakModel>;
  @useResult
  $Res call({
    int currentStreak,
    int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    int streakFreezeAvailable,
    Map<String, int> weeklyActivity,
  });
}

/// @nodoc
class _$StreakModelCopyWithImpl<$Res, $Val extends StreakModel>
    implements $StreakModelCopyWith<$Res> {
  _$StreakModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastStudiedDate = freezed,
    Object? streakFreezeAvailable = null,
    Object? weeklyActivity = null,
  }) {
    return _then(
      _value.copyWith(
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
            weeklyActivity: null == weeklyActivity
                ? _value.weeklyActivity
                : weeklyActivity // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StreakModelImplCopyWith<$Res>
    implements $StreakModelCopyWith<$Res> {
  factory _$$StreakModelImplCopyWith(
    _$StreakModelImpl value,
    $Res Function(_$StreakModelImpl) then,
  ) = __$$StreakModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStreak,
    int longestStreak,
    @_NullableTimestampConverter() DateTime? lastStudiedDate,
    int streakFreezeAvailable,
    Map<String, int> weeklyActivity,
  });
}

/// @nodoc
class __$$StreakModelImplCopyWithImpl<$Res>
    extends _$StreakModelCopyWithImpl<$Res, _$StreakModelImpl>
    implements _$$StreakModelImplCopyWith<$Res> {
  __$$StreakModelImplCopyWithImpl(
    _$StreakModelImpl _value,
    $Res Function(_$StreakModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StreakModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastStudiedDate = freezed,
    Object? streakFreezeAvailable = null,
    Object? weeklyActivity = null,
  }) {
    return _then(
      _$StreakModelImpl(
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
        weeklyActivity: null == weeklyActivity
            ? _value._weeklyActivity
            : weeklyActivity // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakModelImpl extends _StreakModel {
  const _$StreakModelImpl({
    this.currentStreak = 0,
    this.longestStreak = 0,
    @_NullableTimestampConverter() this.lastStudiedDate,
    this.streakFreezeAvailable = 1,
    final Map<String, int> weeklyActivity = const {},
  }) : _weeklyActivity = weeklyActivity,
       super._();

  factory _$StreakModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakModelImplFromJson(json);

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
  final Map<String, int> _weeklyActivity;
  @override
  @JsonKey()
  Map<String, int> get weeklyActivity {
    if (_weeklyActivity is EqualUnmodifiableMapView) return _weeklyActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_weeklyActivity);
  }

  @override
  String toString() {
    return 'StreakModel(currentStreak: $currentStreak, longestStreak: $longestStreak, lastStudiedDate: $lastStudiedDate, streakFreezeAvailable: $streakFreezeAvailable, weeklyActivity: $weeklyActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakModelImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastStudiedDate, lastStudiedDate) ||
                other.lastStudiedDate == lastStudiedDate) &&
            (identical(other.streakFreezeAvailable, streakFreezeAvailable) ||
                other.streakFreezeAvailable == streakFreezeAvailable) &&
            const DeepCollectionEquality().equals(
              other._weeklyActivity,
              _weeklyActivity,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStreak,
    longestStreak,
    lastStudiedDate,
    streakFreezeAvailable,
    const DeepCollectionEquality().hash(_weeklyActivity),
  );

  /// Create a copy of StreakModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      __$$StreakModelImplCopyWithImpl<_$StreakModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakModelImplToJson(this);
  }
}

abstract class _StreakModel extends StreakModel {
  const factory _StreakModel({
    final int currentStreak,
    final int longestStreak,
    @_NullableTimestampConverter() final DateTime? lastStudiedDate,
    final int streakFreezeAvailable,
    final Map<String, int> weeklyActivity,
  }) = _$StreakModelImpl;
  const _StreakModel._() : super._();

  factory _StreakModel.fromJson(Map<String, dynamic> json) =
      _$StreakModelImpl.fromJson;

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
  Map<String, int> get weeklyActivity;

  /// Create a copy of StreakModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakModelImplCopyWith<_$StreakModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
