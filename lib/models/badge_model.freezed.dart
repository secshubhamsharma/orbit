// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BadgeModel _$BadgeModelFromJson(Map<String, dynamic> json) {
  return _BadgeModel.fromJson(json);
}

/// @nodoc
mixin _$BadgeModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconEmoji => throw _privateConstructorUsedError;
  String get condition => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get earnedAt => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  int get progressTarget => throw _privateConstructorUsedError;

  /// Serializes this BadgeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeModelCopyWith<BadgeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeModelCopyWith<$Res> {
  factory $BadgeModelCopyWith(
    BadgeModel value,
    $Res Function(BadgeModel) then,
  ) = _$BadgeModelCopyWithImpl<$Res, BadgeModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconEmoji,
    String condition,
    @_NullableTimestampConverter() DateTime? earnedAt,
    int progress,
    int progressTarget,
  });
}

/// @nodoc
class _$BadgeModelCopyWithImpl<$Res, $Val extends BadgeModel>
    implements $BadgeModelCopyWith<$Res> {
  _$BadgeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconEmoji = null,
    Object? condition = null,
    Object? earnedAt = freezed,
    Object? progress = null,
    Object? progressTarget = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconEmoji: null == iconEmoji
                ? _value.iconEmoji
                : iconEmoji // ignore: cast_nullable_to_non_nullable
                      as String,
            condition: null == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String,
            earnedAt: freezed == earnedAt
                ? _value.earnedAt
                : earnedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as int,
            progressTarget: null == progressTarget
                ? _value.progressTarget
                : progressTarget // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeModelImplCopyWith<$Res>
    implements $BadgeModelCopyWith<$Res> {
  factory _$$BadgeModelImplCopyWith(
    _$BadgeModelImpl value,
    $Res Function(_$BadgeModelImpl) then,
  ) = __$$BadgeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconEmoji,
    String condition,
    @_NullableTimestampConverter() DateTime? earnedAt,
    int progress,
    int progressTarget,
  });
}

/// @nodoc
class __$$BadgeModelImplCopyWithImpl<$Res>
    extends _$BadgeModelCopyWithImpl<$Res, _$BadgeModelImpl>
    implements _$$BadgeModelImplCopyWith<$Res> {
  __$$BadgeModelImplCopyWithImpl(
    _$BadgeModelImpl _value,
    $Res Function(_$BadgeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconEmoji = null,
    Object? condition = null,
    Object? earnedAt = freezed,
    Object? progress = null,
    Object? progressTarget = null,
  }) {
    return _then(
      _$BadgeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        iconEmoji: null == iconEmoji
            ? _value.iconEmoji
            : iconEmoji // ignore: cast_nullable_to_non_nullable
                  as String,
        condition: null == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String,
        earnedAt: freezed == earnedAt
            ? _value.earnedAt
            : earnedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as int,
        progressTarget: null == progressTarget
            ? _value.progressTarget
            : progressTarget // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeModelImpl extends _BadgeModel {
  const _$BadgeModelImpl({
    required this.id,
    required this.name,
    required this.description,
    this.iconEmoji = '🏆',
    required this.condition,
    @_NullableTimestampConverter() this.earnedAt,
    this.progress = 0,
    this.progressTarget = 0,
  }) : super._();

  factory _$BadgeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final String iconEmoji;
  @override
  final String condition;
  @override
  @_NullableTimestampConverter()
  final DateTime? earnedAt;
  @override
  @JsonKey()
  final int progress;
  @override
  @JsonKey()
  final int progressTarget;

  @override
  String toString() {
    return 'BadgeModel(id: $id, name: $name, description: $description, iconEmoji: $iconEmoji, condition: $condition, earnedAt: $earnedAt, progress: $progress, progressTarget: $progressTarget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconEmoji, iconEmoji) ||
                other.iconEmoji == iconEmoji) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.progressTarget, progressTarget) ||
                other.progressTarget == progressTarget));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    iconEmoji,
    condition,
    earnedAt,
    progress,
    progressTarget,
  );

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeModelImplCopyWith<_$BadgeModelImpl> get copyWith =>
      __$$BadgeModelImplCopyWithImpl<_$BadgeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeModelImplToJson(this);
  }
}

abstract class _BadgeModel extends BadgeModel {
  const factory _BadgeModel({
    required final String id,
    required final String name,
    required final String description,
    final String iconEmoji,
    required final String condition,
    @_NullableTimestampConverter() final DateTime? earnedAt,
    final int progress,
    final int progressTarget,
  }) = _$BadgeModelImpl;
  const _BadgeModel._() : super._();

  factory _BadgeModel.fromJson(Map<String, dynamic> json) =
      _$BadgeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get iconEmoji;
  @override
  String get condition;
  @override
  @_NullableTimestampConverter()
  DateTime? get earnedAt;
  @override
  int get progress;
  @override
  int get progressTarget;

  /// Create a copy of BadgeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeModelImplCopyWith<_$BadgeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
