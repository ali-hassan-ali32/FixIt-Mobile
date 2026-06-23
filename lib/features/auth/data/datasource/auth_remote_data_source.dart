import '../models/requests/login_request.dart';
import '../models/requests/register_customer_request.dart';
import '../models/requests/register_handyman_request.dart';
import '../models/requests/forgot_password_request.dart';
import '../models/requests/reset_password_request.dart';

import '../models/requests/verify_otp_request.dart';
import '../models/responses/auth_response_model.dart';
import '../models/responses/message_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(
      LoginRequest request,
      );

  Future<AuthResponseModel>
  registerCustomer(
      RegisterCustomerRequest request,
      );

  Future<AuthResponseModel>
  registerHandyman(
      RegisterHandymanRequest request,
      );

  Future<MessageResponseModel>
  forgotPassword(
      ForgotPasswordRequest request,
      );

  Future<MessageResponseModel>
  resetPassword(
      ResetPasswordRequest request,
      );

  Future<MessageResponseModel> verifyOtp(
      VerifyOtpRequest request,
      );
}