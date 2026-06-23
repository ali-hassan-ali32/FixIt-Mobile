import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/api/services/auth_api_service.dart';
import '../../features/customer/api/services/customer_api_service.dart';
import '../../features/lookups/api/services/lookup_api_service.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';

@lazySingleton
class DioFactory {
  final AuthInterceptor authInterceptor;

  DioFactory(this.authInterceptor);

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(authInterceptor);

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }

  @lazySingleton
  AuthApiService authApiService(Dio dio) => AuthApiService(dio);

  @lazySingleton
  LookupApiService lookupApiService(Dio dio) => LookupApiService(dio);

  @lazySingleton
  CustomerApiService customerApiService(Dio dio,) => CustomerApiService(dio);
}
