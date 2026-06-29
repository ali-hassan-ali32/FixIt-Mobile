// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_service_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateServiceRequest _$CreateServiceRequestFromJson(
  Map<String, dynamic> json,
) => CreateServiceRequest(
  categoryId: json['categoryId'] as String,
  cityId: json['cityId'] as String,
  regionId: json['regionId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  addressLine: json['addressLine'] as String,
  scheduledAtUtc: DateTime.parse(json['scheduledAtUtc'] as String),
  estimatedDurationInMinutes: (json['estimatedDurationInMinutes'] as num)
      .toInt(),
  images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
  handymanId: json['handymanId'] as String?,
);

Map<String, dynamic> _$CreateServiceRequestToJson(
  CreateServiceRequest instance,
) => <String, dynamic>{
  'handymanId': ?instance.handymanId,
  'categoryId': instance.categoryId,
  'cityId': instance.cityId,
  'regionId': instance.regionId,
  'title': instance.title,
  'description': instance.description,
  'addressLine': instance.addressLine,
  'scheduledAtUtc': instance.scheduledAtUtc.toIso8601String(),
  'estimatedDurationInMinutes': instance.estimatedDurationInMinutes,
  'images': instance.images,
};
