// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubjectModel _$SubjectModelFromJson(Map<String, dynamic> json) {
  return _SubjectModel.fromJson(json);
}

/// @nodoc
mixin _$SubjectModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  List<String> get applicableExams => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  int get totalTopics => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this SubjectModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectModelCopyWith<SubjectModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectModelCopyWith<$Res> {
  factory $SubjectModelCopyWith(
    SubjectModel value,
    $Res Function(SubjectModel) then,
  ) = _$SubjectModelCopyWithImpl<$Res, SubjectModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String domainId,
    List<String> applicableExams,
    String iconUrl,
    int totalTopics,
    int order,
  });
}

/// @nodoc
class _$SubjectModelCopyWithImpl<$Res, $Val extends SubjectModel>
    implements $SubjectModelCopyWith<$Res> {
  _$SubjectModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? domainId = null,
    Object? applicableExams = null,
    Object? iconUrl = null,
    Object? totalTopics = null,
    Object? order = null,
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
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            applicableExams: null == applicableExams
                ? _value.applicableExams
                : applicableExams // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            iconUrl: null == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            totalTopics: null == totalTopics
                ? _value.totalTopics
                : totalTopics // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$SubjectModelImplCopyWith<$Res>
    implements $SubjectModelCopyWith<$Res> {
  factory _$$SubjectModelImplCopyWith(
    _$SubjectModelImpl value,
    $Res Function(_$SubjectModelImpl) then,
  ) = __$$SubjectModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String domainId,
    List<String> applicableExams,
    String iconUrl,
    int totalTopics,
    int order,
  });
}

/// @nodoc
class __$$SubjectModelImplCopyWithImpl<$Res>
    extends _$SubjectModelCopyWithImpl<$Res, _$SubjectModelImpl>
    implements _$$SubjectModelImplCopyWith<$Res> {
  __$$SubjectModelImplCopyWithImpl(
    _$SubjectModelImpl _value,
    $Res Function(_$SubjectModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? domainId = null,
    Object? applicableExams = null,
    Object? iconUrl = null,
    Object? totalTopics = null,
    Object? order = null,
  }) {
    return _then(
      _$SubjectModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        applicableExams: null == applicableExams
            ? _value._applicableExams
            : applicableExams // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        iconUrl: null == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        totalTopics: null == totalTopics
            ? _value.totalTopics
            : totalTopics // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$SubjectModelImpl implements _SubjectModel {
  const _$SubjectModelImpl({
    required this.id,
    required this.name,
    required this.domainId,
    final List<String> applicableExams = const [],
    this.iconUrl = '',
    this.totalTopics = 0,
    this.order = 0,
  }) : _applicableExams = applicableExams;

  factory _$SubjectModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String domainId;
  final List<String> _applicableExams;
  @override
  @JsonKey()
  List<String> get applicableExams {
    if (_applicableExams is EqualUnmodifiableListView) return _applicableExams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicableExams);
  }

  @override
  @JsonKey()
  final String iconUrl;
  @override
  @JsonKey()
  final int totalTopics;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'SubjectModel(id: $id, name: $name, domainId: $domainId, applicableExams: $applicableExams, iconUrl: $iconUrl, totalTopics: $totalTopics, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            const DeepCollectionEquality().equals(
              other._applicableExams,
              _applicableExams,
            ) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.totalTopics, totalTopics) ||
                other.totalTopics == totalTopics) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    domainId,
    const DeepCollectionEquality().hash(_applicableExams),
    iconUrl,
    totalTopics,
    order,
  );

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectModelImplCopyWith<_$SubjectModelImpl> get copyWith =>
      __$$SubjectModelImplCopyWithImpl<_$SubjectModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectModelImplToJson(this);
  }
}

abstract class _SubjectModel implements SubjectModel {
  const factory _SubjectModel({
    required final String id,
    required final String name,
    required final String domainId,
    final List<String> applicableExams,
    final String iconUrl,
    final int totalTopics,
    final int order,
  }) = _$SubjectModelImpl;

  factory _SubjectModel.fromJson(Map<String, dynamic> json) =
      _$SubjectModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get domainId;
  @override
  List<String> get applicableExams;
  @override
  String get iconUrl;
  @override
  int get totalTopics;
  @override
  int get order;

  /// Create a copy of SubjectModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectModelImplCopyWith<_$SubjectModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
