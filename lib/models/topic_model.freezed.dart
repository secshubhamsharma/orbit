// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopicModel _$TopicModelFromJson(Map<String, dynamic> json) {
  return _TopicModel.fromJson(json);
}

/// @nodoc
mixin _$TopicModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  int get totalCards => throw _privateConstructorUsedError;
  int get estimatedMinutes => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  bool get generatedByAI => throw _privateConstructorUsedError;

  /// Serializes this TopicModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicModelCopyWith<TopicModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicModelCopyWith<$Res> {
  factory $TopicModelCopyWith(
    TopicModel value,
    $Res Function(TopicModel) then,
  ) = _$TopicModelCopyWithImpl<$Res, TopicModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String subjectId,
    String domainId,
    String description,
    String difficulty,
    int totalCards,
    int estimatedMinutes,
    List<String> tags,
    @_TimestampConverter() DateTime createdAt,
    @_TimestampConverter() DateTime lastUpdated,
    bool generatedByAI,
  });
}

/// @nodoc
class _$TopicModelCopyWithImpl<$Res, $Val extends TopicModel>
    implements $TopicModelCopyWith<$Res> {
  _$TopicModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subjectId = null,
    Object? domainId = null,
    Object? description = null,
    Object? difficulty = null,
    Object? totalCards = null,
    Object? estimatedMinutes = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? lastUpdated = null,
    Object? generatedByAI = null,
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
            subjectId: null == subjectId
                ? _value.subjectId
                : subjectId // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            totalCards: null == totalCards
                ? _value.totalCards
                : totalCards // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedMinutes: null == estimatedMinutes
                ? _value.estimatedMinutes
                : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastUpdated: null == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            generatedByAI: null == generatedByAI
                ? _value.generatedByAI
                : generatedByAI // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicModelImplCopyWith<$Res>
    implements $TopicModelCopyWith<$Res> {
  factory _$$TopicModelImplCopyWith(
    _$TopicModelImpl value,
    $Res Function(_$TopicModelImpl) then,
  ) = __$$TopicModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String subjectId,
    String domainId,
    String description,
    String difficulty,
    int totalCards,
    int estimatedMinutes,
    List<String> tags,
    @_TimestampConverter() DateTime createdAt,
    @_TimestampConverter() DateTime lastUpdated,
    bool generatedByAI,
  });
}

/// @nodoc
class __$$TopicModelImplCopyWithImpl<$Res>
    extends _$TopicModelCopyWithImpl<$Res, _$TopicModelImpl>
    implements _$$TopicModelImplCopyWith<$Res> {
  __$$TopicModelImplCopyWithImpl(
    _$TopicModelImpl _value,
    $Res Function(_$TopicModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? subjectId = null,
    Object? domainId = null,
    Object? description = null,
    Object? difficulty = null,
    Object? totalCards = null,
    Object? estimatedMinutes = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? lastUpdated = null,
    Object? generatedByAI = null,
  }) {
    return _then(
      _$TopicModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectId: null == subjectId
            ? _value.subjectId
            : subjectId // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        totalCards: null == totalCards
            ? _value.totalCards
            : totalCards // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedMinutes: null == estimatedMinutes
            ? _value.estimatedMinutes
            : estimatedMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastUpdated: null == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        generatedByAI: null == generatedByAI
            ? _value.generatedByAI
            : generatedByAI // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicModelImpl implements _TopicModel {
  const _$TopicModelImpl({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.domainId,
    this.description = '',
    this.difficulty = 'beginner',
    this.totalCards = 0,
    this.estimatedMinutes = 10,
    final List<String> tags = const [],
    @_TimestampConverter() required this.createdAt,
    @_TimestampConverter() required this.lastUpdated,
    this.generatedByAI = true,
  }) : _tags = tags;

  factory _$TopicModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String subjectId;
  @override
  final String domainId;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String difficulty;
  @override
  @JsonKey()
  final int totalCards;
  @override
  @JsonKey()
  final int estimatedMinutes;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @_TimestampConverter()
  final DateTime createdAt;
  @override
  @_TimestampConverter()
  final DateTime lastUpdated;
  @override
  @JsonKey()
  final bool generatedByAI;

  @override
  String toString() {
    return 'TopicModel(id: $id, name: $name, subjectId: $subjectId, domainId: $domainId, description: $description, difficulty: $difficulty, totalCards: $totalCards, estimatedMinutes: $estimatedMinutes, tags: $tags, createdAt: $createdAt, lastUpdated: $lastUpdated, generatedByAI: $generatedByAI)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.totalCards, totalCards) ||
                other.totalCards == totalCards) &&
            (identical(other.estimatedMinutes, estimatedMinutes) ||
                other.estimatedMinutes == estimatedMinutes) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.generatedByAI, generatedByAI) ||
                other.generatedByAI == generatedByAI));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    subjectId,
    domainId,
    description,
    difficulty,
    totalCards,
    estimatedMinutes,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    lastUpdated,
    generatedByAI,
  );

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      __$$TopicModelImplCopyWithImpl<_$TopicModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicModelImplToJson(this);
  }
}

abstract class _TopicModel implements TopicModel {
  const factory _TopicModel({
    required final String id,
    required final String name,
    required final String subjectId,
    required final String domainId,
    final String description,
    final String difficulty,
    final int totalCards,
    final int estimatedMinutes,
    final List<String> tags,
    @_TimestampConverter() required final DateTime createdAt,
    @_TimestampConverter() required final DateTime lastUpdated,
    final bool generatedByAI,
  }) = _$TopicModelImpl;

  factory _TopicModel.fromJson(Map<String, dynamic> json) =
      _$TopicModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get subjectId;
  @override
  String get domainId;
  @override
  String get description;
  @override
  String get difficulty;
  @override
  int get totalCards;
  @override
  int get estimatedMinutes;
  @override
  List<String> get tags;
  @override
  @_TimestampConverter()
  DateTime get createdAt;
  @override
  @_TimestampConverter()
  DateTime get lastUpdated;
  @override
  bool get generatedByAI;

  /// Create a copy of TopicModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
