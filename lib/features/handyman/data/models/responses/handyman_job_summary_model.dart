import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/handyman_job_summary_entity.dart';

part 'handyman_job_summary_model.g.dart';

@JsonSerializable()
class HandymanJobSummaryModel {
  final String id;
  final String? title;
  final String? description;
  final String? category;
  final String? location;
  final DateTime? scheduledDate;
  // final double? price;
  final String? estimatedDuration;
  final String? status;
  final String? customerName;

  const HandymanJobSummaryModel({
    required this.id,
    this.title,
    this.description,
    this.category,
    this.location,
    this.scheduledDate,
    // this.price,
    this.estimatedDuration,
    this.status,
    this.customerName,
  });

  factory HandymanJobSummaryModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanJobSummaryModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HandymanJobSummaryModelToJson(this);

  HandymanJobSummaryEntity toEntity() {
    return HandymanJobSummaryEntity(
      id: id,
      title: title ?? '-',
      description: description ?? '-',
      category: category ?? '-',
      location: location ?? '-',
      scheduledDate: scheduledDate ?? DateTime.now(),
      // price: price ?? 0,
      estimatedDuration: estimatedDuration ?? '-',
      status: status ?? '-',
      customerName: customerName ?? '-',
    );
  }
}