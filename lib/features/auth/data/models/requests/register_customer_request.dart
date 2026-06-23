import 'package:json_annotation/json_annotation.dart';

part 'register_customer_request.g.dart';

@JsonSerializable()
class RegisterCustomerRequest {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final String confirmPassword;

  final DateTime birthDate;

  final String cityId;
  final String regionId;

  final String addressLine;

  const RegisterCustomerRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.birthDate,
    required this.cityId,
    required this.regionId,
    required this.addressLine,
  });

  factory RegisterCustomerRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$RegisterCustomerRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$RegisterCustomerRequestToJson(
        this,
      );
}