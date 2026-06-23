import 'package:json_annotation/json_annotation.dart';

part 'register_handyman_request.g.dart';

@JsonSerializable()
class RegisterHandymanRequest {
  final String fullName;
  final String phoneNumber;
  final String email;

  final String password;
  final String confirmPassword;

  final DateTime birthDate;

  final String cityId;
  final String regionId;

  final String addressLine;

  final String categoryId;

  final int yearsOfExperience;

  final String nationalIdImageUrl;

  const RegisterHandymanRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.birthDate,
    required this.cityId,
    required this.regionId,
    required this.addressLine,
    required this.categoryId,
    required this.yearsOfExperience,
    required this.nationalIdImageUrl,
  });

  factory RegisterHandymanRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$RegisterHandymanRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$RegisterHandymanRequestToJson(
        this,
      );
}