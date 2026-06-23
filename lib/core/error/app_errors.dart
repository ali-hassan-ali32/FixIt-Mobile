abstract class AppErrors {

  // 🌐 Network Errors
  static const String connectionTimeout = 'connectionTimeout';
  static const String sendTimeout = 'sendTimeout';
  static const String receiveTimeout = 'receiveTimeout';
  static const String badCertificate = 'badCertificate';
  static const String badResponse = 'badResponse';
  static const String noResponse = 'noResponse';
  static const String failedToParseResponse = 'failedToParseResponse';
  static const String dioErrorCancel = 'dioErrorCancel';
  static const String connectionError = 'connectionError';
  static const String unknownError = 'unknownError';
  static const String unknown = 'unknown';

  // 📝 Validation Errors
  static const String emailIsRequired = 'emailIsRequired';
  static const String enterValidEmail = 'enterValidEmail';
  static const String passwordIsRequired = 'passwordIsRequired';
  static const String passwordNotMatched = 'passwordNotMatched';
  static const String thisFieldIsRequired = 'thisFieldIsRequired';
  static const String enterValidUsername = 'enterValidUsername';
  static const String enterNumbersOnly = 'enterNumbersOnly';
  static const String enterValueMustEqual11Digit = 'enterValueMustEqual11Digit';
  static const String enterValidEgyptianPhoneNumber = 'enterValidEgyptianPhoneNumber';
}