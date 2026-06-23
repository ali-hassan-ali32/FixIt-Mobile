import 'package:injectable/injectable.dart';

import '../models/requests/login_request.dart';
import '../models/requests/register_customer_request.dart';
import '../models/requests/register_handyman_request.dart';
import '../models/requests/forgot_password_request.dart';
import '../models/requests/reset_password_request.dart';

import '../models/requests/verify_otp_request.dart';
import '../models/responses/auth_response_model.dart';
import '../models/responses/message_response_model.dart';
import '../../api/services/auth_api_service.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthApiService _api;

  AuthRemoteDataSourceImpl(this._api);

  @override
  Future<AuthResponseModel> login(LoginRequest request) {
    return _api.login(request);
  }

  @override
  Future<AuthResponseModel> registerCustomer(RegisterCustomerRequest request) {
    return _api.registerCustomer(request);
  }

  @override
  Future<AuthResponseModel> registerHandyman(RegisterHandymanRequest request) {
    return _api.registerHandyman(request);
  }

  @override
  Future<MessageResponseModel> forgotPassword(ForgotPasswordRequest request) {
    return _api.forgotPassword(request);
  }

  @override
  Future<MessageResponseModel> resetPassword(ResetPasswordRequest request) {
    return _api.resetPassword(request);
  }

  @override
  Future<MessageResponseModel> verifyOtp(VerifyOtpRequest request) {
    return _api.verifyOtp(request);
  }
}
