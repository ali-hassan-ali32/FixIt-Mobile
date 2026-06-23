// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_request_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRequestDetailsModel _$CustomerRequestDetailsModelFromJson(
  Map<String, dynamic> json,
) => CustomerRequestDetailsModel(
  id: json['id'] as String,
  handymanName: json['handymanName'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  status: json['status'] as String,
  address: json['address'] as String,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  imageUrls: (json['imageUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CustomerRequestDetailsModelToJson(
  CustomerRequestDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'handymanName': instance.handymanName,
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'address': instance.address,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'imageUrls': instance.imageUrls,
  'createdAt': instance.createdAt.toIso8601String(),
};
