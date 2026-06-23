import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../data/models/requests/forgot_password_request.dart';
import '../../data/models/requests/login_request.dart';
import '../../data/models/requests/register_customer_request.dart';
import '../../data/models/requests/register_handyman_request.dart';
import '../../data/models/requests/reset_password_request.dart';
import '../../data/models/requests/verify_otp_request.dart';
import '../../data/models/responses/auth_response_model.dart';
import '../../data/models/responses/message_response_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiConstants.login)
  Future<AuthResponseModel> login(@Body() LoginRequest request);

  @POST(ApiConstants.registerCustomer)
  Future<AuthResponseModel> registerCustomer(
    @Body() RegisterCustomerRequest request,
  );

  @POST(ApiConstants.registerHandyman)
  Future<AuthResponseModel> registerHandyman(
    @Body() RegisterHandymanRequest request,
  );

  @POST(ApiConstants.forgotPassword)
  Future<MessageResponseModel> forgotPassword(
    @Body() ForgotPasswordRequest request,
  );

  @POST(ApiConstants.resetPassword)
  Future<MessageResponseModel> resetPassword(
    @Body() ResetPasswordRequest request,
  );

  @POST('/auth/verify-otp')
  Future<MessageResponseModel> verifyOtp(@Body() VerifyOtpRequest request);
}
