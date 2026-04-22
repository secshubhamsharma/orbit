// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_upload_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfUploadModel _$PdfUploadModelFromJson(Map<String, dynamic> json) {
  return _PdfUploadModel.fromJson(json);
}

/// @nodoc
mixin _$PdfUploadModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  int get pageCount => throw _privateConstructorUsedError;
  double get fileSizeMB => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @_TimestampConverter()
  DateTime get uploadedAt => throw _privateConstructorUsedError;
  @_NullableTimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String get topicName => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  int get generatedCardCount => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;

  /// Serializes this PdfUploadModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfUploadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfUploadModelCopyWith<PdfUploadModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfUploadModelCopyWith<$Res> {
  factory $PdfUploadModelCopyWith(
    PdfUploadModel value,
    $Res Function(PdfUploadModel) then,
  ) = _$PdfUploadModelCopyWithImpl<$Res, PdfUploadModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String fileName,
    String storagePath,
    int pageCount,
    double fileSizeMB,
    String status,
    @_TimestampConverter() DateTime uploadedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    String topicName,
    String domainId,
    int generatedCardCount,
    String? error,
    bool isPublic,
  });
}

/// @nodoc
class _$PdfUploadModelCopyWithImpl<$Res, $Val extends PdfUploadModel>
    implements $PdfUploadModelCopyWith<$Res> {
  _$PdfUploadModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfUploadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fileName = null,
    Object? storagePath = null,
    Object? pageCount = null,
    Object? fileSizeMB = null,
    Object? status = null,
    Object? uploadedAt = null,
    Object? completedAt = freezed,
    Object? topicName = null,
    Object? domainId = null,
    Object? generatedCardCount = null,
    Object? error = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            storagePath: null == storagePath
                ? _value.storagePath
                : storagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            pageCount: null == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            fileSizeMB: null == fileSizeMB
                ? _value.fileSizeMB
                : fileSizeMB // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadedAt: null == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            topicName: null == topicName
                ? _value.topicName
                : topicName // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            generatedCardCount: null == generatedCardCount
                ? _value.generatedCardCount
                : generatedCardCount // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfUploadModelImplCopyWith<$Res>
    implements $PdfUploadModelCopyWith<$Res> {
  factory _$$PdfUploadModelImplCopyWith(
    _$PdfUploadModelImpl value,
    $Res Function(_$PdfUploadModelImpl) then,
  ) = __$$PdfUploadModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String fileName,
    String storagePath,
    int pageCount,
    double fileSizeMB,
    String status,
    @_TimestampConverter() DateTime uploadedAt,
    @_NullableTimestampConverter() DateTime? completedAt,
    String topicName,
    String domainId,
    int generatedCardCount,
    String? error,
    bool isPublic,
  });
}

/// @nodoc
class __$$PdfUploadModelImplCopyWithImpl<$Res>
    extends _$PdfUploadModelCopyWithImpl<$Res, _$PdfUploadModelImpl>
    implements _$$PdfUploadModelImplCopyWith<$Res> {
  __$$PdfUploadModelImplCopyWithImpl(
    _$PdfUploadModelImpl _value,
    $Res Function(_$PdfUploadModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfUploadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? fileName = null,
    Object? storagePath = null,
    Object? pageCount = null,
    Object? fileSizeMB = null,
    Object? status = null,
    Object? uploadedAt = null,
    Object? completedAt = freezed,
    Object? topicName = null,
    Object? domainId = null,
    Object? generatedCardCount = null,
    Object? error = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _$PdfUploadModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        storagePath: null == storagePath
            ? _value.storagePath
            : storagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        pageCount: null == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        fileSizeMB: null == fileSizeMB
            ? _value.fileSizeMB
            : fileSizeMB // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedAt: null == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        topicName: null == topicName
            ? _value.topicName
            : topicName // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        generatedCardCount: null == generatedCardCount
            ? _value.generatedCardCount
            : generatedCardCount // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfUploadModelImpl extends _PdfUploadModel {
  const _$PdfUploadModelImpl({
    required this.id,
    required this.userId,
    required this.fileName,
    this.storagePath = '',
    this.pageCount = 0,
    this.fileSizeMB = 0.0,
    this.status = 'uploading',
    @_TimestampConverter() required this.uploadedAt,
    @_NullableTimestampConverter() this.completedAt,
    this.topicName = '',
    this.domainId = '',
    this.generatedCardCount = 0,
    this.error,
    this.isPublic = false,
  }) : super._();

  factory _$PdfUploadModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfUploadModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String fileName;
  @override
  @JsonKey()
  final String storagePath;
  @override
  @JsonKey()
  final int pageCount;
  @override
  @JsonKey()
  final double fileSizeMB;
  @override
  @JsonKey()
  final String status;
  @override
  @_TimestampConverter()
  final DateTime uploadedAt;
  @override
  @_NullableTimestampConverter()
  final DateTime? completedAt;
  @override
  @JsonKey()
  final String topicName;
  @override
  @JsonKey()
  final String domainId;
  @override
  @JsonKey()
  final int generatedCardCount;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isPublic;

  @override
  String toString() {
    return 'PdfUploadModel(id: $id, userId: $userId, fileName: $fileName, storagePath: $storagePath, pageCount: $pageCount, fileSizeMB: $fileSizeMB, status: $status, uploadedAt: $uploadedAt, completedAt: $completedAt, topicName: $topicName, domainId: $domainId, generatedCardCount: $generatedCardCount, error: $error, isPublic: $isPublic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfUploadModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.fileSizeMB, fileSizeMB) ||
                other.fileSizeMB == fileSizeMB) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.topicName, topicName) ||
                other.topicName == topicName) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.generatedCardCount, generatedCardCount) ||
                other.generatedCardCount == generatedCardCount) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    fileName,
    storagePath,
    pageCount,
    fileSizeMB,
    status,
    uploadedAt,
    completedAt,
    topicName,
    domainId,
    generatedCardCount,
    error,
    isPublic,
  );

  /// Create a copy of PdfUploadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfUploadModelImplCopyWith<_$PdfUploadModelImpl> get copyWith =>
      __$$PdfUploadModelImplCopyWithImpl<_$PdfUploadModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfUploadModelImplToJson(this);
  }
}

abstract class _PdfUploadModel extends PdfUploadModel {
  const factory _PdfUploadModel({
    required final String id,
    required final String userId,
    required final String fileName,
    final String storagePath,
    final int pageCount,
    final double fileSizeMB,
    final String status,
    @_TimestampConverter() required final DateTime uploadedAt,
    @_NullableTimestampConverter() final DateTime? completedAt,
    final String topicName,
    final String domainId,
    final int generatedCardCount,
    final String? error,
    final bool isPublic,
  }) = _$PdfUploadModelImpl;
  const _PdfUploadModel._() : super._();

  factory _PdfUploadModel.fromJson(Map<String, dynamic> json) =
      _$PdfUploadModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get fileName;
  @override
  String get storagePath;
  @override
  int get pageCount;
  @override
  double get fileSizeMB;
  @override
  String get status;
  @override
  @_TimestampConverter()
  DateTime get uploadedAt;
  @override
  @_NullableTimestampConverter()
  DateTime? get completedAt;
  @override
  String get topicName;
  @override
  String get domainId;
  @override
  int get generatedCardCount;
  @override
  String? get error;
  @override
  bool get isPublic;

  /// Create a copy of PdfUploadModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfUploadModelImplCopyWith<_$PdfUploadModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
