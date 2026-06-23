import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../features/auth/api/services/auth_api_service.dart';

@module
abstract class AuthServiceModule {
  @lazySingleton
  AuthApiService authApiService(Dio dio) {
    return AuthApiService(dio);
  }
}
