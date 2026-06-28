// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_handyman_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateHandymanProfileRequest _$UpdateHandymanProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateHandymanProfileRequest(
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatar: json['avatar'] as String?,
  bio: json['bio'] as String?,
  basePrice: (json['basePrice'] as num?)?.toDouble(),
  isAvailable: json['isAvailable'] as bool?,
);

Map<String, dynamic> _$UpdateHandymanProfileRequestToJson(
  UpdateHandymanProfileRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'avatar': instance.avatar,
  'bio': instance.bio,
  'basePrice': instance.basePrice,
  'isAvailable': instance.isAvailable,
};
