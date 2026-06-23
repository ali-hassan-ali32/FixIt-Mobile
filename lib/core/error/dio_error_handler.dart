import 'package:dio/dio.dart';
import 'app_errors.dart';

String handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return AppErrors.connectionTimeout;

    case DioExceptionType.sendTimeout:
      return AppErrors.sendTimeout;

    case DioExceptionType.receiveTimeout:
      return AppErrors.receiveTimeout;

    case DioExceptionType.badCertificate:
      return AppErrors.badCertificate;

    case DioExceptionType.badResponse:
      return _extractErrorMessageFromResponse(error.response);

    case DioExceptionType.cancel:
      return AppErrors.dioErrorCancel;

    case DioExceptionType.connectionError:
      return AppErrors.connectionError;

    case DioExceptionType.unknown:
      return "${AppErrors.unknownError} ${error.message ?? AppErrors.unknown}";
  }
}

String _extractErrorMessageFromResponse(Response? response) {
  if (response == null) return AppErrors.noResponse;

  try {
    final data = response.data;

    if (data is Map) {
      if (data.containsKey('message')) return data['message'];
      if (data.containsKey('error')) return data['error'];

      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return "${AppErrors.badResponse} [${response.statusCode}].";
  } catch (e) {
    return AppErrors.failedToParseResponse;
  }
}