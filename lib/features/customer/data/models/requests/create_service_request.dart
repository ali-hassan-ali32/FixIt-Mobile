import 'package:json_annotation/json_annotation.dart';

part 'create_service_request.g.dart';

@JsonSerializable()
class CreateServiceRequest {
  final String? handymanId;
  final String categoryId;
  final String cityId;
  final String regionId;
  final String title;
  final String description;
  final String addressLine;
  final DateTime scheduledAtUtc;
  final int estimatedDurationInMinutes;
  final List<String> images;

  const CreateServiceRequest({
    required this.categoryId,
    required this.cityId,
    required this.regionId,
    required this.title,
    required this.description,
    required this.addressLine,
    required this.scheduledAtUtc,
    required this.estimatedDurationInMinutes,
    required this.images,
    this.handymanId,
  });

  factory CreateServiceRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CreateServiceRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$CreateServiceRequestToJson(
        this,
      );
}