abstract class AppException implements Exception {
  final String message;
  final Object? originalError;

  const AppException({required this.message, this.originalError});

  @override
  String toString() => '$runtimeType(message: $message, originalError: $originalError)';
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection', super.originalError});
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException({super.message = 'Server error occurred', this.statusCode, super.originalError});
}

class CacheException extends AppException {
  const CacheException({super.message = 'Cache error occurred', super.originalError});
}

class UnauthorizedException extends AppException {
  final int? statusCode;
  const UnauthorizedException({super.message = 'Unauthorized request', this.statusCode, super.originalError});
}

class ForbiddenException extends AppException {
  final int? statusCode;
  const ForbiddenException({super.message = 'Forbidden request', this.statusCode, super.originalError});
}

class NotFoundException extends AppException {
  final int? statusCode;
  const NotFoundException({super.message = 'Requested resource was not found', this.statusCode, super.originalError});
}

class ValidationException extends AppException {
  final int? statusCode;
  const ValidationException({super.message = 'Validation error occurred', this.statusCode, super.originalError});
}

class TimeoutException extends AppException {
  const TimeoutException({super.message = 'Request timeout', super.originalError});
}

class RequestCancelledException extends AppException {
  const RequestCancelledException({super.message = 'Request was cancelled', super.originalError});
}

class UnknownException extends AppException {
  const UnknownException({super.message = 'Something went wrong', super.originalError});
}
