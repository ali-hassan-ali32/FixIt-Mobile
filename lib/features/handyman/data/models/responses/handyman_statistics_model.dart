import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/handyman_statistics_entity.dart';

part 'handyman_statistics_model.g.dart';

@JsonSerializable()
class HandymanStatisticsModel {
  final int? completedJobs;
  final int? activeJobs;
  final int? pendingJobs;
  final int? totalReviews;
  final double? averageRating;

  const HandymanStatisticsModel({
    required this.completedJobs,
    required this.activeJobs,
    required this.pendingJobs,
    required this.totalReviews,
    required this.averageRating,
  });

  factory HandymanStatisticsModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanStatisticsModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HandymanStatisticsModelToJson(this);

  HandymanStatisticsEntity toEntity() {
    return HandymanStatisticsEntity(
      completedJobs: completedJobs ?? 0,
      activeJobs: activeJobs ?? 0,
      pendingJobs: pendingJobs ?? 0,
      totalReviews: totalReviews ?? 0,
      averageRating: averageRating ?? 0.0,
    );
  }
}