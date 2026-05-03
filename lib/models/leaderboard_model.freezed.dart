// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaderboardEntryModel _$LeaderboardEntryModelFromJson(
  Map<String, dynamic> json,
) {
  return _LeaderboardEntryModel.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntryModel {
  String get userId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  int get totalCardsReviewed => throw _privateConstructorUsedError;
  double get overallAccuracy => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get rank =>
      throw _privateConstructorUsedError; // populated client-side after sorting
  double get score =>
      throw _privateConstructorUsedError; // totalCardsReviewed × overallAccuracy
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryModelCopyWith<LeaderboardEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryModelCopyWith<$Res> {
  factory $LeaderboardEntryModelCopyWith(
    LeaderboardEntryModel value,
    $Res Function(LeaderboardEntryModel) then,
  ) = _$LeaderboardEntryModelCopyWithImpl<$Res, LeaderboardEntryModel>;
  @useResult
  $Res call({
    String userId,
    String displayName,
    String? photoUrl,
    int totalCardsReviewed,
    double overallAccuracy,
    int currentStreak,
    int rank,
    double score,
    @NullableTimestampConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class _$LeaderboardEntryModelCopyWithImpl<
  $Res,
  $Val extends LeaderboardEntryModel
>
    implements $LeaderboardEntryModelCopyWith<$Res> {
  _$LeaderboardEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? totalCardsReviewed = null,
    Object? overallAccuracy = null,
    Object? currentStreak = null,
    Object? rank = null,
    Object? score = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalCardsReviewed: null == totalCardsReviewed
                ? _value.totalCardsReviewed
                : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                      as int,
            overallAccuracy: null == overallAccuracy
                ? _value.overallAccuracy
                : overallAccuracy // ignore: cast_nullable_to_non_nullable
                      as double,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryModelImplCopyWith<$Res>
    implements $LeaderboardEntryModelCopyWith<$Res> {
  factory _$$LeaderboardEntryModelImplCopyWith(
    _$LeaderboardEntryModelImpl value,
    $Res Function(_$LeaderboardEntryModelImpl) then,
  ) = __$$LeaderboardEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String displayName,
    String? photoUrl,
    int totalCardsReviewed,
    double overallAccuracy,
    int currentStreak,
    int rank,
    double score,
    @NullableTimestampConverter() DateTime? updatedAt,
  });
}

/// @nodoc
class __$$LeaderboardEntryModelImplCopyWithImpl<$Res>
    extends
        _$LeaderboardEntryModelCopyWithImpl<$Res, _$LeaderboardEntryModelImpl>
    implements _$$LeaderboardEntryModelImplCopyWith<$Res> {
  __$$LeaderboardEntryModelImplCopyWithImpl(
    _$LeaderboardEntryModelImpl _value,
    $Res Function(_$LeaderboardEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? totalCardsReviewed = null,
    Object? overallAccuracy = null,
    Object? currentStreak = null,
    Object? rank = null,
    Object? score = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$LeaderboardEntryModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalCardsReviewed: null == totalCardsReviewed
            ? _value.totalCardsReviewed
            : totalCardsReviewed // ignore: cast_nullable_to_non_nullable
                  as int,
        overallAccuracy: null == overallAccuracy
            ? _value.overallAccuracy
            : overallAccuracy // ignore: cast_nullable_to_non_nullable
                  as double,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryModelImpl implements _LeaderboardEntryModel {
  const _$LeaderboardEntryModelImpl({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.totalCardsReviewed = 0,
    this.overallAccuracy = 0.0,
    this.currentStreak = 0,
    this.rank = 0,
    this.score = 0.0,
    @NullableTimestampConverter() this.updatedAt,
  });

  factory _$LeaderboardEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryModelImplFromJson(json);

  @override
  final String userId;
  @override
  final String displayName;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final int totalCardsReviewed;
  @override
  @JsonKey()
  final double overallAccuracy;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int rank;
  // populated client-side after sorting
  @override
  @JsonKey()
  final double score;
  // totalCardsReviewed × overallAccuracy
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'LeaderboardEntryModel(userId: $userId, displayName: $displayName, photoUrl: $photoUrl, totalCardsReviewed: $totalCardsReviewed, overallAccuracy: $overallAccuracy, currentStreak: $currentStreak, rank: $rank, score: $score, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.totalCardsReviewed, totalCardsReviewed) ||
                other.totalCardsReviewed == totalCardsReviewed) &&
            (identical(other.overallAccuracy, overallAccuracy) ||
                other.overallAccuracy == overallAccuracy) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    displayName,
    photoUrl,
    totalCardsReviewed,
    overallAccuracy,
    currentStreak,
    rank,
    score,
    updatedAt,
  );

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryModelImplCopyWith<_$LeaderboardEntryModelImpl>
  get copyWith =>
      __$$LeaderboardEntryModelImplCopyWithImpl<_$LeaderboardEntryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryModelImplToJson(this);
  }
}

abstract class _LeaderboardEntryModel implements LeaderboardEntryModel {
  const factory _LeaderboardEntryModel({
    required final String userId,
    required final String displayName,
    final String? photoUrl,
    final int totalCardsReviewed,
    final double overallAccuracy,
    final int currentStreak,
    final int rank,
    final double score,
    @NullableTimestampConverter() final DateTime? updatedAt,
  }) = _$LeaderboardEntryModelImpl;

  factory _LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryModelImpl.fromJson;

  @override
  String get userId;
  @override
  String get displayName;
  @override
  String? get photoUrl;
  @override
  int get totalCardsReviewed;
  @override
  double get overallAccuracy;
  @override
  int get currentStreak;
  @override
  int get rank; // populated client-side after sorting
  @override
  double get score; // totalCardsReviewed × overallAccuracy
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryModelImplCopyWith<_$LeaderboardEntryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
