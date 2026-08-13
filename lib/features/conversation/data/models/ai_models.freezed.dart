// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiReflection {

/// Recognises what the person said. Never claims to know God's message.
 String get acknowledgement;/// One entry per passage the app supplied, with why it speaks to this.
 List<AiScriptureNote> get scriptures;/// The substance of the reply: answers what the person asked and teaches
/// something, grounded in the supplied passages and attributed rather than
/// asserted. Rendered under the design's "Consider this" label.
 String get response;/// The "REFLECT" section.
 String get reflectionQuestion;/// A gentle invitation to continue.
 String get followUpPrompt;/// Crisis support text (PRD §25), computed by the backend from the *user's*
/// message rather than the model's output — so a bad generation cannot
/// suppress it.
///
/// **When non-null this must be displayed prominently.** It is not optional
/// copy; it is the app's obligation to someone who may be in danger.
 String? get safetyNotice;
/// Create a copy of AiReflection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiReflectionCopyWith<AiReflection> get copyWith => _$AiReflectionCopyWithImpl<AiReflection>(this as AiReflection, _$identity);

  /// Serializes this AiReflection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiReflection&&(identical(other.acknowledgement, acknowledgement) || other.acknowledgement == acknowledgement)&&const DeepCollectionEquality().equals(other.scriptures, scriptures)&&(identical(other.response, response) || other.response == response)&&(identical(other.reflectionQuestion, reflectionQuestion) || other.reflectionQuestion == reflectionQuestion)&&(identical(other.followUpPrompt, followUpPrompt) || other.followUpPrompt == followUpPrompt)&&(identical(other.safetyNotice, safetyNotice) || other.safetyNotice == safetyNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acknowledgement,const DeepCollectionEquality().hash(scriptures),response,reflectionQuestion,followUpPrompt,safetyNotice);

@override
String toString() {
  return 'AiReflection(acknowledgement: $acknowledgement, scriptures: $scriptures, response: $response, reflectionQuestion: $reflectionQuestion, followUpPrompt: $followUpPrompt, safetyNotice: $safetyNotice)';
}


}

/// @nodoc
abstract mixin class $AiReflectionCopyWith<$Res>  {
  factory $AiReflectionCopyWith(AiReflection value, $Res Function(AiReflection) _then) = _$AiReflectionCopyWithImpl;
@useResult
$Res call({
 String acknowledgement, List<AiScriptureNote> scriptures, String response, String reflectionQuestion, String followUpPrompt, String? safetyNotice
});




}
/// @nodoc
class _$AiReflectionCopyWithImpl<$Res>
    implements $AiReflectionCopyWith<$Res> {
  _$AiReflectionCopyWithImpl(this._self, this._then);

  final AiReflection _self;
  final $Res Function(AiReflection) _then;

/// Create a copy of AiReflection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? acknowledgement = null,Object? scriptures = null,Object? response = null,Object? reflectionQuestion = null,Object? followUpPrompt = null,Object? safetyNotice = freezed,}) {
  return _then(_self.copyWith(
acknowledgement: null == acknowledgement ? _self.acknowledgement : acknowledgement // ignore: cast_nullable_to_non_nullable
as String,scriptures: null == scriptures ? _self.scriptures : scriptures // ignore: cast_nullable_to_non_nullable
as List<AiScriptureNote>,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String,reflectionQuestion: null == reflectionQuestion ? _self.reflectionQuestion : reflectionQuestion // ignore: cast_nullable_to_non_nullable
as String,followUpPrompt: null == followUpPrompt ? _self.followUpPrompt : followUpPrompt // ignore: cast_nullable_to_non_nullable
as String,safetyNotice: freezed == safetyNotice ? _self.safetyNotice : safetyNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiReflection].
extension AiReflectionPatterns on AiReflection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiReflection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiReflection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiReflection value)  $default,){
final _that = this;
switch (_that) {
case _AiReflection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiReflection value)?  $default,){
final _that = this;
switch (_that) {
case _AiReflection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String acknowledgement,  List<AiScriptureNote> scriptures,  String response,  String reflectionQuestion,  String followUpPrompt,  String? safetyNotice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiReflection() when $default != null:
return $default(_that.acknowledgement,_that.scriptures,_that.response,_that.reflectionQuestion,_that.followUpPrompt,_that.safetyNotice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String acknowledgement,  List<AiScriptureNote> scriptures,  String response,  String reflectionQuestion,  String followUpPrompt,  String? safetyNotice)  $default,) {final _that = this;
switch (_that) {
case _AiReflection():
return $default(_that.acknowledgement,_that.scriptures,_that.response,_that.reflectionQuestion,_that.followUpPrompt,_that.safetyNotice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String acknowledgement,  List<AiScriptureNote> scriptures,  String response,  String reflectionQuestion,  String followUpPrompt,  String? safetyNotice)?  $default,) {final _that = this;
switch (_that) {
case _AiReflection() when $default != null:
return $default(_that.acknowledgement,_that.scriptures,_that.response,_that.reflectionQuestion,_that.followUpPrompt,_that.safetyNotice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiReflection implements AiReflection {
  const _AiReflection({required this.acknowledgement, required final  List<AiScriptureNote> scriptures, required this.response, required this.reflectionQuestion, required this.followUpPrompt, this.safetyNotice}): _scriptures = scriptures;
  factory _AiReflection.fromJson(Map<String, dynamic> json) => _$AiReflectionFromJson(json);

/// Recognises what the person said. Never claims to know God's message.
@override final  String acknowledgement;
/// One entry per passage the app supplied, with why it speaks to this.
 final  List<AiScriptureNote> _scriptures;
/// One entry per passage the app supplied, with why it speaks to this.
@override List<AiScriptureNote> get scriptures {
  if (_scriptures is EqualUnmodifiableListView) return _scriptures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scriptures);
}

/// The substance of the reply: answers what the person asked and teaches
/// something, grounded in the supplied passages and attributed rather than
/// asserted. Rendered under the design's "Consider this" label.
@override final  String response;
/// The "REFLECT" section.
@override final  String reflectionQuestion;
/// A gentle invitation to continue.
@override final  String followUpPrompt;
/// Crisis support text (PRD §25), computed by the backend from the *user's*
/// message rather than the model's output — so a bad generation cannot
/// suppress it.
///
/// **When non-null this must be displayed prominently.** It is not optional
/// copy; it is the app's obligation to someone who may be in danger.
@override final  String? safetyNotice;

/// Create a copy of AiReflection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiReflectionCopyWith<_AiReflection> get copyWith => __$AiReflectionCopyWithImpl<_AiReflection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiReflectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiReflection&&(identical(other.acknowledgement, acknowledgement) || other.acknowledgement == acknowledgement)&&const DeepCollectionEquality().equals(other._scriptures, _scriptures)&&(identical(other.response, response) || other.response == response)&&(identical(other.reflectionQuestion, reflectionQuestion) || other.reflectionQuestion == reflectionQuestion)&&(identical(other.followUpPrompt, followUpPrompt) || other.followUpPrompt == followUpPrompt)&&(identical(other.safetyNotice, safetyNotice) || other.safetyNotice == safetyNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,acknowledgement,const DeepCollectionEquality().hash(_scriptures),response,reflectionQuestion,followUpPrompt,safetyNotice);

@override
String toString() {
  return 'AiReflection(acknowledgement: $acknowledgement, scriptures: $scriptures, response: $response, reflectionQuestion: $reflectionQuestion, followUpPrompt: $followUpPrompt, safetyNotice: $safetyNotice)';
}


}

/// @nodoc
abstract mixin class _$AiReflectionCopyWith<$Res> implements $AiReflectionCopyWith<$Res> {
  factory _$AiReflectionCopyWith(_AiReflection value, $Res Function(_AiReflection) _then) = __$AiReflectionCopyWithImpl;
@override @useResult
$Res call({
 String acknowledgement, List<AiScriptureNote> scriptures, String response, String reflectionQuestion, String followUpPrompt, String? safetyNotice
});




}
/// @nodoc
class __$AiReflectionCopyWithImpl<$Res>
    implements _$AiReflectionCopyWith<$Res> {
  __$AiReflectionCopyWithImpl(this._self, this._then);

  final _AiReflection _self;
  final $Res Function(_AiReflection) _then;

/// Create a copy of AiReflection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? acknowledgement = null,Object? scriptures = null,Object? response = null,Object? reflectionQuestion = null,Object? followUpPrompt = null,Object? safetyNotice = freezed,}) {
  return _then(_AiReflection(
acknowledgement: null == acknowledgement ? _self.acknowledgement : acknowledgement // ignore: cast_nullable_to_non_nullable
as String,scriptures: null == scriptures ? _self._scriptures : scriptures // ignore: cast_nullable_to_non_nullable
as List<AiScriptureNote>,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String,reflectionQuestion: null == reflectionQuestion ? _self.reflectionQuestion : reflectionQuestion // ignore: cast_nullable_to_non_nullable
as String,followUpPrompt: null == followUpPrompt ? _self.followUpPrompt : followUpPrompt // ignore: cast_nullable_to_non_nullable
as String,safetyNotice: freezed == safetyNotice ? _self.safetyNotice : safetyNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AiScriptureNote {

/// Corpus verse id, matching one the app supplied.
 String get id; String get reference;/// One sentence on why this passage speaks to the situation.
 String get reason;
/// Create a copy of AiScriptureNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiScriptureNoteCopyWith<AiScriptureNote> get copyWith => _$AiScriptureNoteCopyWithImpl<AiScriptureNote>(this as AiScriptureNote, _$identity);

  /// Serializes this AiScriptureNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiScriptureNote&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,reason);

@override
String toString() {
  return 'AiScriptureNote(id: $id, reference: $reference, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $AiScriptureNoteCopyWith<$Res>  {
  factory $AiScriptureNoteCopyWith(AiScriptureNote value, $Res Function(AiScriptureNote) _then) = _$AiScriptureNoteCopyWithImpl;
@useResult
$Res call({
 String id, String reference, String reason
});




}
/// @nodoc
class _$AiScriptureNoteCopyWithImpl<$Res>
    implements $AiScriptureNoteCopyWith<$Res> {
  _$AiScriptureNoteCopyWithImpl(this._self, this._then);

  final AiScriptureNote _self;
  final $Res Function(AiScriptureNote) _then;

/// Create a copy of AiScriptureNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reference = null,Object? reason = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AiScriptureNote].
extension AiScriptureNotePatterns on AiScriptureNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiScriptureNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiScriptureNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiScriptureNote value)  $default,){
final _that = this;
switch (_that) {
case _AiScriptureNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiScriptureNote value)?  $default,){
final _that = this;
switch (_that) {
case _AiScriptureNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String reference,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiScriptureNote() when $default != null:
return $default(_that.id,_that.reference,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String reference,  String reason)  $default,) {final _that = this;
switch (_that) {
case _AiScriptureNote():
return $default(_that.id,_that.reference,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String reference,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _AiScriptureNote() when $default != null:
return $default(_that.id,_that.reference,_that.reason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiScriptureNote implements AiScriptureNote {
  const _AiScriptureNote({required this.id, required this.reference, required this.reason});
  factory _AiScriptureNote.fromJson(Map<String, dynamic> json) => _$AiScriptureNoteFromJson(json);

/// Corpus verse id, matching one the app supplied.
@override final  String id;
@override final  String reference;
/// One sentence on why this passage speaks to the situation.
@override final  String reason;

/// Create a copy of AiScriptureNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiScriptureNoteCopyWith<_AiScriptureNote> get copyWith => __$AiScriptureNoteCopyWithImpl<_AiScriptureNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiScriptureNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiScriptureNote&&(identical(other.id, id) || other.id == id)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reference,reason);

@override
String toString() {
  return 'AiScriptureNote(id: $id, reference: $reference, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$AiScriptureNoteCopyWith<$Res> implements $AiScriptureNoteCopyWith<$Res> {
  factory _$AiScriptureNoteCopyWith(_AiScriptureNote value, $Res Function(_AiScriptureNote) _then) = __$AiScriptureNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String reference, String reason
});




}
/// @nodoc
class __$AiScriptureNoteCopyWithImpl<$Res>
    implements _$AiScriptureNoteCopyWith<$Res> {
  __$AiScriptureNoteCopyWithImpl(this._self, this._then);

  final _AiScriptureNote _self;
  final $Res Function(_AiScriptureNote) _then;

/// Create a copy of AiScriptureNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reference = null,Object? reason = null,}) {
  return _then(_AiScriptureNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AiPrayer {

/// Always labelled "Prayer starter" in the UI — never "God's prayer".
 String get prayerStarter; String? get safetyNotice;
/// Create a copy of AiPrayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiPrayerCopyWith<AiPrayer> get copyWith => _$AiPrayerCopyWithImpl<AiPrayer>(this as AiPrayer, _$identity);

  /// Serializes this AiPrayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiPrayer&&(identical(other.prayerStarter, prayerStarter) || other.prayerStarter == prayerStarter)&&(identical(other.safetyNotice, safetyNotice) || other.safetyNotice == safetyNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prayerStarter,safetyNotice);

@override
String toString() {
  return 'AiPrayer(prayerStarter: $prayerStarter, safetyNotice: $safetyNotice)';
}


}

/// @nodoc
abstract mixin class $AiPrayerCopyWith<$Res>  {
  factory $AiPrayerCopyWith(AiPrayer value, $Res Function(AiPrayer) _then) = _$AiPrayerCopyWithImpl;
@useResult
$Res call({
 String prayerStarter, String? safetyNotice
});




}
/// @nodoc
class _$AiPrayerCopyWithImpl<$Res>
    implements $AiPrayerCopyWith<$Res> {
  _$AiPrayerCopyWithImpl(this._self, this._then);

  final AiPrayer _self;
  final $Res Function(AiPrayer) _then;

/// Create a copy of AiPrayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? prayerStarter = null,Object? safetyNotice = freezed,}) {
  return _then(_self.copyWith(
prayerStarter: null == prayerStarter ? _self.prayerStarter : prayerStarter // ignore: cast_nullable_to_non_nullable
as String,safetyNotice: freezed == safetyNotice ? _self.safetyNotice : safetyNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiPrayer].
extension AiPrayerPatterns on AiPrayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiPrayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiPrayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiPrayer value)  $default,){
final _that = this;
switch (_that) {
case _AiPrayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiPrayer value)?  $default,){
final _that = this;
switch (_that) {
case _AiPrayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String prayerStarter,  String? safetyNotice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiPrayer() when $default != null:
return $default(_that.prayerStarter,_that.safetyNotice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String prayerStarter,  String? safetyNotice)  $default,) {final _that = this;
switch (_that) {
case _AiPrayer():
return $default(_that.prayerStarter,_that.safetyNotice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String prayerStarter,  String? safetyNotice)?  $default,) {final _that = this;
switch (_that) {
case _AiPrayer() when $default != null:
return $default(_that.prayerStarter,_that.safetyNotice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiPrayer implements AiPrayer {
  const _AiPrayer({required this.prayerStarter, this.safetyNotice});
  factory _AiPrayer.fromJson(Map<String, dynamic> json) => _$AiPrayerFromJson(json);

/// Always labelled "Prayer starter" in the UI — never "God's prayer".
@override final  String prayerStarter;
@override final  String? safetyNotice;

/// Create a copy of AiPrayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiPrayerCopyWith<_AiPrayer> get copyWith => __$AiPrayerCopyWithImpl<_AiPrayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiPrayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiPrayer&&(identical(other.prayerStarter, prayerStarter) || other.prayerStarter == prayerStarter)&&(identical(other.safetyNotice, safetyNotice) || other.safetyNotice == safetyNotice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,prayerStarter,safetyNotice);

@override
String toString() {
  return 'AiPrayer(prayerStarter: $prayerStarter, safetyNotice: $safetyNotice)';
}


}

/// @nodoc
abstract mixin class _$AiPrayerCopyWith<$Res> implements $AiPrayerCopyWith<$Res> {
  factory _$AiPrayerCopyWith(_AiPrayer value, $Res Function(_AiPrayer) _then) = __$AiPrayerCopyWithImpl;
@override @useResult
$Res call({
 String prayerStarter, String? safetyNotice
});




}
/// @nodoc
class __$AiPrayerCopyWithImpl<$Res>
    implements _$AiPrayerCopyWith<$Res> {
  __$AiPrayerCopyWithImpl(this._self, this._then);

  final _AiPrayer _self;
  final $Res Function(_AiPrayer) _then;

/// Create a copy of AiPrayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? prayerStarter = null,Object? safetyNotice = freezed,}) {
  return _then(_AiPrayer(
prayerStarter: null == prayerStarter ? _self.prayerStarter : prayerStarter // ignore: cast_nullable_to_non_nullable
as String,safetyNotice: freezed == safetyNotice ? _self.safetyNotice : safetyNotice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
