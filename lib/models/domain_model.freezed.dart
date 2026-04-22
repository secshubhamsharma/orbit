// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'domain_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DomainModel _$DomainModelFromJson(Map<String, dynamic> json) {
  return _DomainModel.fromJson(json);
}

/// @nodoc
mixin _$DomainModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  List<String> get subDomains => throw _privateConstructorUsedError;
  int get totalTopics => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this DomainModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DomainModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DomainModelCopyWith<DomainModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DomainModelCopyWith<$Res> {
  factory $DomainModelCopyWith(
    DomainModel value,
    $Res Function(DomainModel) then,
  ) = _$DomainModelCopyWithImpl<$Res, DomainModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconUrl,
    String colorHex,
    List<String> subDomains,
    int totalTopics,
    int order,
  });
}

/// @nodoc
class _$DomainModelCopyWithImpl<$Res, $Val extends DomainModel>
    implements $DomainModelCopyWith<$Res> {
  _$DomainModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DomainModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconUrl = null,
    Object? colorHex = null,
    Object? subDomains = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            iconUrl: null == iconUrl
                ? _value.iconUrl
                : iconUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            subDomains: null == subDomains
                ? _value.subDomains
                : subDomains // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$DomainModelImplCopyWith<$Res>
    implements $DomainModelCopyWith<$Res> {
  factory _$$DomainModelImplCopyWith(
    _$DomainModelImpl value,
    $Res Function(_$DomainModelImpl) then,
  ) = __$$DomainModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String iconUrl,
    String colorHex,
    List<String> subDomains,
    int totalTopics,
    int order,
  });
}

/// @nodoc
class __$$DomainModelImplCopyWithImpl<$Res>
    extends _$DomainModelCopyWithImpl<$Res, _$DomainModelImpl>
    implements _$$DomainModelImplCopyWith<$Res> {
  __$$DomainModelImplCopyWithImpl(
    _$DomainModelImpl _value,
    $Res Function(_$DomainModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DomainModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? iconUrl = null,
    Object? colorHex = null,
    Object? subDomains = null,
    Object? totalTopics = null,
    Object? order = null,
  }) {
    return _then(
      _$DomainModelImpl(
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
        iconUrl: null == iconUrl
            ? _value.iconUrl
            : iconUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        subDomains: null == subDomains
            ? _value._subDomains
            : subDomains // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$DomainModelImpl implements _DomainModel {
  const _$DomainModelImpl({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl = '',
    this.colorHex = '#7C6FE8',
    final List<String> subDomains = const [],
    this.totalTopics = 0,
    this.order = 0,
  }) : _subDomains = subDomains;

  factory _$DomainModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DomainModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final String iconUrl;
  @override
  @JsonKey()
  final String colorHex;
  final List<String> _subDomains;
  @override
  @JsonKey()
  List<String> get subDomains {
    if (_subDomains is EqualUnmodifiableListView) return _subDomains;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subDomains);
  }

  @override
  @JsonKey()
  final int totalTopics;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'DomainModel(id: $id, name: $name, description: $description, iconUrl: $iconUrl, colorHex: $colorHex, subDomains: $subDomains, totalTopics: $totalTopics, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DomainModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            const DeepCollectionEquality().equals(
              other._subDomains,
              _subDomains,
            ) &&
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
    description,
    iconUrl,
    colorHex,
    const DeepCollectionEquality().hash(_subDomains),
    totalTopics,
    order,
  );

  /// Create a copy of DomainModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DomainModelImplCopyWith<_$DomainModelImpl> get copyWith =>
      __$$DomainModelImplCopyWithImpl<_$DomainModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DomainModelImplToJson(this);
  }
}

abstract class _DomainModel implements DomainModel {
  const factory _DomainModel({
    required final String id,
    required final String name,
    required final String description,
    final String iconUrl,
    final String colorHex,
    final List<String> subDomains,
    final int totalTopics,
    final int order,
  }) = _$DomainModelImpl;

  factory _DomainModel.fromJson(Map<String, dynamic> json) =
      _$DomainModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get iconUrl;
  @override
  String get colorHex;
  @override
  List<String> get subDomains;
  @override
  int get totalTopics;
  @override
  int get order;

  /// Create a copy of DomainModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DomainModelImplCopyWith<_$DomainModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
