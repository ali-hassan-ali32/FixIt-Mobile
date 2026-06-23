// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lookup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LookupState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LookupState()';
}


}

/// @nodoc
class $LookupStateCopyWith<$Res>  {
$LookupStateCopyWith(LookupState _, $Res Function(LookupState) __);
}


/// Adds pattern-matching-related methods to [LookupState].
extension LookupStatePatterns on LookupState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LookupInitial value)?  initial,TResult Function( LookupLoading value)?  loading,TResult Function( LookupLoaded value)?  loaded,TResult Function( LookupError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LookupInitial() when initial != null:
return initial(_that);case LookupLoading() when loading != null:
return loading(_that);case LookupLoaded() when loaded != null:
return loaded(_that);case LookupError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LookupInitial value)  initial,required TResult Function( LookupLoading value)  loading,required TResult Function( LookupLoaded value)  loaded,required TResult Function( LookupError value)  error,}){
final _that = this;
switch (_that) {
case LookupInitial():
return initial(_that);case LookupLoading():
return loading(_that);case LookupLoaded():
return loaded(_that);case LookupError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LookupInitial value)?  initial,TResult? Function( LookupLoading value)?  loading,TResult? Function( LookupLoaded value)?  loaded,TResult? Function( LookupError value)?  error,}){
final _that = this;
switch (_that) {
case LookupInitial() when initial != null:
return initial(_that);case LookupLoading() when loading != null:
return loading(_that);case LookupLoaded() when loaded != null:
return loaded(_that);case LookupError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<LookupItemEntity> cities,  List<LookupItemEntity> regions,  List<LookupItemEntity> categories)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LookupInitial() when initial != null:
return initial();case LookupLoading() when loading != null:
return loading();case LookupLoaded() when loaded != null:
return loaded(_that.cities,_that.regions,_that.categories);case LookupError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<LookupItemEntity> cities,  List<LookupItemEntity> regions,  List<LookupItemEntity> categories)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case LookupInitial():
return initial();case LookupLoading():
return loading();case LookupLoaded():
return loaded(_that.cities,_that.regions,_that.categories);case LookupError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<LookupItemEntity> cities,  List<LookupItemEntity> regions,  List<LookupItemEntity> categories)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case LookupInitial() when initial != null:
return initial();case LookupLoading() when loading != null:
return loading();case LookupLoaded() when loaded != null:
return loaded(_that.cities,_that.regions,_that.categories);case LookupError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class LookupInitial implements LookupState {
  const LookupInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LookupState.initial()';
}


}




/// @nodoc


class LookupLoading implements LookupState {
  const LookupLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LookupState.loading()';
}


}




/// @nodoc


class LookupLoaded implements LookupState {
  const LookupLoaded({final  List<LookupItemEntity> cities = const [], final  List<LookupItemEntity> regions = const [], final  List<LookupItemEntity> categories = const []}): _cities = cities,_regions = regions,_categories = categories;
  

 final  List<LookupItemEntity> _cities;
@JsonKey() List<LookupItemEntity> get cities {
  if (_cities is EqualUnmodifiableListView) return _cities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cities);
}

 final  List<LookupItemEntity> _regions;
@JsonKey() List<LookupItemEntity> get regions {
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regions);
}

 final  List<LookupItemEntity> _categories;
@JsonKey() List<LookupItemEntity> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupLoadedCopyWith<LookupLoaded> get copyWith => _$LookupLoadedCopyWithImpl<LookupLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupLoaded&&const DeepCollectionEquality().equals(other._cities, _cities)&&const DeepCollectionEquality().equals(other._regions, _regions)&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cities),const DeepCollectionEquality().hash(_regions),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'LookupState.loaded(cities: $cities, regions: $regions, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $LookupLoadedCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory $LookupLoadedCopyWith(LookupLoaded value, $Res Function(LookupLoaded) _then) = _$LookupLoadedCopyWithImpl;
@useResult
$Res call({
 List<LookupItemEntity> cities, List<LookupItemEntity> regions, List<LookupItemEntity> categories
});




}
/// @nodoc
class _$LookupLoadedCopyWithImpl<$Res>
    implements $LookupLoadedCopyWith<$Res> {
  _$LookupLoadedCopyWithImpl(this._self, this._then);

  final LookupLoaded _self;
  final $Res Function(LookupLoaded) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? cities = null,Object? regions = null,Object? categories = null,}) {
  return _then(LookupLoaded(
cities: null == cities ? _self._cities : cities // ignore: cast_nullable_to_non_nullable
as List<LookupItemEntity>,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<LookupItemEntity>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<LookupItemEntity>,
  ));
}


}

/// @nodoc


class LookupError implements LookupState {
  const LookupError(this.message);
  

 final  String message;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LookupErrorCopyWith<LookupError> get copyWith => _$LookupErrorCopyWithImpl<LookupError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LookupError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'LookupState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $LookupErrorCopyWith<$Res> implements $LookupStateCopyWith<$Res> {
  factory $LookupErrorCopyWith(LookupError value, $Res Function(LookupError) _then) = _$LookupErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$LookupErrorCopyWithImpl<$Res>
    implements $LookupErrorCopyWith<$Res> {
  _$LookupErrorCopyWithImpl(this._self, this._then);

  final LookupError _self;
  final $Res Function(LookupError) _then;

/// Create a copy of LookupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(LookupError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
