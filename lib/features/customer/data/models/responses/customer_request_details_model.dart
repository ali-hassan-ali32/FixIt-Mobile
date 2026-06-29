import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/customer_request_details_entity.dart';

part 'customer_request_details_model.g.dart';

@JsonSerializable()
class CustomerRequestDetailsModel {
  final String id;
  final String? handymanId;
  final String? handymanName;
  final String title;
  final String description;
  final String status;
  final String address;
  final DateTime scheduledAt;
  final List<String> imageUrls;
  final DateTime createdAt;

  const CustomerRequestDetailsModel({
    required this.id,
    this.handymanId,
    required this.handymanName,
    required this.title,
    required this.description,
    required this.status,
    required this.address,
    required this.scheduledAt,
    required this.imageUrls,
    required this.createdAt,
  });

  factory CustomerRequestDetailsModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CustomerRequestDetailsModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$CustomerRequestDetailsModelToJson(
        this,
      );

  CustomerRequestDetailsEntity toEntity() {
    return CustomerRequestDetailsEntity(
      id: id,
      handymanId: handymanId,
      handymanName: handymanName,
      title: title,
      description: description,
      status: status,
      address: address,
      scheduledAt: scheduledAt,
      imageUrls: imageUrls,
      createdAt: createdAt,
    );
  }
}