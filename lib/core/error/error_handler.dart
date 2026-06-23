import 'package:dio/dio.dart';

import 'app_exception.dart';
import 'failure.dart';

abstract final class ErrorHandler {
  static Failure handle(Object error) {
    if (error is Failure) return error;
    if (error is AppException) return _handleAppException(error);
    if (error is DioException) return _handleDioException(error);
    return Failure.unknown(originalError: error);
  }

  static Failure _handleAppException(AppException exception) {
    if (exception is NetworkException) {
      return Failure.network(message: exception.message, originalError: exception.originalError);
    }
    if (exception is ServerException) {
      return Failure.server(message: exception.message, statusCode: exception.statusCode, originalError: exception.originalError);
    }
    if (exception is CacheException) {
      return Failure.cache(message: exception.message, originalError: exception.originalError);
    }
    if (exception is UnauthorizedException) {
      return Failure.unauthorized(message: exception.message, statusCode: exception.statusCode, originalError: exception.originalError);
    }
    if (exception is ForbiddenException) {
      return Failure.forbidden(message: exception.message, statusCode: exception.statusCode, originalError: exception.originalError);
    }
    if (exception is NotFoundException) {
      return Failure.notFound(message: exception.message, statusCode: exception.statusCode, originalError: exception.originalError);
    }
    if (exception is ValidationException) {
      return Failure.validation(message: exception.message, statusCode: exception.statusCode, originalError: exception.originalError);
    }
    if (exception is TimeoutException) {
      return Failure.timeout(message: exception.message, originalError: exception.originalError);
    }
    if (exception is RequestCancelledException) {
      return Failure.cancel(message: exception.message, originalError: exception.originalError);
    }
    return Failure.unknown(message: exception.message, originalError: exception.originalError);
  }

  static Failure _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure.timeout(message: 'Request timeout. Please try again.', originalError: exception);
      case DioExceptionType.badCertificate:
        return Failure.server(message: 'Bad certificate. Please try again later.', originalError: exception);
      case DioExceptionType.badResponse:
        return _handleBadResponse(exception);
      case DioExceptionType.cancel:
        return Failure.cancel(originalError: exception);
      case DioExceptionType.connectionError:
        return Failure.network(originalError: exception);
      case DioExceptionType.unknown:
        return Failure.unknown(message: exception.message ?? 'Something went wrong', originalError: exception);
    }
  }

  static Failure _handleBadResponse(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final message = _extractErrorMessage(exception);

    if (statusCode == 400) return Failure.validation(message: message, statusCode: statusCode, originalError: exception);
    if (statusCode == 401) return Failure.unauthorized(message: message, statusCode: statusCode, originalError: exception);
    if (statusCode == 403) return Failure.forbidden(message: message, statusCode: statusCode, originalError: exception);
    if (statusCode == 404) return Failure.notFound(message: message, statusCode: statusCode, originalError: exception);
    if (statusCode != null && statusCode >= 500) return Failure.server(message: message, statusCode: statusCode, originalError: exception);

    return Failure.unknown(message: message, statusCode: statusCode, originalError: exception);
  }

  static String _extractErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    final message = exception.message;
    if (message != null && message.trim().isNotEmpty) return message;
    return 'Something went wrong';
  }
}
