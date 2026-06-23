import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../storage/secure_storage_service.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final SecureStorageService storage;

  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {

    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] =
      'Bearer $token';
    }

    return handler.next(options);
  }
}