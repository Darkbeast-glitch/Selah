// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scripture {

 String get id; String get book; int get bookOrder; int get chapter; int get verse; String get text; String get translation;
/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptureCopyWith<Scripture> get copyWith => _$ScriptureCopyWithImpl<Scripture>(this as Scripture, _$identity);

  /// Serializes this Scripture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scripture&&(identical(other.id, id) || other.id == id)&&(identical(other.book, book) || other.book == book)&&(identical(other.bookOrder, bookOrder) || other.bookOrder == bookOrder)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.text, text) || other.text == text)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,book,bookOrder,chapter,verse,text,translation);

@override
String toString() {
  return 'Scripture(id: $id, book: $book, bookOrder: $bookOrder, chapter: $chapter, verse: $verse, text: $text, translation: $translation)';
}


}

/// @nodoc
abstract mixin class $ScriptureCopyWith<$Res>  {
  factory $ScriptureCopyWith(Scripture value, $Res Function(Scripture) _then) = _$ScriptureCopyWithImpl;
@useResult
$Res call({
 String id, String book, int bookOrder, int chapter, int verse, String text, String translation
});




}
/// @nodoc
class _$ScriptureCopyWithImpl<$Res>
    implements $ScriptureCopyWith<$Res> {
  _$ScriptureCopyWithImpl(this._self, this._then);

  final Scripture _self;
  final $Res Function(Scripture) _then;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? book = null,Object? bookOrder = null,Object? chapter = null,Object? verse = null,Object? text = null,Object? translation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,bookOrder: null == bookOrder ? _self.bookOrder : bookOrder // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Scripture].
extension ScripturePatterns on Scripture {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scripture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scripture value)  $default,){
final _that = this;
switch (_that) {
case _Scripture():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scripture value)?  $default,){
final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String book,  int bookOrder,  int chapter,  int verse,  String text,  String translation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that.id,_that.book,_that.bookOrder,_that.chapter,_that.verse,_that.text,_that.translation);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String book,  int bookOrder,  int chapter,  int verse,  String text,  String translation)  $default,) {final _that = this;
switch (_that) {
case _Scripture():
return $default(_that.id,_that.book,_that.bookOrder,_that.chapter,_that.verse,_that.text,_that.translation);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String book,  int bookOrder,  int chapter,  int verse,  String text,  String translation)?  $default,) {final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that.id,_that.book,_that.bookOrder,_that.chapter,_that.verse,_that.text,_that.translation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scripture extends Scripture {
  const _Scripture({required this.id, required this.book, required this.bookOrder, required this.chapter, required this.verse, required this.text, required this.translation}): super._();
  factory _Scripture.fromJson(Map<String, dynamic> json) => _$ScriptureFromJson(json);

@override final  String id;
@override final  String book;
@override final  int bookOrder;
@override final  int chapter;
@override final  int verse;
@override final  String text;
@override final  String translation;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptureCopyWith<_Scripture> get copyWith => __$ScriptureCopyWithImpl<_Scripture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scripture&&(identical(other.id, id) || other.id == id)&&(identical(other.book, book) || other.book == book)&&(identical(other.bookOrder, bookOrder) || other.bookOrder == bookOrder)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.text, text) || other.text == text)&&(identical(other.translation, translation) || other.translation == translation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,book,bookOrder,chapter,verse,text,translation);

@override
String toString() {
  return 'Scripture(id: $id, book: $book, bookOrder: $bookOrder, chapter: $chapter, verse: $verse, text: $text, translation: $translation)';
}


}

/// @nodoc
abstract mixin class _$ScriptureCopyWith<$Res> implements $ScriptureCopyWith<$Res> {
  factory _$ScriptureCopyWith(_Scripture value, $Res Function(_Scripture) _then) = __$ScriptureCopyWithImpl;
@override @useResult
$Res call({
 String id, String book, int bookOrder, int chapter, int verse, String text, String translation
});




}
/// @nodoc
class __$ScriptureCopyWithImpl<$Res>
    implements _$ScriptureCopyWith<$Res> {
  __$ScriptureCopyWithImpl(this._self, this._then);

  final _Scripture _self;
  final $Res Function(_Scripture) _then;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? book = null,Object? bookOrder = null,Object? chapter = null,Object? verse = null,Object? text = null,Object? translation = null,}) {
  return _then(_Scripture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,bookOrder: null == bookOrder ? _self.bookOrder : bookOrder // ignore: cast_nullable_to_non_nullable
as int,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,translation: null == translation ? _self.translation : translation // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BibleBook {

 int get bookOrder; String get name; String get slug; Testament get testament; int get chapters;
/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BibleBookCopyWith<BibleBook> get copyWith => _$BibleBookCopyWithImpl<BibleBook>(this as BibleBook, _$identity);

  /// Serializes this BibleBook to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BibleBook&&(identical(other.bookOrder, bookOrder) || other.bookOrder == bookOrder)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.testament, testament) || other.testament == testament)&&(identical(other.chapters, chapters) || other.chapters == chapters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookOrder,name,slug,testament,chapters);

@override
String toString() {
  return 'BibleBook(bookOrder: $bookOrder, name: $name, slug: $slug, testament: $testament, chapters: $chapters)';
}


}

/// @nodoc
abstract mixin class $BibleBookCopyWith<$Res>  {
  factory $BibleBookCopyWith(BibleBook value, $Res Function(BibleBook) _then) = _$BibleBookCopyWithImpl;
@useResult
$Res call({
 int bookOrder, String name, String slug, Testament testament, int chapters
});




}
/// @nodoc
class _$BibleBookCopyWithImpl<$Res>
    implements $BibleBookCopyWith<$Res> {
  _$BibleBookCopyWithImpl(this._self, this._then);

  final BibleBook _self;
  final $Res Function(BibleBook) _then;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookOrder = null,Object? name = null,Object? slug = null,Object? testament = null,Object? chapters = null,}) {
  return _then(_self.copyWith(
bookOrder: null == bookOrder ? _self.bookOrder : bookOrder // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,testament: null == testament ? _self.testament : testament // ignore: cast_nullable_to_non_nullable
as Testament,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BibleBook].
extension BibleBookPatterns on BibleBook {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BibleBook value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BibleBook value)  $default,){
final _that = this;
switch (_that) {
case _BibleBook():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BibleBook value)?  $default,){
final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int bookOrder,  String name,  String slug,  Testament testament,  int chapters)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that.bookOrder,_that.name,_that.slug,_that.testament,_that.chapters);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int bookOrder,  String name,  String slug,  Testament testament,  int chapters)  $default,) {final _that = this;
switch (_that) {
case _BibleBook():
return $default(_that.bookOrder,_that.name,_that.slug,_that.testament,_that.chapters);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int bookOrder,  String name,  String slug,  Testament testament,  int chapters)?  $default,) {final _that = this;
switch (_that) {
case _BibleBook() when $default != null:
return $default(_that.bookOrder,_that.name,_that.slug,_that.testament,_that.chapters);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BibleBook implements BibleBook {
  const _BibleBook({required this.bookOrder, required this.name, required this.slug, required this.testament, required this.chapters});
  factory _BibleBook.fromJson(Map<String, dynamic> json) => _$BibleBookFromJson(json);

@override final  int bookOrder;
@override final  String name;
@override final  String slug;
@override final  Testament testament;
@override final  int chapters;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BibleBookCopyWith<_BibleBook> get copyWith => __$BibleBookCopyWithImpl<_BibleBook>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BibleBookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BibleBook&&(identical(other.bookOrder, bookOrder) || other.bookOrder == bookOrder)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.testament, testament) || other.testament == testament)&&(identical(other.chapters, chapters) || other.chapters == chapters));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,bookOrder,name,slug,testament,chapters);

@override
String toString() {
  return 'BibleBook(bookOrder: $bookOrder, name: $name, slug: $slug, testament: $testament, chapters: $chapters)';
}


}

/// @nodoc
abstract mixin class _$BibleBookCopyWith<$Res> implements $BibleBookCopyWith<$Res> {
  factory _$BibleBookCopyWith(_BibleBook value, $Res Function(_BibleBook) _then) = __$BibleBookCopyWithImpl;
@override @useResult
$Res call({
 int bookOrder, String name, String slug, Testament testament, int chapters
});




}
/// @nodoc
class __$BibleBookCopyWithImpl<$Res>
    implements _$BibleBookCopyWith<$Res> {
  __$BibleBookCopyWithImpl(this._self, this._then);

  final _BibleBook _self;
  final $Res Function(_BibleBook) _then;

/// Create a copy of BibleBook
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookOrder = null,Object? name = null,Object? slug = null,Object? testament = null,Object? chapters = null,}) {
  return _then(_BibleBook(
bookOrder: null == bookOrder ? _self.bookOrder : bookOrder // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,testament: null == testament ? _self.testament : testament // ignore: cast_nullable_to_non_nullable
as Testament,chapters: null == chapters ? _self.chapters : chapters // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ScriptureRef {

 String get book; int get chapter;/// Null when the user named a chapter but no specific verse.
 int? get verse;
/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptureRefCopyWith<ScriptureRef> get copyWith => _$ScriptureRefCopyWithImpl<ScriptureRef>(this as ScriptureRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptureRef&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,book,chapter,verse);

@override
String toString() {
  return 'ScriptureRef(book: $book, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class $ScriptureRefCopyWith<$Res>  {
  factory $ScriptureRefCopyWith(ScriptureRef value, $Res Function(ScriptureRef) _then) = _$ScriptureRefCopyWithImpl;
@useResult
$Res call({
 String book, int chapter, int? verse
});




}
/// @nodoc
class _$ScriptureRefCopyWithImpl<$Res>
    implements $ScriptureRefCopyWith<$Res> {
  _$ScriptureRefCopyWithImpl(this._self, this._then);

  final ScriptureRef _self;
  final $Res Function(ScriptureRef) _then;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? book = null,Object? chapter = null,Object? verse = freezed,}) {
  return _then(_self.copyWith(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: freezed == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptureRef].
extension ScriptureRefPatterns on ScriptureRef {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptureRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptureRef value)  $default,){
final _that = this;
switch (_that) {
case _ScriptureRef():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptureRef value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String book,  int chapter,  int? verse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that.book,_that.chapter,_that.verse);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String book,  int chapter,  int? verse)  $default,) {final _that = this;
switch (_that) {
case _ScriptureRef():
return $default(_that.book,_that.chapter,_that.verse);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String book,  int chapter,  int? verse)?  $default,) {final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that.book,_that.chapter,_that.verse);case _:
  return null;

}
}

}

/// @nodoc


class _ScriptureRef implements ScriptureRef {
  const _ScriptureRef({required this.book, required this.chapter, this.verse});
  

@override final  String book;
@override final  int chapter;
/// Null when the user named a chapter but no specific verse.
@override final  int? verse;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptureRefCopyWith<_ScriptureRef> get copyWith => __$ScriptureRefCopyWithImpl<_ScriptureRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptureRef&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse));
}


@override
int get hashCode => Object.hash(runtimeType,book,chapter,verse);

@override
String toString() {
  return 'ScriptureRef(book: $book, chapter: $chapter, verse: $verse)';
}


}

/// @nodoc
abstract mixin class _$ScriptureRefCopyWith<$Res> implements $ScriptureRefCopyWith<$Res> {
  factory _$ScriptureRefCopyWith(_ScriptureRef value, $Res Function(_ScriptureRef) _then) = __$ScriptureRefCopyWithImpl;
@override @useResult
$Res call({
 String book, int chapter, int? verse
});




}
/// @nodoc
class __$ScriptureRefCopyWithImpl<$Res>
    implements _$ScriptureRefCopyWith<$Res> {
  __$ScriptureRefCopyWithImpl(this._self, this._then);

  final _ScriptureRef _self;
  final $Res Function(_ScriptureRef) _then;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? book = null,Object? chapter = null,Object? verse = freezed,}) {
  return _then(_ScriptureRef(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: freezed == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
