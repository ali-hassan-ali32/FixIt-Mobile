import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/auth_user_entity.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String role;
  final String token;

  const AuthResponseModel({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.role,
    required this.token,
  });

  factory AuthResponseModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AuthResponseModelToJson(this);

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      displayName: displayName,
      phoneNumber: phoneNumber,
      role: role,
      token: token,
    );
  }
}