class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://lucrative-ladies-resilient.ngrok-free.dev/';

  // ==========================
  // Auth
  // ==========================
  static const String login =
      'api/auth/login';

  static const String registerCustomer =
      'api/auth/register/customer';

  static const String registerHandyman =
      'api/auth/register/handyman';

  static const String forgotPassword =
      'api/auth/forgot-password';

  static const String resetPassword =
      'api/auth/reset-password';

  static const String verifyOtp =
      'api/auth/verify-otp';

  // ==========================
  // Lookups
  // ==========================
  static const String cities = 'api/lookups/cities';

  static const String regions = 'api/lookups/cities/{cityId}/regions';

  static const String categories = 'api/categories';

  // ==========================
  // Customer Profile
  // ==========================
  static const String customerProfile =
      'customers/me';

  // ==========================
  // Customer Requests
  // ==========================
  static const String customerRequests =
      'customers/requests';

  static const String customerRequestDetails =
      'customers/requests/{id}';

  static const String customerCancelRequest =
      'customers/requests/{id}/cancel';

  // ==========================
  // Customer Statistics
  // ==========================
  static const String customerStatistics =
      'customers/statistics';

  // ==========================
  // Customer Notifications
  // ==========================
  static const String readAllNotifications =
      'customers/notifications/read-all';
}