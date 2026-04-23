// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookModel _$BookModelFromJson(Map<String, dynamic> json) {
  return _BookModel.fromJson(json);
}

/// @nodoc
mixin _$BookModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get domainId => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  List<String> get authors => throw _privateConstructorUsedError;
  String get coverUrl => throw _privateConstructorUsedError;
  String get googleBooksId => throw _privateConstructorUsedError;
  String get isbn => throw _privateConstructorUsedError;
  String get publisher => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get totalChapters => throw _privateConstructorUsedError;
  List<String> get examTags => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this BookModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookModelCopyWith<BookModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookModelCopyWith<$Res> {
  factory $BookModelCopyWith(BookModel value, $Res Function(BookModel) then) =
      _$BookModelCopyWithImpl<$Res, BookModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String domainId,
    String subjectId,
    List<String> authors,
    String coverUrl,
    String googleBooksId,
    String isbn,
    String publisher,
    String description,
    int totalChapters,
    List<String> examTags,
    int order,
  });
}

/// @nodoc
class _$BookModelCopyWithImpl<$Res, $Val extends BookModel>
    implements $BookModelCopyWith<$Res> {
  _$BookModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? domainId = null,
    Object? subjectId = null,
    Object? authors = null,
    Object? coverUrl = null,
    Object? googleBooksId = null,
    Object? isbn = null,
    Object? publisher = null,
    Object? description = null,
    Object? totalChapters = null,
    Object? examTags = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            domainId: null == domainId
                ? _value.domainId
                : domainId // ignore: cast_nullable_to_non_nullable
                      as String,
            subjectId: null == subjectId
                ? _value.subjectId
                : subjectId // ignore: cast_nullable_to_non_nullable
                      as String,
            authors: null == authors
                ? _value.authors
                : authors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            coverUrl: null == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            googleBooksId: null == googleBooksId
                ? _value.googleBooksId
                : googleBooksId // ignore: cast_nullable_to_non_nullable
                      as String,
            isbn: null == isbn
                ? _value.isbn
                : isbn // ignore: cast_nullable_to_non_nullable
                      as String,
            publisher: null == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            totalChapters: null == totalChapters
                ? _value.totalChapters
                : totalChapters // ignore: cast_nullable_to_non_nullable
                      as int,
            examTags: null == examTags
                ? _value.examTags
                : examTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$BookModelImplCopyWith<$Res>
    implements $BookModelCopyWith<$Res> {
  factory _$$BookModelImplCopyWith(
    _$BookModelImpl value,
    $Res Function(_$BookModelImpl) then,
  ) = __$$BookModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String domainId,
    String subjectId,
    List<String> authors,
    String coverUrl,
    String googleBooksId,
    String isbn,
    String publisher,
    String description,
    int totalChapters,
    List<String> examTags,
    int order,
  });
}

/// @nodoc
class __$$BookModelImplCopyWithImpl<$Res>
    extends _$BookModelCopyWithImpl<$Res, _$BookModelImpl>
    implements _$$BookModelImplCopyWith<$Res> {
  __$$BookModelImplCopyWithImpl(
    _$BookModelImpl _value,
    $Res Function(_$BookModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? domainId = null,
    Object? subjectId = null,
    Object? authors = null,
    Object? coverUrl = null,
    Object? googleBooksId = null,
    Object? isbn = null,
    Object? publisher = null,
    Object? description = null,
    Object? totalChapters = null,
    Object? examTags = null,
    Object? order = null,
  }) {
    return _then(
      _$BookModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        domainId: null == domainId
            ? _value.domainId
            : domainId // ignore: cast_nullable_to_non_nullable
                  as String,
        subjectId: null == subjectId
            ? _value.subjectId
            : subjectId // ignore: cast_nullable_to_non_nullable
                  as String,
        authors: null == authors
            ? _value._authors
            : authors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        coverUrl: null == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        googleBooksId: null == googleBooksId
            ? _value.googleBooksId
            : googleBooksId // ignore: cast_nullable_to_non_nullable
                  as String,
        isbn: null == isbn
            ? _value.isbn
            : isbn // ignore: cast_nullable_to_non_nullable
                  as String,
        publisher: null == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        totalChapters: null == totalChapters
            ? _value.totalChapters
            : totalChapters // ignore: cast_nullable_to_non_nullable
                  as int,
        examTags: null == examTags
            ? _value._examTags
            : examTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$BookModelImpl implements _BookModel {
  const _$BookModelImpl({
    required this.id,
    required this.title,
    required this.domainId,
    required this.subjectId,
    final List<String> authors = const [],
    this.coverUrl = '',
    this.googleBooksId = '',
    this.isbn = '',
    this.publisher = '',
    this.description = '',
    this.totalChapters = 0,
    final List<String> examTags = const [],
    this.order = 0,
  }) : _authors = authors,
       _examTags = examTags;

  factory _$BookModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String domainId;
  @override
  final String subjectId;
  final List<String> _authors;
  @override
  @JsonKey()
  List<String> get authors {
    if (_authors is EqualUnmodifiableListView) return _authors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authors);
  }

  @override
  @JsonKey()
  final String coverUrl;
  @override
  @JsonKey()
  final String googleBooksId;
  @override
  @JsonKey()
  final String isbn;
  @override
  @JsonKey()
  final String publisher;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final int totalChapters;
  final List<String> _examTags;
  @override
  @JsonKey()
  List<String> get examTags {
    if (_examTags is EqualUnmodifiableListView) return _examTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_examTags);
  }

  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'BookModel(id: $id, title: $title, domainId: $domainId, subjectId: $subjectId, authors: $authors, coverUrl: $coverUrl, googleBooksId: $googleBooksId, isbn: $isbn, publisher: $publisher, description: $description, totalChapters: $totalChapters, examTags: $examTags, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.domainId, domainId) ||
                other.domainId == domainId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            const DeepCollectionEquality().equals(other._authors, _authors) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.googleBooksId, googleBooksId) ||
                other.googleBooksId == googleBooksId) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.totalChapters, totalChapters) ||
                other.totalChapters == totalChapters) &&
            const DeepCollectionEquality().equals(other._examTags, _examTags) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    domainId,
    subjectId,
    const DeepCollectionEquality().hash(_authors),
    coverUrl,
    googleBooksId,
    isbn,
    publisher,
    description,
    totalChapters,
    const DeepCollectionEquality().hash(_examTags),
    order,
  );

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      __$$BookModelImplCopyWithImpl<_$BookModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookModelImplToJson(this);
  }
}

abstract class _BookModel implements BookModel {
  const factory _BookModel({
    required final String id,
    required final String title,
    required final String domainId,
    required final String subjectId,
    final List<String> authors,
    final String coverUrl,
    final String googleBooksId,
    final String isbn,
    final String publisher,
    final String description,
    final int totalChapters,
    final List<String> examTags,
    final int order,
  }) = _$BookModelImpl;

  factory _BookModel.fromJson(Map<String, dynamic> json) =
      _$BookModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get domainId;
  @override
  String get subjectId;
  @override
  List<String> get authors;
  @override
  String get coverUrl;
  @override
  String get googleBooksId;
  @override
  String get isbn;
  @override
  String get publisher;
  @override
  String get description;
  @override
  int get totalChapters;
  @override
  List<String> get examTags;
  @override
  int get order;

  /// Create a copy of BookModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookModelImplCopyWith<_$BookModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
