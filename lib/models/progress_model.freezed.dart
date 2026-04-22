// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) {
  return _ProgressModel.fromJson(json);
}

/// @nodoc
mixin _$ProgressModel {
  String get topicId => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get firstStudied => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get lastStudied => throw _privateConstructorUsedError;
  int get totalSessions => throw _privateConstructorUsedError;
  int get totalCardsReviewed => throw _privateConstructorUsedError;
  int get totalCorrect => throw _privateConstructorUsedError;
  int get totalIncorrect => throw _privateConstructorUsedError;
  double get accuracy => throw _privateConstructorUsedError;
  double get masteryPercent => throw _privateConstructorUsedError;
  String get masteryLevel => throw _privateConstructorUsedError;
  List<String> get weakSubTopics => throw _privateConstructorUsedError;
  int get totalStudyMinutes => throw _privateConstructorUsedError;
  int get cardsDue => throw _privateConstructorUsedError;
  int get cardsNew => throw _privateConstructorUsedError;
  int get cardsMastered => throw _privateConstructorUsedError;

  /// Serializes this ProgressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressModelCopyWith<ProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressModelCopyWith<$Res> {
  factory $ProgressModelCopyWith(
    ProgressModel value,
    $Res Function(ProgressModel) then,
  ) = _$ProgressModelCopyWithImpl<$Res, ProgressModel>;
  @useResult
  $Res call({
    String topicId,
    String topicName,
    String domainId,
    @_NullableTimestampConverter() DateTime? firstStudied,
    @_NullableTimestampConverter() DateTime? lastStudied,
    int totalSessions,
    int totalCardsReviewed,
    int totalCorrect,
    int totalIncorrect,
    double accuracy,
    double masteryPercent,
    String masteryLevel,
    List<String> weakSubTopics,
    int totalStudyMinutes,
    int cardsDue,
    int cardsNew,
    int cardsMastered,
  });
}

/// @nodoc
class _$ProgressModelCopyWithImpl<$Res, $Val extends ProgressModel>
    implements $ProgressModelCopyWith<$Res> {
  _$ProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = null,
    Object? topicName = null,
    Object? domainId = null,
    Object? firstStudied = freezed,
    Object? lastStudied = freezed,
    Object? totalSessions = null,
    Object? totalCardsReviewed = null,
    Object? totalCorrect = null,
    Object? totalIncorrect = null,
    Object? accuracy = null,
    Object? masteryPercent = null,
    Object? masteryLevel = null,
    Object? weakSubTopics = null,
    Object? totalStudyMinutes = null,
    Object? cardsDue = null,
    Object? cardsNew = null,
    Object? cardsMastered = null,
  }) {
    return _then(
      _value.copyWith(
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
            firstStudied: freezed == firstStudied
                ? _value.firstStudied
                : firstStudied // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastStudied: freezed == lastStudied
                ? _value.lastStudied
                : lastStudied // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalSessions: null == totalSessions
                ? _value.totalSessions
                : totalSessions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCardsReviewed: null == totalCardsReviewed
                ? _value.totalCardsReviewed
                : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCorrect: null == totalCorrect
                ? _value.totalCorrect
                : totalCorrect // ignore: cast_nullable_to_non_nullable
                      as int,
            totalIncorrect: null == totalIncorrect
                ? _value.totalIncorrect
                : totalIncorrect // ignore: cast_nullable_to_non_nullable
                      as int,
            accuracy: null == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            masteryPercent: null == masteryPercent
                ? _value.masteryPercent
                : masteryPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            masteryLevel: null == masteryLevel
                ? _value.masteryLevel
                : masteryLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            weakSubTopics: null == weakSubTopics
                ? _value.weakSubTopics
                : weakSubTopics // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            totalStudyMinutes: null == totalStudyMinutes
                ? _value.totalStudyMinutes
                : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            cardsDue: null == cardsDue
                ? _value.cardsDue
                : cardsDue // ignore: cast_nullable_to_non_nullable
                      as int,
            cardsNew: null == cardsNew
                ? _value.cardsNew
                : cardsNew // ignore: cast_nullable_to_non_nullable
                      as int,
            cardsMastered: null == cardsMastered
                ? _value.cardsMastered
                : cardsMastered // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressModelImplCopyWith<$Res>
    implements $ProgressModelCopyWith<$Res> {
  factory _$$ProgressModelImplCopyWith(
    _$ProgressModelImpl value,
    $Res Function(_$ProgressModelImpl) then,
  ) = __$$ProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topicId,
    String topicName,
    String domainId,
    @_NullableTimestampConverter() DateTime? firstStudied,
    @_NullableTimestampConverter() DateTime? lastStudied,
    int totalSessions,
    int totalCardsReviewed,
    int totalCorrect,
    int totalIncorrect,
    double accuracy,
    double masteryPercent,
    String masteryLevel,
    List<String> weakSubTopics,
    int totalStudyMinutes,
    int cardsDue,
    int cardsNew,
    int cardsMastered,
  });
}

/// @nodoc
class __$$ProgressModelImplCopyWithImpl<$Res>
    extends _$ProgressModelCopyWithImpl<$Res, _$ProgressModelImpl>
    implements _$$ProgressModelImplCopyWith<$Res> {
  __$$ProgressModelImplCopyWithImpl(
    _$ProgressModelImpl _value,
    $Res Function(_$ProgressModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topicId = null,
    Object? topicName = null,
    Object? domainId = null,
    Object? firstStudied = freezed,
    Object? lastStudied = freezed,
    Object? totalSessions = null,
    Object? totalCardsReviewed = null,
    Object? totalCorrect = null,
    Object? totalIncorrect = null,
    Object? accuracy = null,
    Object? masteryPercent = null,
    Object? masteryLevel = null,
    Object? weakSubTopics = null,
    Object? totalStudyMinutes = null,
    Object? cardsDue = null,
    Object? cardsNew = null,
    Object? cardsMastered = null,
  }) {
    return _then(
      _$ProgressModelImpl(
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
        firstStudied: freezed == firstStudied
            ? _value.firstStudied
            : firstStudied // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastStudied: freezed == lastStudied
            ? _value.lastStudied
            : lastStudied // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalSessions: null == totalSessions
            ? _value.totalSessions
            : totalSessions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCardsReviewed: null == totalCardsReviewed
            ? _value.totalCardsReviewed
            : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCorrect: null == totalCorrect
            ? _value.totalCorrect
            : totalCorrect // ignore: cast_nullable_to_non_nullable
                  as int,
        totalIncorrect: null == totalIncorrect
            ? _value.totalIncorrect
            : totalIncorrect // ignore: cast_nullable_to_non_nullable
                  as int,
        accuracy: null == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        masteryPercent: null == masteryPercent
            ? _value.masteryPercent
            : masteryPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        masteryLevel: null == masteryLevel
            ? _value.masteryLevel
            : masteryLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        weakSubTopics: null == weakSubTopics
            ? _value._weakSubTopics
            : weakSubTopics // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        totalStudyMinutes: null == totalStudyMinutes
            ? _value.totalStudyMinutes
            : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsDue: null == cardsDue
            ? _value.cardsDue
            : cardsDue // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsNew: null == cardsNew
            ? _value.cardsNew
            : cardsNew // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsMastered: null == cardsMastered
            ? _value.cardsMastered
            : cardsMastered // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressModelImpl implements _ProgressModel {
  const _$ProgressModelImpl({
    required this.topicId,
    this.topicName = '',
    this.domainId = '',
    @_NullableTimestampConverter() this.firstStudied,
    @_NullableTimestampConverter() this.lastStudied,
    this.totalSessions = 0,
    this.totalCardsReviewed = 0,
    this.totalCorrect = 0,
    this.totalIncorrect = 0,
    this.accuracy = 0.0,
    this.masteryPercent = 0.0,
    this.masteryLevel = 'learning',
    final List<String> weakSubTopics = const [],
    this.totalStudyMinutes = 0,
    this.cardsDue = 0,
    this.cardsNew = 0,
    this.cardsMastered = 0,
  }) : _weakSubTopics = weakSubTopics;

  factory _$ProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressModelImplFromJson(json);

  @override
  final String topicId;
  @override
  @JsonKey()
  final String topicName;
  @override
  @JsonKey()
  final String domainId;
  @override
  @_NullableTimestampConverter()
  final DateTime? firstStudied;
  @override
  @_NullableTimestampConverter()
  final DateTime? lastStudied;
  @override
  @JsonKey()
  final int totalSessions;
  @override
  @JsonKey()
  final int totalCardsReviewed;
  @override
  @JsonKey()
  final int totalCorrect;
  @override
  @JsonKey()
  final int totalIncorrect;
  @override
  @JsonKey()
  final double accuracy;
  @override
  @JsonKey()
  final double masteryPercent;
  @override
  @JsonKey()
  final String masteryLevel;
  final List<String> _weakSubTopics;
  @override
  @JsonKey()
  List<String> get weakSubTopics {
    if (_weakSubTopics is EqualUnmodifiableListView) return _weakSubTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weakSubTopics);
  }

  @override
  @JsonKey()
  final int totalStudyMinutes;
  @override
  @JsonKey()
  final int cardsDue;
  @override
  @JsonKey()
  final int cardsNew;
  @override
  @JsonKey()
  final int cardsMastered;

  @override
  String toString() {
    return 'ProgressModel(topicId: $topicId, topicName: $topicName, domainId: $domainId, firstStudied: $firstStudied, lastStudied: $lastStudied, totalSessions: $totalSessions, totalCardsReviewed: $totalCardsReviewed, totalCorrect: $totalCorrect, totalIncorrect: $totalIncorrect, accuracy: $accuracy, masteryPercent: $masteryPercent, masteryLevel: $masteryLevel, weakSubTopics: $weakSubTopics, totalStudyMinutes: $totalStudyMinutes, cardsDue: $cardsDue, cardsNew: $cardsNew, cardsMastered: $cardsMastered)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressModelImpl &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.firstStudied, firstStudied) ||
                other.firstStudied == firstStudied) &&
            (identical(other.lastStudied, lastStudied) ||
                other.lastStudied == lastStudied) &&
            (identical(other.totalSessions, totalSessions) ||
                other.totalSessions == totalSessions) &&
            (identical(other.totalCardsReviewed, totalCardsReviewed) ||
                other.totalCardsReviewed == totalCardsReviewed) &&
            (identical(other.totalCorrect, totalCorrect) ||
                other.totalCorrect == totalCorrect) &&
            (identical(other.totalIncorrect, totalIncorrect) ||
                other.totalIncorrect == totalIncorrect) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.masteryPercent, masteryPercent) ||
                other.masteryPercent == masteryPercent) &&
            (identical(other.masteryLevel, masteryLevel) ||
                other.masteryLevel == masteryLevel) &&
            const DeepCollectionEquality().equals(
              other._weakSubTopics,
              _weakSubTopics,
            ) &&
            (identical(other.totalStudyMinutes, totalStudyMinutes) ||
                other.totalStudyMinutes == totalStudyMinutes) &&
            (identical(other.cardsDue, cardsDue) ||
                other.cardsDue == cardsDue) &&
            (identical(other.cardsNew, cardsNew) ||
                other.cardsNew == cardsNew) &&
            (identical(other.cardsMastered, cardsMastered) ||
                other.cardsMastered == cardsMastered));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    topicId,
    topicName,
    domainId,
    firstStudied,
    lastStudied,
    totalSessions,
    totalCardsReviewed,
    totalCorrect,
    totalIncorrect,
    accuracy,
    masteryPercent,
    masteryLevel,
    const DeepCollectionEquality().hash(_weakSubTopics),
    totalStudyMinutes,
    cardsDue,
    cardsNew,
    cardsMastered,
  );

  /// Create a copy of ProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressModelImplCopyWith<_$ProgressModelImpl> get copyWith =>
      __$$ProgressModelImplCopyWithImpl<_$ProgressModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressModelImplToJson(this);
  }
}

abstract class _ProgressModel implements ProgressModel {
  const factory _ProgressModel({
    required final String topicId,
    final String topicName,
    final String domainId,
    @_NullableTimestampConverter() final DateTime? firstStudied,
    @_NullableTimestampConverter() final DateTime? lastStudied,
    final int totalSessions,
    final int totalCardsReviewed,
    final int totalCorrect,
    final int totalIncorrect,
    final double accuracy,
    final double masteryPercent,
    final String masteryLevel,
    final List<String> weakSubTopics,
    final int totalStudyMinutes,
    final int cardsDue,
    final int cardsNew,
    final int cardsMastered,
  }) = _$ProgressModelImpl;

  factory _ProgressModel.fromJson(Map<String, dynamic> json) =
      _$ProgressModelImpl.fromJson;

  @override
  String get topicId;
  @override
  String get topicName;
  @override
  String get domainId;
  @override
  @_NullableTimestampConverter()
  DateTime? get firstStudied;
  @override
  @_NullableTimestampConverter()
  DateTime? get lastStudied;
  @override
  int get totalSessions;
  @override
  int get totalCardsReviewed;
  @override
  int get totalCorrect;
  @override
  int get totalIncorrect;
  @override
  double get accuracy;
  @override
  double get masteryPercent;
  @override
  String get masteryLevel;
  @override
  List<String> get weakSubTopics;
  @override
  int get totalStudyMinutes;
  @override
  int get cardsDue;
  @override
  int get cardsNew;
  @override
  int get cardsMastered;

  /// Create a copy of ProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressModelImplCopyWith<_$ProgressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
