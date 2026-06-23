import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/customer_request_summary_entity.dart';

part 'customer_request_summary_model.g.dart';

@JsonSerializable()
class CustomerRequestSummaryModel {
  final String id;
  final String title;
  final String status;
  final String? handymanName;
  final DateTime scheduledAt;
  final String location;

  const CustomerRequestSummaryModel({
    required this.id,
    required this.title,
    required this.status,
    required this.handymanName,
    required this.scheduledAt,
    required this.location,
  });

  factory CustomerRequestSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CustomerRequestSummaryModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$CustomerRequestSummaryModelToJson(
        this,
      );

  CustomerRequestSummaryEntity toEntity() {
    return CustomerRequestSummaryEntity(
      id: id,
      title: title,
      status: status,
      handymanName: handymanName,
      scheduledAt: scheduledAt,
      location: location,
    );
  }
}