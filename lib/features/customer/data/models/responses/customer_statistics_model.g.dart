// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerStatisticsModel _$CustomerStatisticsModelFromJson(
  Map<String, dynamic> json,
) => CustomerStatisticsModel(
  totalRequests: (json['totalRequests'] as num).toInt(),
  pendingRequests: (json['pendingRequests'] as num).toInt(),
  completedRequests: (json['completedRequests'] as num).toInt(),
  cancelledRequests: (json['cancelledRequests'] as num).toInt(),
  totalReviews: (json['totalReviews'] as num).toInt(),
);

Map<String, dynamic> _$CustomerStatisticsModelToJson(
  CustomerStatisticsModel instance,
) => <String, dynamic>{
  'totalRequests': instance.totalRequests,
  'pendingRequests': instance.pendingRequests,
  'completedRequests': instance.completedRequests,
  'cancelledRequests': instance.cancelledRequests,
  'totalReviews': instance.totalReviews,
};
