import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/customer_profile_entity.dart';

part 'customer_profile_model.g.dart';

@JsonSerializable()
class CustomerProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatar;
  final String address;
  final bool isVerified;
  final DateTime memberSince;

  const CustomerProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.avatar,
    required this.address,
    required this.isVerified,
    required this.memberSince,
  });

  factory CustomerProfileModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$CustomerProfileModelFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$CustomerProfileModelToJson(
        this,
      );

  CustomerProfileEntity toEntity() {
    return CustomerProfileEntity(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      avatar: avatar,
      address: address,
      isVerified: isVerified,
      memberSince: memberSince,
    );
  }
}