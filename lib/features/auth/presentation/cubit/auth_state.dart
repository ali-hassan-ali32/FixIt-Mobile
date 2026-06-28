import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/responses/message_response_model.dart';
import '../../domain/entities/auth_user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.loading() = AuthLoading;

  const factory AuthState.success(AuthUser user) = AuthSuccess;

  const factory AuthState.message(String message) = AuthMessage;

  const factory AuthState.error(String message) = AuthError;

  const factory AuthState.forgotPasswordSuccess(
      String message,
      String? token,
      ) = ForgotPasswordSuccess;
}
