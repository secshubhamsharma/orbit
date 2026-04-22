// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewSessionModel _$ReviewSessionModelFromJson(Map<String, dynamic> json) {
  return _ReviewSessionModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewSessionModel {
  String get sessionId => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get startedAt => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  int get cardsReviewed => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get incorrectCount => throw _privateConstructorUsedError;
  double get accuracy => throw _privateConstructorUsedError;
  Map<String, int> get ratings => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;

  /// Serializes this ReviewSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewSessionModelCopyWith<ReviewSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewSessionModelCopyWith<$Res> {
  factory $ReviewSessionModelCopyWith(
    ReviewSessionModel value,
    $Res Function(ReviewSessionModel) then,
  ) = _$ReviewSessionModelCopyWithImpl<$Res, ReviewSessionModel>;
  @useResult
  $Res call({
    String sessionId,
    String topicId,
    String topicName,
    String domainId,
    @_TimestampConverter() DateTime startedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    int durationSeconds,
    int cardsReviewed,
    int correctCount,
    int incorrectCount,
    double accuracy,
    Map<String, int> ratings,
    int xpEarned,
  });
}

/// @nodoc
class _$ReviewSessionModelCopyWithImpl<$Res, $Val extends ReviewSessionModel>
    implements $ReviewSessionModelCopyWith<$Res> {
  _$ReviewSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? topicId = null,
    Object? topicName = null,
    Object? domainId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? durationSeconds = null,
    Object? cardsReviewed = null,
    Object? correctCount = null,
    Object? incorrectCount = null,
    Object? accuracy = null,
    Object? ratings = null,
    Object? xpEarned = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            cardsReviewed: null == cardsReviewed
                ? _value.cardsReviewed
                : cardsReviewed // ignore: cast_nullable_to_non_nullable
                      as int,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            incorrectCount: null == incorrectCount
                ? _value.incorrectCount
                : incorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
            accuracy: null == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            ratings: null == ratings
                ? _value.ratings
                : ratings // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            xpEarned: null == xpEarned
                ? _value.xpEarned
                : xpEarned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewSessionModelImplCopyWith<$Res>
    implements $ReviewSessionModelCopyWith<$Res> {
  factory _$$ReviewSessionModelImplCopyWith(
    _$ReviewSessionModelImpl value,
    $Res Function(_$ReviewSessionModelImpl) then,
  ) = __$$ReviewSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String topicId,
    String topicName,
    String domainId,
    @_TimestampConverter() DateTime startedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    int durationSeconds,
    int cardsReviewed,
    int correctCount,
    int incorrectCount,
    double accuracy,
    Map<String, int> ratings,
    int xpEarned,
  });
}

/// @nodoc
class __$$ReviewSessionModelImplCopyWithImpl<$Res>
    extends _$ReviewSessionModelCopyWithImpl<$Res, _$ReviewSessionModelImpl>
    implements _$$ReviewSessionModelImplCopyWith<$Res> {
  __$$ReviewSessionModelImplCopyWithImpl(
    _$ReviewSessionModelImpl _value,
    $Res Function(_$ReviewSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? topicId = null,
    Object? topicName = null,
    Object? domainId = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? durationSeconds = null,
    Object? cardsReviewed = null,
    Object? correctCount = null,
    Object? incorrectCount = null,
    Object? accuracy = null,
    Object? ratings = null,
    Object? xpEarned = null,
  }) {
    return _then(
      _$ReviewSessionModelImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsReviewed: null == cardsReviewed
            ? _value.cardsReviewed
            : cardsReviewed // ignore: cast_nullable_to_non_nullable
                  as int,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        incorrectCount: null == incorrectCount
            ? _value.incorrectCount
            : incorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
        accuracy: null == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        ratings: null == ratings
            ? _value._ratings
            : ratings // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        xpEarned: null == xpEarned
            ? _value.xpEarned
            : xpEarned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewSessionModelImpl implements _ReviewSessionModel {
  const _$ReviewSessionModelImpl({
    required this.sessionId,
    required this.topicId,
    this.topicName = '',
    this.domainId = '',
    @_TimestampConverter() required this.startedAt,
    @_NullableTimestampConverter() this.completedAt,
    this.durationSeconds = 0,
    this.cardsReviewed = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.accuracy = 0.0,
    final Map<String, int> ratings = const {},
    this.xpEarned = 0,
  }) : _ratings = ratings;

  factory _$ReviewSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewSessionModelImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String topicId;
  @override
  @JsonKey()
  final String topicName;
  @override
  @JsonKey()
  final String domainId;
  @override
  @_TimestampConverter()
  final DateTime startedAt;
  @override
  @_NullableTimestampConverter()
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int durationSeconds;
  @override
  @JsonKey()
  final int cardsReviewed;
  @override
  @JsonKey()
  final int correctCount;
  @override
  @JsonKey()
  final int incorrectCount;
  @override
  @JsonKey()
  final double accuracy;
  final Map<String, int> _ratings;
  @override
  @JsonKey()
  Map<String, int> get ratings {
    if (_ratings is EqualUnmodifiableMapView) return _ratings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ratings);
  }

  @override
  @JsonKey()
  final int xpEarned;

  @override
  String toString() {
    return 'ReviewSessionModel(sessionId: $sessionId, topicId: $topicId, topicName: $topicName, domainId: $domainId, startedAt: $startedAt, completedAt: $completedAt, durationSeconds: $durationSeconds, cardsReviewed: $cardsReviewed, correctCount: $correctCount, incorrectCount: $incorrectCount, accuracy: $accuracy, ratings: $ratings, xpEarned: $xpEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewSessionModelImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.cardsReviewed, cardsReviewed) ||
                other.cardsReviewed == cardsReviewed) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.incorrectCount, incorrectCount) ||
                other.incorrectCount == incorrectCount) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            const DeepCollectionEquality().equals(other._ratings, _ratings) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    topicId,
    topicName,
    domainId,
    startedAt,
    completedAt,
    durationSeconds,
    cardsReviewed,
    correctCount,
    incorrectCount,
    accuracy,
    const DeepCollectionEquality().hash(_ratings),
    xpEarned,
  );

  /// Create a copy of ReviewSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewSessionModelImplCopyWith<_$ReviewSessionModelImpl> get copyWith =>
      __$$ReviewSessionModelImplCopyWithImpl<_$ReviewSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewSessionModelImplToJson(this);
  }
}

abstract class _ReviewSessionModel implements ReviewSessionModel {
  const factory _ReviewSessionModel({
    required final String sessionId,
    required final String topicId,
    final String topicName,
    final String domainId,
    @_TimestampConverter() required final DateTime startedAt,
    @_NullableTimestampConverter() final DateTime? completedAt,
    final int durationSeconds,
    final int cardsReviewed,
    final int correctCount,
    final int incorrectCount,
    final double accuracy,
    final Map<String, int> ratings,
    final int xpEarned,
  }) = _$ReviewSessionModelImpl;

  factory _ReviewSessionModel.fromJson(Map<String, dynamic> json) =
      _$ReviewSessionModelImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get topicId;
  @override
  String get topicName;
  @override
  String get domainId;
  @override
  @_TimestampConverter()
  DateTime get startedAt;
  @override
  @_NullableTimestampConverter()
  DateTime? get completedAt;
  @override
  int get durationSeconds;
  @override
  int get cardsReviewed;
  @override
  int get correctCount;
  @override
  int get incorrectCount;
  @override
  double get accuracy;
  @override
  Map<String, int> get ratings;
  @override
  int get xpEarned;

  /// Create a copy of ReviewSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewSessionModelImplCopyWith<_$ReviewSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
