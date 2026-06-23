import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/customer_statistics_entity.dart';

part 'customer_statistics_model.g.dart';

@JsonSerializable()
class CustomerStatisticsModel {
  final int totalRequests;
  final int pendingRequests;
  final int completedRequests;
  final int cancelledRequests;
  final int totalReviews;

  const CustomerStatisticsModel({
    required this.totalRequests,
    required this.pendingRequests,
    required this.completedRequests,
    required this.cancelledRequests,
    required this.totalReviews,
  });

  factory CustomerStatisticsModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CustomerStatisticsModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$CustomerStatisticsModelToJson(
        this,
      );

  CustomerStatisticsEntity toEntity() {
    return CustomerStatisticsEntity(
      totalRequests: totalRequests,
      pendingRequests: pendingRequests,
      completedRequests: completedRequests,
      cancelledRequests: cancelledRequests,
      totalReviews: totalReviews,
    );
  }
}