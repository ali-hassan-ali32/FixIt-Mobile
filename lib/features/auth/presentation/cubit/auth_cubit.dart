import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/requests/verify_otp_request.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

import '../../data/models/requests/login_request.dart';
import '../../data/models/requests/register_customer_request.dart';
import '../../data/models/requests/register_handyman_request.dart';
import '../../data/models/requests/forgot_password_request.dart';
import '../../data/models/requests/reset_password_request.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_customer_usecase.dart';
import '../../domain/usecases/register_handyman_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;

  final RegisterCustomerUseCase
  _registerCustomerUseCase;

  final RegisterHandymanUseCase
  _registerHandymanUseCase;

  final ForgotPasswordUseCase
  _forgotPasswordUseCase;

  final ResetPasswordUseCase
  _resetPasswordUseCase;

  final VerifyOtpUseCase
  _verifyOtpUseCase;

  AuthCubit(
      this._loginUseCase,
      this._registerCustomerUseCase,
      this._registerHandymanUseCase,
      this._forgotPasswordUseCase,
      this._resetPasswordUseCase,
      this._verifyOtpUseCase,
      ) : super(
    const AuthState.initial(),
  );

  Future<void> login(
      LoginRequest request,
      ) async {
    emit(
      const AuthState.loading(),
    );

    final result =
    await _loginUseCase(request);

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (user) => emit(
        AuthState.success(user),
      ),
    );
  }

  Future<void> registerCustomer(
      RegisterCustomerRequest request,
      ) async {
    emit(
      const AuthState.loading(),
    );

    final result =
    await _registerCustomerUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (user) => emit(
        AuthState.success(user),
      ),
    );
  }

  Future<void> registerHandyman(
      RegisterHandymanRequest request,
      ) async {
    emit(
      const AuthState.loading(),
    );

    final result =
    await _registerHandymanUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (user) => emit(
        AuthState.success(user),
      ),
    );
  }

  Future<void> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    emit(
      const AuthState.loading(),
    );

    final result =
    await _forgotPasswordUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (response) => emit(
        AuthState.forgotPasswordSuccess(
          response.message ?? 'OTP sent successfully',
          response.token,
        ),
      ),
    );
  }

  Future<void> resetPassword(
      ResetPasswordRequest request,
      ) async {
    emit(
      const AuthState.loading(),
    );

    final result =
    await _resetPasswordUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (message) => emit(
        AuthState.message(
          message,
        ),
      ),
    );
  }

  Future<void> verifyOtp(
      VerifyOtpRequest request,
      ) async {

    emit(
      const AuthState.loading(),
    );

    final result =
    await _verifyOtpUseCase(
      request,
    );

    result.fold(
          (failure) => emit(
        AuthState.error(
          failure.message,
        ),
      ),
          (message) => emit(
        AuthState.message(
          message,
        ),
      ),
    );
  }
}