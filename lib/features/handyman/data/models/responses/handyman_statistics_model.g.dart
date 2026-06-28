// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handyman_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandymanStatisticsModel _$HandymanStatisticsModelFromJson(
  Map<String, dynamic> json,
) => HandymanStatisticsModel(
  completedJobs: (json['completedJobs'] as num?)?.toInt(),
  activeJobs: (json['activeJobs'] as num?)?.toInt(),
  pendingJobs: (json['pendingJobs'] as num?)?.toInt(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  averageRating: (json['averageRating'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HandymanStatisticsModelToJson(
  HandymanStatisticsModel instance,
) => <String, dynamic>{
  'completedJobs': instance.completedJobs,
  'activeJobs': instance.activeJobs,
  'pendingJobs': instance.pendingJobs,
  'totalReviews': instance.totalReviews,
  'averageRating': instance.averageRating,
};
