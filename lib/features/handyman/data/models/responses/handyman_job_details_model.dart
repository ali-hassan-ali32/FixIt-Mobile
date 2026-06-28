import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/handyman_job_details_entity.dart';

part 'handyman_job_details_model.g.dart';

@JsonSerializable()
class HandymanJobDetailsModel {
  final String id;
  final String? title;
  final String? description;
  final String? category;
  final String? location;
  final DateTime? scheduledDate;
  // final double? price;
  final int? estimatedDurationInMinutes;
  final String? status;
  final String? customerName;
  final List<String>? images;

  const HandymanJobDetailsModel({
    required this.id,
    this.title,
    this.description,
    this.category,
    this.location,
    this.scheduledDate,
    // this.price,
    this.estimatedDurationInMinutes,
    this.status,
    this.customerName,
    this.images,
  });

  factory HandymanJobDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanJobDetailsModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HandymanJobDetailsModelToJson(this);

  HandymanJobDetailsEntity toEntity() {
    return HandymanJobDetailsEntity(
      id: id,
      title: title ?? '-',
      description: description ?? '-',
      category: category ?? '-',
      location: location ?? '-',
      scheduledDate: scheduledDate ?? DateTime.now(),
      // price: price ?? 0,
      estimatedDurationInMinutes:
      estimatedDurationInMinutes ?? 0,
      status: status ?? '-',
      customerName: customerName ?? '-',
      images: images ?? [],
    );
  }
}