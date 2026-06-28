// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanProfileModel _$HandymanProfileModelFromJson(
  Map<String, dynamic> json,
) => HandymanProfileModel(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  basePrice: (json['basePrice'] as num).toDouble(),
  yearsOfExperience: (json['yearsOfExperience'] as num).toInt(),
  isAvailable: json['isAvailable'] as bool,
  category: json['category'] as String,
  city: json['city'] as String,
  region: json['region'] as String,
);

Map<String, dynamic> _$HandymanProfileModelToJson(
  HandymanProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'basePrice': instance.basePrice,
  'yearsOfExperience': instance.yearsOfExperience,
  'isAvailable': instance.isAvailable,
  'category': instance.category,
  'city': instance.city,
  'region': instance.region,
};
