import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/handyman_profile_entity.dart';

part 'handyman_profile_model.g.dart';

@JsonSerializable()
class HandymanProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final String? bio;
  final double basePrice;
  final int yearsOfExperience;
  final bool isAvailable;
  final String category;
  final String city;
  final String region;

  const HandymanProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.bio,
    required this.basePrice,
    required this.yearsOfExperience,
    required this.isAvailable,
    required this.category,
    required this.city,
    required this.region,
  });

  factory HandymanProfileModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$HandymanProfileModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HandymanProfileModelToJson(this);

  HandymanProfileEntity toEntity() {
    return HandymanProfileEntity(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      bio: bio,
      basePrice: basePrice,
      yearsOfExperience: yearsOfExperience,
      isAvailable: isAvailable,
      category: category,
      city: city,
      region: region,
    );
  }
}