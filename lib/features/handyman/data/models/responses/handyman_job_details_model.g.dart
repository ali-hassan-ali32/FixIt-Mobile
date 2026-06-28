// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_job_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanJobDetailsModel _$HandymanJobDetailsModelFromJson(
  Map<String, dynamic> json,
) => HandymanJobDetailsModel(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  location: json['location'] as String?,
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  estimatedDurationInMinutes: (json['estimatedDurationInMinutes'] as num?)
      ?.toInt(),
  status: json['status'] as String?,
  customerName: json['customerName'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$HandymanJobDetailsModelToJson(
  HandymanJobDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'scheduledDate': instance.scheduledDate?.toIso8601String(),
  'estimatedDurationInMinutes': instance.estimatedDurationInMinutes,
  'status': instance.status,
  'customerName': instance.customerName,
  'images': instance.images,
};
