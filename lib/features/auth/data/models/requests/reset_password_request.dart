import 'package:json_annotation/json_annotation.dart';

part 'reset_password_request.g.dart';

@JsonSerializable()
class ResetPasswordRequest {
  final String email;

  final String otp;

  final String newPassword;

  final String confirmNewPassword;

  const ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  factory ResetPasswordRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$ResetPasswordRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$ResetPasswordRequestToJson(
        this,
      );
}