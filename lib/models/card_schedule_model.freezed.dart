// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_schedule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CardScheduleModel _$CardScheduleModelFromJson(Map<String, dynamic> json) {
  return _CardScheduleModel.fromJson(json);
}

/// @nodoc
mixin _$CardScheduleModel {
  String get cardId => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  double get easeFactor => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get nextReviewDate => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get lastReviewDate => throw _privateConstructorUsedError;
  String get lastRating => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  int get correctCount => throw _privateConstructorUsedError;
  int get incorrectCount => throw _privateConstructorUsedError;

  /// Serializes this CardScheduleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardScheduleModelCopyWith<CardScheduleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardScheduleModelCopyWith<$Res> {
  factory $CardScheduleModelCopyWith(
    CardScheduleModel value,
    $Res Function(CardScheduleModel) then,
  ) = _$CardScheduleModelCopyWithImpl<$Res, CardScheduleModel>;
  @useResult
  $Res call({
    String cardId,
    String topicId,
    String domainId,
    double easeFactor,
    int interval,
    int repetitions,
    @_TimestampConverter() DateTime nextReviewDate,
    @_NullableTimestampConverter() DateTime? lastReviewDate,
    String lastRating,
    int totalReviews,
    int correctCount,
    int incorrectCount,
  });
}

/// @nodoc
class _$CardScheduleModelCopyWithImpl<$Res, $Val extends CardScheduleModel>
    implements $CardScheduleModelCopyWith<$Res> {
  _$CardScheduleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? topicId = null,
    Object? domainId = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
    Object? nextReviewDate = null,
    Object? lastReviewDate = freezed,
    Object? lastRating = null,
    Object? totalReviews = null,
    Object? correctCount = null,
    Object? incorrectCount = null,
  }) {
    return _then(
      _value.copyWith(
            cardId: null == cardId
                ? _value.cardId
                : cardId // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            easeFactor: null == easeFactor
                ? _value.easeFactor
                : easeFactor // ignore: cast_nullable_to_non_nullable
                      as double,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            repetitions: null == repetitions
                ? _value.repetitions
                : repetitions // ignore: cast_nullable_to_non_nullable
                      as int,
            nextReviewDate: null == nextReviewDate
                ? _value.nextReviewDate
                : nextReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastReviewDate: freezed == lastReviewDate
                ? _value.lastReviewDate
                : lastReviewDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastRating: null == lastRating
                ? _value.lastRating
                : lastRating // ignore: cast_nullable_to_non_nullable
                      as String,
            totalReviews: null == totalReviews
                ? _value.totalReviews
                : totalReviews // ignore: cast_nullable_to_non_nullable
                      as int,
            correctCount: null == correctCount
                ? _value.correctCount
                : correctCount // ignore: cast_nullable_to_non_nullable
                      as int,
            incorrectCount: null == incorrectCount
                ? _value.incorrectCount
                : incorrectCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardScheduleModelImplCopyWith<$Res>
    implements $CardScheduleModelCopyWith<$Res> {
  factory _$$CardScheduleModelImplCopyWith(
    _$CardScheduleModelImpl value,
    $Res Function(_$CardScheduleModelImpl) then,
  ) = __$$CardScheduleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String cardId,
    String topicId,
    String domainId,
    double easeFactor,
    int interval,
    int repetitions,
    @_TimestampConverter() DateTime nextReviewDate,
    @_NullableTimestampConverter() DateTime? lastReviewDate,
    String lastRating,
    int totalReviews,
    int correctCount,
    int incorrectCount,
  });
}

/// @nodoc
class __$$CardScheduleModelImplCopyWithImpl<$Res>
    extends _$CardScheduleModelCopyWithImpl<$Res, _$CardScheduleModelImpl>
    implements _$$CardScheduleModelImplCopyWith<$Res> {
  __$$CardScheduleModelImplCopyWithImpl(
    _$CardScheduleModelImpl _value,
    $Res Function(_$CardScheduleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cardId = null,
    Object? topicId = null,
    Object? domainId = null,
    Object? easeFactor = null,
    Object? interval = null,
    Object? repetitions = null,
    Object? nextReviewDate = null,
    Object? lastReviewDate = freezed,
    Object? lastRating = null,
    Object? totalReviews = null,
    Object? correctCount = null,
    Object? incorrectCount = null,
  }) {
    return _then(
      _$CardScheduleModelImpl(
        cardId: null == cardId
            ? _value.cardId
            : cardId // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        easeFactor: null == easeFactor
            ? _value.easeFactor
            : easeFactor // ignore: cast_nullable_to_non_nullable
                  as double,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        repetitions: null == repetitions
            ? _value.repetitions
            : repetitions // ignore: cast_nullable_to_non_nullable
                  as int,
        nextReviewDate: null == nextReviewDate
            ? _value.nextReviewDate
            : nextReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastReviewDate: freezed == lastReviewDate
            ? _value.lastReviewDate
            : lastReviewDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastRating: null == lastRating
            ? _value.lastRating
            : lastRating // ignore: cast_nullable_to_non_nullable
                  as String,
        totalReviews: null == totalReviews
            ? _value.totalReviews
            : totalReviews // ignore: cast_nullable_to_non_nullable
                  as int,
        correctCount: null == correctCount
            ? _value.correctCount
            : correctCount // ignore: cast_nullable_to_non_nullable
                  as int,
        incorrectCount: null == incorrectCount
            ? _value.incorrectCount
            : incorrectCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardScheduleModelImpl implements _CardScheduleModel {
  const _$CardScheduleModelImpl({
    required this.cardId,
    required this.topicId,
    this.domainId = '',
    this.easeFactor = 2.5,
    this.interval = 1,
    this.repetitions = 0,
    @_TimestampConverter() required this.nextReviewDate,
    @_NullableTimestampConverter() this.lastReviewDate,
    this.lastRating = '',
    this.totalReviews = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
  });

  factory _$CardScheduleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardScheduleModelImplFromJson(json);

  @override
  final String cardId;
  @override
  final String topicId;
  @override
  @JsonKey()
  final String domainId;
  @override
  @JsonKey()
  final double easeFactor;
  @override
  @JsonKey()
  final int interval;
  @override
  @JsonKey()
  final int repetitions;
  @override
  @_TimestampConverter()
  final DateTime nextReviewDate;
  @override
  @_NullableTimestampConverter()
  final DateTime? lastReviewDate;
  @override
  @JsonKey()
  final String lastRating;
  @override
  @JsonKey()
  final int totalReviews;
  @override
  @JsonKey()
  final int correctCount;
  @override
  @JsonKey()
  final int incorrectCount;

  @override
  String toString() {
    return 'CardScheduleModel(cardId: $cardId, topicId: $topicId, domainId: $domainId, easeFactor: $easeFactor, interval: $interval, repetitions: $repetitions, nextReviewDate: $nextReviewDate, lastReviewDate: $lastReviewDate, lastRating: $lastRating, totalReviews: $totalReviews, correctCount: $correctCount, incorrectCount: $incorrectCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardScheduleModelImpl &&
            (identical(other.cardId, cardId) || other.cardId == cardId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.easeFactor, easeFactor) ||
                other.easeFactor == easeFactor) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.nextReviewDate, nextReviewDate) ||
                other.nextReviewDate == nextReviewDate) &&
            (identical(other.lastReviewDate, lastReviewDate) ||
                other.lastReviewDate == lastReviewDate) &&
            (identical(other.lastRating, lastRating) ||
                other.lastRating == lastRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            (identical(other.correctCount, correctCount) ||
                other.correctCount == correctCount) &&
            (identical(other.incorrectCount, incorrectCount) ||
                other.incorrectCount == incorrectCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cardId,
    topicId,
    domainId,
    easeFactor,
    interval,
    repetitions,
    nextReviewDate,
    lastReviewDate,
    lastRating,
    totalReviews,
    correctCount,
    incorrectCount,
  );

  /// Create a copy of CardScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardScheduleModelImplCopyWith<_$CardScheduleModelImpl> get copyWith =>
      __$$CardScheduleModelImplCopyWithImpl<_$CardScheduleModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CardScheduleModelImplToJson(this);
  }
}

abstract class _CardScheduleModel implements CardScheduleModel {
  const factory _CardScheduleModel({
    required final String cardId,
    required final String topicId,
    final String domainId,
    final double easeFactor,
    final int interval,
    final int repetitions,
    @_TimestampConverter() required final DateTime nextReviewDate,
    @_NullableTimestampConverter() final DateTime? lastReviewDate,
    final String lastRating,
    final int totalReviews,
    final int correctCount,
    final int incorrectCount,
  }) = _$CardScheduleModelImpl;

  factory _CardScheduleModel.fromJson(Map<String, dynamic> json) =
      _$CardScheduleModelImpl.fromJson;

  @override
  String get cardId;
  @override
  String get topicId;
  @override
  String get domainId;
  @override
  double get easeFactor;
  @override
  int get interval;
  @override
  int get repetitions;
  @override
  @_TimestampConverter()
  DateTime get nextReviewDate;
  @override
  @_NullableTimestampConverter()
  DateTime? get lastReviewDate;
  @override
  String get lastRating;
  @override
  int get totalReviews;
  @override
  int get correctCount;
  @override
  int get incorrectCount;

  /// Create a copy of CardScheduleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardScheduleModelImplCopyWith<_$CardScheduleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
