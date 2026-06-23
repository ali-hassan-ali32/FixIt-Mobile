sealed class AppRoutes {
  // Auth
  static const String splash                          = '/';
  static const String home                            = '/home';
  static const String login                           = '/auth-login';
  static const String signUp                          = '/signUp';
  static const String forgotPassword                  = '/forgot-password';
  static const String chooseRole                      = '/choose-role';
  static const String otp                             = '/otp';
  static const String registerCustomer                = '/register-customer';
  static const String registerHandyman                = '/register-handyman';
  static const String handymanApprovalPending         = '/handyman-approval-pending';
  static const String resetPassword                   = '/auth-reset-password';


  // Shared
  static const String sharedHelpSupport               = '/help-support';
  static const String sharedContactUs                 = '/contact-us';
  static const String sharedFaqBooking                = '/faq-booking';
  static const String sharedFaqPayment                = '/faq-payment';
  static const String sharedFaqCancellation           = '/faq-cancellation';
  static const String sharedFaqQuality                = '/faq-quality';

  // Customer
  static const String customerEditProfileView         = '/customer-edit-profile';
  static const String customerHome                    = '/customer-home';
  static const String customerNotifications           = '/customer-notifications';
  static const String customerBrowseCategories        = '/customer-browse-categories';
  static const String customerProfile                 = '/customer-own-profile';
  static const String customerEditProfile             = '/customer-edit-profile';
  static const String customerViewHandyman            = '/customer-view-handyman';
  static const String customerBookService             = '/customer-book-service';
  static const String customerSearchResults           = '/customer-search-results';
  static const String customerSettings                = '/customer-settings';
  static const String customerTrackRequestPending     = '/customer-track-request-pending';
  static const String customerTrackRequestActive      = '/customer-track-request-active';
  static const String customerTrackRequestCompleted   = '/customer-track-request-completed';
  static const String customerTrackRequestCancelled   = '/customer-track-request-cancelled';
  static const String customerViewHandymanPortfolio   = '/customer-view-handyman-portfolio';
  static const String customerViewHandymanReviews     = '/customer-view-handyman-reviews';
  static const String customerCategorySearchResults   = '/customer-category-search-results';

  // Handyman
  static const String handymanHome                    = '/handyman-home';
  static const String handymanNotifications           = '/handyman-notifications';
  static const String handymanActiveJobs              = '/handyman-active-jobs';
  static const String handymanViewActiveJob           = '/handyman-view-active-job';
  static const String handymanViewNewRequest          = '/handyman-view-new-request';
  static const String handymanProfile                 = '/handyman-own-profile';
  static const String handymanSettings                = '/handyman-settings';
  static const String handymanManagePortfolio         = '/handyman-manage-portfolio';
  static const String handymanOwnReviews              = '/handyman-own-reviews';
  static const String handymanUpdateJobStatus         = '/handyman-update-job-status';
  static const String handymanCompletedJobs           = '/handyman-completed-jobs';
}