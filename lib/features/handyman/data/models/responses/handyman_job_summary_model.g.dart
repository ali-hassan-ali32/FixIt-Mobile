// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_job_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanJobSummaryModel _$HandymanJobSummaryModelFromJson(
  Map<String, dynamic> json,
) => HandymanJobSummaryModel(
  id: json['id'] as String,
  title: json['title'] as String?,
  description: json['description'] as String?,
  category: json['category'] as String?,
  location: json['location'] as String?,
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  estimatedDuration: json['estimatedDuration'] as String?,
  status: json['status'] as String?,
  customerName: json['customerName'] as String?,
);

Map<String, dynamic> _$HandymanJobSummaryModelToJson(
  HandymanJobSummaryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'scheduledDate': instance.scheduledDate?.toIso8601String(),
  'estimatedDuration': instance.estimatedDuration,
  'status': instance.status,
  'customerName': instance.customerName,
};
