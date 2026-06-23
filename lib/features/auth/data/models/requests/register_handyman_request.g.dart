// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_handyman_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterHandymanRequest _$RegisterHandymanRequestFromJson(
  Map<String, dynamic> json,
) => RegisterHandymanRequest(
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  confirmPassword: json['confirmPassword'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  cityId: json['cityId'] as String,
  regionId: json['regionId'] as String,
  addressLine: json['addressLine'] as String,
  categoryId: json['categoryId'] as String,
  yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
  nationalIdImageUrl: json['nationalIdImageUrl'] as String,
);

Map<String, dynamic> _$RegisterHandymanRequestToJson(
  RegisterHandymanRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phoneNumber': instance.phoneNumber,
  'email': instance.email,
  'password': instance.password,
  'confirmPassword': instance.confirmPassword,
  'birthDate': instance.birthDate.toIso8601String(),
  'cityId': instance.cityId,
  'regionId': instance.regionId,
  'addressLine': instance.addressLine,
  'categoryId': instance.categoryId,
  'yearsOfExperience': instance.yearsOfExperience,
  'nationalIdImageUrl': instance.nationalIdImageUrl,
};
