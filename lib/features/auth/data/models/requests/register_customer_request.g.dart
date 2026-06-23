// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_customer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterCustomerRequest _$RegisterCustomerRequestFromJson(
  Map<String, dynamic> json,
) => RegisterCustomerRequest(
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  confirmPassword: json['confirmPassword'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  cityId: json['cityId'] as String,
  regionId: json['regionId'] as String,
  addressLine: json['addressLine'] as String,
);

Map<String, dynamic> _$RegisterCustomerRequestToJson(
  RegisterCustomerRequest instance,
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
};
