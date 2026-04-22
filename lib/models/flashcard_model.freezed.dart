// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flashcard_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlashcardModel _$FlashcardModelFromJson(Map<String, dynamic> json) {
  return _FlashcardModel.fromJson(json);
}

/// @nodoc
mixin _$FlashcardModel {
  String get id => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get front => throw _privateConstructorUsedError;
  String get back => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int? get correctOption => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get generatedByAI => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this FlashcardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlashcardModelCopyWith<FlashcardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlashcardModelCopyWith<$Res> {
  factory $FlashcardModelCopyWith(
    FlashcardModel value,
    $Res Function(FlashcardModel) then,
  ) = _$FlashcardModelCopyWithImpl<$Res, FlashcardModel>;
  @useResult
  $Res call({
    String id,
    String topicId,
    String type,
    String front,
    String back,
    List<String> options,
    int? correctOption,
    String? explanation,
    String difficulty,
    List<String> tags,
    @_TimestampConverter() DateTime createdAt,
    bool generatedByAI,
    int order,
  });
}

/// @nodoc
class _$FlashcardModelCopyWithImpl<$Res, $Val extends FlashcardModel>
    implements $FlashcardModelCopyWith<$Res> {
  _$FlashcardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? type = null,
    Object? front = null,
    Object? back = null,
    Object? options = null,
    Object? correctOption = freezed,
    Object? explanation = freezed,
    Object? difficulty = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? generatedByAI = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            front: null == front
                ? _value.front
                : front // ignore: cast_nullable_to_non_nullable
                      as String,
            back: null == back
                ? _value.back
                : back // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctOption: freezed == correctOption
                ? _value.correctOption
                : correctOption // ignore: cast_nullable_to_non_nullable
                      as int?,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            generatedByAI: null == generatedByAI
                ? _value.generatedByAI
                : generatedByAI // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlashcardModelImplCopyWith<$Res>
    implements $FlashcardModelCopyWith<$Res> {
  factory _$$FlashcardModelImplCopyWith(
    _$FlashcardModelImpl value,
    $Res Function(_$FlashcardModelImpl) then,
  ) = __$$FlashcardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String topicId,
    String type,
    String front,
    String back,
    List<String> options,
    int? correctOption,
    String? explanation,
    String difficulty,
    List<String> tags,
    @_TimestampConverter() DateTime createdAt,
    bool generatedByAI,
    int order,
  });
}

/// @nodoc
class __$$FlashcardModelImplCopyWithImpl<$Res>
    extends _$FlashcardModelCopyWithImpl<$Res, _$FlashcardModelImpl>
    implements _$$FlashcardModelImplCopyWith<$Res> {
  __$$FlashcardModelImplCopyWithImpl(
    _$FlashcardModelImpl _value,
    $Res Function(_$FlashcardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? type = null,
    Object? front = null,
    Object? back = null,
    Object? options = null,
    Object? correctOption = freezed,
    Object? explanation = freezed,
    Object? difficulty = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? generatedByAI = null,
    Object? order = null,
  }) {
    return _then(
      _$FlashcardModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        front: null == front
            ? _value.front
            : front // ignore: cast_nullable_to_non_nullable
                  as String,
        back: null == back
            ? _value.back
            : back // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctOption: freezed == correctOption
            ? _value.correctOption
            : correctOption // ignore: cast_nullable_to_non_nullable
                  as int?,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        generatedByAI: null == generatedByAI
            ? _value.generatedByAI
            : generatedByAI // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlashcardModelImpl implements _FlashcardModel {
  const _$FlashcardModelImpl({
    required this.id,
    required this.topicId,
    this.type = 'flashcard',
    required this.front,
    required this.back,
    final List<String> options = const [],
    this.correctOption,
    this.explanation,
    this.difficulty = 'medium',
    final List<String> tags = const [],
    @_TimestampConverter() required this.createdAt,
    this.generatedByAI = true,
    this.order = 0,
  }) : _options = options,
       _tags = tags;

  factory _$FlashcardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlashcardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String topicId;
  @override
  @JsonKey()
  final String type;
  @override
  final String front;
  @override
  final String back;
  final List<String> _options;
  @override
  @JsonKey()
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int? correctOption;
  @override
  final String? explanation;
  @override
  @JsonKey()
  final String difficulty;
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
  @JsonKey()
  final bool generatedByAI;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'FlashcardModel(id: $id, topicId: $topicId, type: $type, front: $front, back: $back, options: $options, correctOption: $correctOption, explanation: $explanation, difficulty: $difficulty, tags: $tags, createdAt: $createdAt, generatedByAI: $generatedByAI, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlashcardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.front, front) || other.front == front) &&
            (identical(other.back, back) || other.back == back) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctOption, correctOption) ||
                other.correctOption == correctOption) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.generatedByAI, generatedByAI) ||
                other.generatedByAI == generatedByAI) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    topicId,
    type,
    front,
    back,
    const DeepCollectionEquality().hash(_options),
    correctOption,
    explanation,
    difficulty,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    generatedByAI,
    order,
  );

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      __$$FlashcardModelImplCopyWithImpl<_$FlashcardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlashcardModelImplToJson(this);
  }
}

abstract class _FlashcardModel implements FlashcardModel {
  const factory _FlashcardModel({
    required final String id,
    required final String topicId,
    final String type,
    required final String front,
    required final String back,
    final List<String> options,
    final int? correctOption,
    final String? explanation,
    final String difficulty,
    final List<String> tags,
    @_TimestampConverter() required final DateTime createdAt,
    final bool generatedByAI,
    final int order,
  }) = _$FlashcardModelImpl;

  factory _FlashcardModel.fromJson(Map<String, dynamic> json) =
      _$FlashcardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get topicId;
  @override
  String get type;
  @override
  String get front;
  @override
  String get back;
  @override
  List<String> get options;
  @override
  int? get correctOption;
  @override
  String? get explanation;
  @override
  String get difficulty;
  @override
  List<String> get tags;
  @override
  @_TimestampConverter()
  DateTime get createdAt;
  @override
  bool get generatedByAI;
  @override
  int get order;

  /// Create a copy of FlashcardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlashcardModelImplCopyWith<_$FlashcardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
