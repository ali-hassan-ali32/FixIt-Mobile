import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request.g.dart';

@JsonSerializable()
class UpdateProfileRequest {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final String? avatar;

  const UpdateProfileRequest({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    this.avatar,
  });

  factory UpdateProfileRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$UpdateProfileRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$UpdateProfileRequestToJson(
        this,
      );
}