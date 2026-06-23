// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_request_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerRequestSummaryModel _$CustomerRequestSummaryModelFromJson(
  Map<String, dynamic> json,
) => CustomerRequestSummaryModel(
  id: json['id'] as String,
  title: json['title'] as String,
  status: json['status'] as String,
  handymanName: json['handymanName'] as String?,
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  location: json['location'] as String,
);

Map<String, dynamic> _$CustomerRequestSummaryModelToJson(
  CustomerRequestSummaryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'handymanName': instance.handymanName,
  'scheduledAt': instance.scheduledAt.toIso8601String(),
  'location': instance.location,
};
