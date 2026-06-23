// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CustomerState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CustomerState()';
}


}

/// @nodoc
class $CustomerStateCopyWith<$Res>  {
$CustomerStateCopyWith(CustomerState _, $Res Function(CustomerState) __);
}


/// Adds pattern-matching-related methods to [CustomerState].
extension CustomerStatePatterns on CustomerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CustomerInitial value)?  initial,TResult Function( CustomerLoading value)?  loading,TResult Function( CustomerProfileLoaded value)?  profileLoaded,TResult Function( CustomerRequestsLoaded value)?  requestsLoaded,TResult Function( CustomerRequestDetailsLoaded value)?  requestDetailsLoaded,TResult Function( CustomerStatisticsLoaded value)?  statisticsLoaded,TResult Function( CustomerMessage value)?  message,TResult Function( CustomerError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CustomerInitial() when initial != null:
return initial(_that);case CustomerLoading() when loading != null:
return loading(_that);case CustomerProfileLoaded() when profileLoaded != null:
return profileLoaded(_that);case CustomerRequestsLoaded() when requestsLoaded != null:
return requestsLoaded(_that);case CustomerRequestDetailsLoaded() when requestDetailsLoaded != null:
return requestDetailsLoaded(_that);case CustomerStatisticsLoaded() when statisticsLoaded != null:
return statisticsLoaded(_that);case CustomerMessage() when message != null:
return message(_that);case CustomerError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CustomerInitial value)  initial,required TResult Function( CustomerLoading value)  loading,required TResult Function( CustomerProfileLoaded value)  profileLoaded,required TResult Function( CustomerRequestsLoaded value)  requestsLoaded,required TResult Function( CustomerRequestDetailsLoaded value)  requestDetailsLoaded,required TResult Function( CustomerStatisticsLoaded value)  statisticsLoaded,required TResult Function( CustomerMessage value)  message,required TResult Function( CustomerError value)  error,}){
final _that = this;
switch (_that) {
case CustomerInitial():
return initial(_that);case CustomerLoading():
return loading(_that);case CustomerProfileLoaded():
return profileLoaded(_that);case CustomerRequestsLoaded():
return requestsLoaded(_that);case CustomerRequestDetailsLoaded():
return requestDetailsLoaded(_that);case CustomerStatisticsLoaded():
return statisticsLoaded(_that);case CustomerMessage():
return message(_that);case CustomerError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CustomerInitial value)?  initial,TResult? Function( CustomerLoading value)?  loading,TResult? Function( CustomerProfileLoaded value)?  profileLoaded,TResult? Function( CustomerRequestsLoaded value)?  requestsLoaded,TResult? Function( CustomerRequestDetailsLoaded value)?  requestDetailsLoaded,TResult? Function( CustomerStatisticsLoaded value)?  statisticsLoaded,TResult? Function( CustomerMessage value)?  message,TResult? Function( CustomerError value)?  error,}){
final _that = this;
switch (_that) {
case CustomerInitial() when initial != null:
return initial(_that);case CustomerLoading() when loading != null:
return loading(_that);case CustomerProfileLoaded() when profileLoaded != null:
return profileLoaded(_that);case CustomerRequestsLoaded() when requestsLoaded != null:
return requestsLoaded(_that);case CustomerRequestDetailsLoaded() when requestDetailsLoaded != null:
return requestDetailsLoaded(_that);case CustomerStatisticsLoaded() when statisticsLoaded != null:
return statisticsLoaded(_that);case CustomerMessage() when message != null:
return message(_that);case CustomerError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( CustomerProfileEntity profile)?  profileLoaded,TResult Function( List<CustomerRequestSummaryEntity> requests)?  requestsLoaded,TResult Function( CustomerRequestDetailsEntity request)?  requestDetailsLoaded,TResult Function( CustomerStatisticsEntity statistics)?  statisticsLoaded,TResult Function( String message)?  message,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CustomerInitial() when initial != null:
return initial();case CustomerLoading() when loading != null:
return loading();case CustomerProfileLoaded() when profileLoaded != null:
return profileLoaded(_that.profile);case CustomerRequestsLoaded() when requestsLoaded != null:
return requestsLoaded(_that.requests);case CustomerRequestDetailsLoaded() when requestDetailsLoaded != null:
return requestDetailsLoaded(_that.request);case CustomerStatisticsLoaded() when statisticsLoaded != null:
return statisticsLoaded(_that.statistics);case CustomerMessage() when message != null:
return message(_that.message);case CustomerError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( CustomerProfileEntity profile)  profileLoaded,required TResult Function( List<CustomerRequestSummaryEntity> requests)  requestsLoaded,required TResult Function( CustomerRequestDetailsEntity request)  requestDetailsLoaded,required TResult Function( CustomerStatisticsEntity statistics)  statisticsLoaded,required TResult Function( String message)  message,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case CustomerInitial():
return initial();case CustomerLoading():
return loading();case CustomerProfileLoaded():
return profileLoaded(_that.profile);case CustomerRequestsLoaded():
return requestsLoaded(_that.requests);case CustomerRequestDetailsLoaded():
return requestDetailsLoaded(_that.request);case CustomerStatisticsLoaded():
return statisticsLoaded(_that.statistics);case CustomerMessage():
return message(_that.message);case CustomerError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( CustomerProfileEntity profile)?  profileLoaded,TResult? Function( List<CustomerRequestSummaryEntity> requests)?  requestsLoaded,TResult? Function( CustomerRequestDetailsEntity request)?  requestDetailsLoaded,TResult? Function( CustomerStatisticsEntity statistics)?  statisticsLoaded,TResult? Function( String message)?  message,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case CustomerInitial() when initial != null:
return initial();case CustomerLoading() when loading != null:
return loading();case CustomerProfileLoaded() when profileLoaded != null:
return profileLoaded(_that.profile);case CustomerRequestsLoaded() when requestsLoaded != null:
return requestsLoaded(_that.requests);case CustomerRequestDetailsLoaded() when requestDetailsLoaded != null:
return requestDetailsLoaded(_that.request);case CustomerStatisticsLoaded() when statisticsLoaded != null:
return statisticsLoaded(_that.statistics);case CustomerMessage() when message != null:
return message(_that.message);case CustomerError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class CustomerInitial implements CustomerState {
  const CustomerInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CustomerState.initial()';
}


}




/// @nodoc


class CustomerLoading implements CustomerState {
  const CustomerLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CustomerState.loading()';
}


}




/// @nodoc


class CustomerProfileLoaded implements CustomerState {
  const CustomerProfileLoaded(this.profile);
  

 final  CustomerProfileEntity profile;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerProfileLoadedCopyWith<CustomerProfileLoaded> get copyWith => _$CustomerProfileLoadedCopyWithImpl<CustomerProfileLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerProfileLoaded&&(identical(other.profile, profile) || other.profile == profile));
}


@override
int get hashCode => Object.hash(runtimeType,profile);

@override
String toString() {
  return 'CustomerState.profileLoaded(profile: $profile)';
}


}

/// @nodoc
abstract mixin class $CustomerProfileLoadedCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerProfileLoadedCopyWith(CustomerProfileLoaded value, $Res Function(CustomerProfileLoaded) _then) = _$CustomerProfileLoadedCopyWithImpl;
@useResult
$Res call({
 CustomerProfileEntity profile
});




}
/// @nodoc
class _$CustomerProfileLoadedCopyWithImpl<$Res>
    implements $CustomerProfileLoadedCopyWith<$Res> {
  _$CustomerProfileLoadedCopyWithImpl(this._self, this._then);

  final CustomerProfileLoaded _self;
  final $Res Function(CustomerProfileLoaded) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profile = null,}) {
  return _then(CustomerProfileLoaded(
null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as CustomerProfileEntity,
  ));
}


}

/// @nodoc


class CustomerRequestsLoaded implements CustomerState {
  const CustomerRequestsLoaded(final  List<CustomerRequestSummaryEntity> requests): _requests = requests;
  

 final  List<CustomerRequestSummaryEntity> _requests;
 List<CustomerRequestSummaryEntity> get requests {
  if (_requests is EqualUnmodifiableListView) return _requests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_requests);
}


/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerRequestsLoadedCopyWith<CustomerRequestsLoaded> get copyWith => _$CustomerRequestsLoadedCopyWithImpl<CustomerRequestsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerRequestsLoaded&&const DeepCollectionEquality().equals(other._requests, _requests));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_requests));

@override
String toString() {
  return 'CustomerState.requestsLoaded(requests: $requests)';
}


}

/// @nodoc
abstract mixin class $CustomerRequestsLoadedCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerRequestsLoadedCopyWith(CustomerRequestsLoaded value, $Res Function(CustomerRequestsLoaded) _then) = _$CustomerRequestsLoadedCopyWithImpl;
@useResult
$Res call({
 List<CustomerRequestSummaryEntity> requests
});




}
/// @nodoc
class _$CustomerRequestsLoadedCopyWithImpl<$Res>
    implements $CustomerRequestsLoadedCopyWith<$Res> {
  _$CustomerRequestsLoadedCopyWithImpl(this._self, this._then);

  final CustomerRequestsLoaded _self;
  final $Res Function(CustomerRequestsLoaded) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? requests = null,}) {
  return _then(CustomerRequestsLoaded(
null == requests ? _self._requests : requests // ignore: cast_nullable_to_non_nullable
as List<CustomerRequestSummaryEntity>,
  ));
}


}

/// @nodoc


class CustomerRequestDetailsLoaded implements CustomerState {
  const CustomerRequestDetailsLoaded(this.request);
  

 final  CustomerRequestDetailsEntity request;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerRequestDetailsLoadedCopyWith<CustomerRequestDetailsLoaded> get copyWith => _$CustomerRequestDetailsLoadedCopyWithImpl<CustomerRequestDetailsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerRequestDetailsLoaded&&(identical(other.request, request) || other.request == request));
}


@override
int get hashCode => Object.hash(runtimeType,request);

@override
String toString() {
  return 'CustomerState.requestDetailsLoaded(request: $request)';
}


}

/// @nodoc
abstract mixin class $CustomerRequestDetailsLoadedCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerRequestDetailsLoadedCopyWith(CustomerRequestDetailsLoaded value, $Res Function(CustomerRequestDetailsLoaded) _then) = _$CustomerRequestDetailsLoadedCopyWithImpl;
@useResult
$Res call({
 CustomerRequestDetailsEntity request
});




}
/// @nodoc
class _$CustomerRequestDetailsLoadedCopyWithImpl<$Res>
    implements $CustomerRequestDetailsLoadedCopyWith<$Res> {
  _$CustomerRequestDetailsLoadedCopyWithImpl(this._self, this._then);

  final CustomerRequestDetailsLoaded _self;
  final $Res Function(CustomerRequestDetailsLoaded) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? request = null,}) {
  return _then(CustomerRequestDetailsLoaded(
null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as CustomerRequestDetailsEntity,
  ));
}


}

/// @nodoc


class CustomerStatisticsLoaded implements CustomerState {
  const CustomerStatisticsLoaded(this.statistics);
  

 final  CustomerStatisticsEntity statistics;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerStatisticsLoadedCopyWith<CustomerStatisticsLoaded> get copyWith => _$CustomerStatisticsLoadedCopyWithImpl<CustomerStatisticsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerStatisticsLoaded&&(identical(other.statistics, statistics) || other.statistics == statistics));
}


@override
int get hashCode => Object.hash(runtimeType,statistics);

@override
String toString() {
  return 'CustomerState.statisticsLoaded(statistics: $statistics)';
}


}

/// @nodoc
abstract mixin class $CustomerStatisticsLoadedCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerStatisticsLoadedCopyWith(CustomerStatisticsLoaded value, $Res Function(CustomerStatisticsLoaded) _then) = _$CustomerStatisticsLoadedCopyWithImpl;
@useResult
$Res call({
 CustomerStatisticsEntity statistics
});




}
/// @nodoc
class _$CustomerStatisticsLoadedCopyWithImpl<$Res>
    implements $CustomerStatisticsLoadedCopyWith<$Res> {
  _$CustomerStatisticsLoadedCopyWithImpl(this._self, this._then);

  final CustomerStatisticsLoaded _self;
  final $Res Function(CustomerStatisticsLoaded) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statistics = null,}) {
  return _then(CustomerStatisticsLoaded(
null == statistics ? _self.statistics : statistics // ignore: cast_nullable_to_non_nullable
as CustomerStatisticsEntity,
  ));
}


}

/// @nodoc


class CustomerMessage implements CustomerState {
  const CustomerMessage(this.message);
  

 final  String message;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerMessageCopyWith<CustomerMessage> get copyWith => _$CustomerMessageCopyWithImpl<CustomerMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerMessage&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CustomerState.message(message: $message)';
}


}

/// @nodoc
abstract mixin class $CustomerMessageCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerMessageCopyWith(CustomerMessage value, $Res Function(CustomerMessage) _then) = _$CustomerMessageCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CustomerMessageCopyWithImpl<$Res>
    implements $CustomerMessageCopyWith<$Res> {
  _$CustomerMessageCopyWithImpl(this._self, this._then);

  final CustomerMessage _self;
  final $Res Function(CustomerMessage) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CustomerMessage(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CustomerError implements CustomerState {
  const CustomerError(this.message);
  

 final  String message;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerErrorCopyWith<CustomerError> get copyWith => _$CustomerErrorCopyWithImpl<CustomerError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'CustomerState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $CustomerErrorCopyWith<$Res> implements $CustomerStateCopyWith<$Res> {
  factory $CustomerErrorCopyWith(CustomerError value, $Res Function(CustomerError) _then) = _$CustomerErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$CustomerErrorCopyWithImpl<$Res>
    implements $CustomerErrorCopyWith<$Res> {
  _$CustomerErrorCopyWithImpl(this._self, this._then);

  final CustomerError _self;
  final $Res Function(CustomerError) _then;

/// Create a copy of CustomerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(CustomerError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
