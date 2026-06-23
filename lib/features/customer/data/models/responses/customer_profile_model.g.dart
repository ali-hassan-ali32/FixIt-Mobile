// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerProfileModel _$CustomerProfileModelFromJson(
  Map<String, dynamic> json,
) => CustomerProfileModel(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  avatar: json['avatar'] as String?,
  address: json['address'] as String,
  isVerified: json['isVerified'] as bool,
  memberSince: DateTime.parse(json['memberSince'] as String),
);

Map<String, dynamic> _$CustomerProfileModelToJson(
  CustomerProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'avatar': instance.avatar,
  'address': instance.address,
  'isVerified': instance.isVerified,
  'memberSince': instance.memberSince.toIso8601String(),
};
