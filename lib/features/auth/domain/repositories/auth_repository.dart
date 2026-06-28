import 'package:dartz/dartz.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/login_request.dart';
import '../../data/models/requests/register_customer_request.dart';
import '../../data/models/requests/register_handyman_request.dart';
import '../../data/models/requests/forgot_password_request.dart';
import '../../data/models/requests/reset_password_request.dart';
import '../../data/models/requests/verify_otp_request.dart';
import '../../data/models/responses/message_response_model.dart';
import '../entities/auth_user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> login(
      LoginRequest request,
      );

  Future<Either<Failure, AuthUser>>
  registerCustomer(
      RegisterCustomerRequest request,
      );

  Future<Either<Failure, AuthUser>>
  registerHandyman(
      RegisterHandymanRequest request,
      );

  Future<Either<Failure, MessageResponseModel>>
  forgotPassword(
      ForgotPasswordRequest request,
      );

  Future<Either<Failure, String>>
  resetPassword(
      ResetPasswordRequest request,
      );

  Future<Either<Failure, String>> verifyOtp(VerifyOtpRequest request,);
}