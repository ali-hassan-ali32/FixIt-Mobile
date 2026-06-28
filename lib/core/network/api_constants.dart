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
  //  Notifications
  // ==========================
  static const getNotifications = '/notifications';

  static const readNotification =
      '/notifications/{id}/read';

  static const readAllNotifications =
      '/notifications/read-all';

  static const deleteNotification =
      '/notifications/{id}';




  // Handyman Profile
  static const String handymanProfile = 'handymen/me';

  // Handyman Jobs
  static const String handymanJobs = 'handymen/me/jobs';

  static const String handymanJobDetails = 'handymen/jobs/{id}';

  static const String handymanUpdateJobStatus = 'handymen/jobs/{id}/status';

  // Handyman Reviews
  static const String handymanReviews = 'handymen/me/reviews';

  // Available Requests
  static const String handymanAvailableRequests = 'handymen/me/pending-jobs';


  static const String handymanStatistics =
      'handymen/me/statistics';

  static const String handymanPortfolio =
      'handymen/me/portfolio';

  static const String handymanDeletePortfolio =
      'handymen/me/portfolio/{id}';







  static const customerHandymen = '/customers/handymen';

  static const customerFeaturedHandymen =
      '/customers/featured-handymen';

  static const customerHandymanDetails =
      '/customers/handymen/{handymanId}';

  static const customerHandymanPortfolio =
      '/customers/handymen/{handymanId}/portfolio';


  static const customerHandymanReviews =
      '/customers/handymen/{handymanId}/reviews';

  static const customerAddReview =
      '/customers/requests/{requestId}/review';

  static const customerReviews =
      '/customers/reviews';
}