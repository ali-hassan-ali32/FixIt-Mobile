enum FailureType {
  network,
  server,
  cache,
  unauthorized,
  forbidden,
  notFound,
  validation,
  timeout,
  cancel,
  unknown,
}

class Failure {
  final String message;
  final FailureType type;
  final int? statusCode;
  final Object? originalError;

  const Failure({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  factory Failure.network({String message = 'No internet connection', Object? originalError}) {
    return Failure(message: message, type: FailureType.network, originalError: originalError);
  }

  factory Failure.server({String message = 'Server error occurred', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.server, statusCode: statusCode, originalError: originalError);
  }

  factory Failure.cache({String message = 'Cache error occurred', Object? originalError}) {
    return Failure(message: message, type: FailureType.cache, originalError: originalError);
  }

  factory Failure.unauthorized({String message = 'Unauthorized request', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.unauthorized, statusCode: statusCode, originalError: originalError);
  }

  factory Failure.forbidden({String message = 'Forbidden request', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.forbidden, statusCode: statusCode, originalError: originalError);
  }

  factory Failure.notFound({String message = 'Requested resource was not found', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.notFound, statusCode: statusCode, originalError: originalError);
  }

  factory Failure.validation({String message = 'Validation error occurred', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.validation, statusCode: statusCode, originalError: originalError);
  }

  factory Failure.timeout({String message = 'Request timeout', Object? originalError}) {
    return Failure(message: message, type: FailureType.timeout, originalError: originalError);
  }

  factory Failure.cancel({String message = 'Request was cancelled', Object? originalError}) {
    return Failure(message: message, type: FailureType.cancel, originalError: originalError);
  }

  factory Failure.unknown({String message = 'Something went wrong', int? statusCode, Object? originalError}) {
    return Failure(message: message, type: FailureType.unknown, statusCode: statusCode, originalError: originalError);
  }
}
