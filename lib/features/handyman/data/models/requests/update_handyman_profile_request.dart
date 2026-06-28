import 'package:json_annotation/json_annotation.dart';

part 'update_handyman_profile_request.g.dart';

@JsonSerializable()
class UpdateHandymanProfileRequest {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatar;
  final String? bio;
  final double? basePrice;
  final bool? isAvailable;

  const UpdateHandymanProfileRequest({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatar,
    this.bio,
    this.basePrice,
    this.isAvailable,
  });

  factory UpdateHandymanProfileRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$UpdateHandymanProfileRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$UpdateHandymanProfileRequestToJson(this);
}