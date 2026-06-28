import 'package:dio/dio.dart';

String extractErrorMessage(
    DioException e,
    String defaultMessage,
    ) {
  final data = e.response?.data;

  if (e.type == DioExceptionType.connectionError) {
    return 'No internet connection. Please check your network and try again.';
  }

  if (e.type == DioExceptionType.connectionTimeout) {
    return 'Connection timed out. Please try again.';
  }

  if (e.type == DioExceptionType.receiveTimeout) {
    return 'Server took too long to respond.';
  }

  if (e.type == DioExceptionType.sendTimeout) {
    return 'Request timed out. Please try again.';
  }

  if (data is Map<String, dynamic>) {
    final errors = data['Errors'];

    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
  }

  if(data == null) {
    return defaultMessage;
  }

  return defaultMessage;
}