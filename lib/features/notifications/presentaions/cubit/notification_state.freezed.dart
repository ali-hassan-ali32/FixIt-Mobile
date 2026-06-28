// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState()';
}


}

/// @nodoc
class $NotificationStateCopyWith<$Res>  {
$NotificationStateCopyWith(NotificationState _, $Res Function(NotificationState) __);
}


/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NotificationInitial value)?  initial,TResult Function( NotificationLoading value)?  loading,TResult Function( NotificationLoaded value)?  loaded,TResult Function( NotificationMessage value)?  message,TResult Function( NotificationError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial(_that);case NotificationLoading() when loading != null:
return loading(_that);case NotificationLoaded() when loaded != null:
return loaded(_that);case NotificationMessage() when message != null:
return message(_that);case NotificationError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NotificationInitial value)  initial,required TResult Function( NotificationLoading value)  loading,required TResult Function( NotificationLoaded value)  loaded,required TResult Function( NotificationMessage value)  message,required TResult Function( NotificationError value)  error,}){
final _that = this;
switch (_that) {
case NotificationInitial():
return initial(_that);case NotificationLoading():
return loading(_that);case NotificationLoaded():
return loaded(_that);case NotificationMessage():
return message(_that);case NotificationError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NotificationInitial value)?  initial,TResult? Function( NotificationLoading value)?  loading,TResult? Function( NotificationLoaded value)?  loaded,TResult? Function( NotificationMessage value)?  message,TResult? Function( NotificationError value)?  error,}){
final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial(_that);case NotificationLoading() when loading != null:
return loading(_that);case NotificationLoaded() when loaded != null:
return loaded(_that);case NotificationMessage() when message != null:
return message(_that);case NotificationError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<NotificationEntity> notifications)?  loaded,TResult Function( String message)?  message,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial();case NotificationLoading() when loading != null:
return loading();case NotificationLoaded() when loaded != null:
return loaded(_that.notifications);case NotificationMessage() when message != null:
return message(_that.message);case NotificationError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<NotificationEntity> notifications)  loaded,required TResult Function( String message)  message,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case NotificationInitial():
return initial();case NotificationLoading():
return loading();case NotificationLoaded():
return loaded(_that.notifications);case NotificationMessage():
return message(_that.message);case NotificationError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<NotificationEntity> notifications)?  loaded,TResult? Function( String message)?  message,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case NotificationInitial() when initial != null:
return initial();case NotificationLoading() when loading != null:
return loading();case NotificationLoaded() when loaded != null:
return loaded(_that.notifications);case NotificationMessage() when message != null:
return message(_that.message);case NotificationError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class NotificationInitial implements NotificationState {
  const NotificationInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.initial()';
}


}




/// @nodoc


class NotificationLoading implements NotificationState {
  const NotificationLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.loading()';
}


}




/// @nodoc


class NotificationLoaded implements NotificationState {
  const NotificationLoaded(final  List<NotificationEntity> notifications): _notifications = notifications;
  

 final  List<NotificationEntity> _notifications;
 List<NotificationEntity> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}


/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationLoadedCopyWith<NotificationLoaded> get copyWith => _$NotificationLoadedCopyWithImpl<NotificationLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationLoaded&&const DeepCollectionEquality().equals(other._notifications, _notifications));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notifications));

@override
String toString() {
  return 'NotificationState.loaded(notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class $NotificationLoadedCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationLoadedCopyWith(NotificationLoaded value, $Res Function(NotificationLoaded) _then) = _$NotificationLoadedCopyWithImpl;
@useResult
$Res call({
 List<NotificationEntity> notifications
});




}
/// @nodoc
class _$NotificationLoadedCopyWithImpl<$Res>
    implements $NotificationLoadedCopyWith<$Res> {
  _$NotificationLoadedCopyWithImpl(this._self, this._then);

  final NotificationLoaded _self;
  final $Res Function(NotificationLoaded) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notifications = null,}) {
  return _then(NotificationLoaded(
null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationEntity>,
  ));
}


}

/// @nodoc


class NotificationMessage implements NotificationState {
  const NotificationMessage(this.message);
  

 final  String message;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationMessageCopyWith<NotificationMessage> get copyWith => _$NotificationMessageCopyWithImpl<NotificationMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationMessage&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NotificationState.message(message: $message)';
}


}

/// @nodoc
abstract mixin class $NotificationMessageCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationMessageCopyWith(NotificationMessage value, $Res Function(NotificationMessage) _then) = _$NotificationMessageCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NotificationMessageCopyWithImpl<$Res>
    implements $NotificationMessageCopyWith<$Res> {
  _$NotificationMessageCopyWithImpl(this._self, this._then);

  final NotificationMessage _self;
  final $Res Function(NotificationMessage) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NotificationMessage(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NotificationError implements NotificationState {
  const NotificationError(this.message);
  

 final  String message;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationErrorCopyWith<NotificationError> get copyWith => _$NotificationErrorCopyWithImpl<NotificationError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NotificationState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $NotificationErrorCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory $NotificationErrorCopyWith(NotificationError value, $Res Function(NotificationError) _then) = _$NotificationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NotificationErrorCopyWithImpl<$Res>
    implements $NotificationErrorCopyWith<$Res> {
  _$NotificationErrorCopyWithImpl(this._self, this._then);

  final NotificationError _self;
  final $Res Function(NotificationError) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NotificationError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
