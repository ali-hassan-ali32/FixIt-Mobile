import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translation/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FixIt'**
  String get appTitle;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Fix it easily'**
  String get splashTagline;

  /// No description provided for @appLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appLoading;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connecting you with the best technicians in Egypt'**
  String get splashSubtitle;

  /// No description provided for @splashVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get splashVersion;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginWelcomeBack;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address Line'**
  String get addressLine;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @addressLinePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter the Address Line'**
  String get addressLinePlaceholder;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'+20 1XX XXX XXXX'**
  String get phonePlaceholder;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get registerButton;

  /// No description provided for @snackbarSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackbarSuccessTitle;

  /// No description provided for @snackbarErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackbarErrorTitle;

  /// No description provided for @snackbarWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get snackbarWarningTitle;

  /// No description provided for @snackbarInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get snackbarInfoTitle;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egyptian phone number'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordShort;

  /// No description provided for @loginValidationWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete data'**
  String get loginValidationWarningTitle;

  /// No description provided for @loginValidationWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check the entered data'**
  String get loginValidationWarningMessage;

  /// No description provided for @loginSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome! 👋'**
  String get loginSuccessTitle;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'You have successfully signed in'**
  String get loginSuccessMessage;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No worries! Enter your email\nand we\'ll send you a verification code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'example@domain.com'**
  String get emailPlaceholder;

  /// No description provided for @sendOtpButton.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendOtpButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @forgotPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Sent! 📧'**
  String get forgotPasswordSuccessTitle;

  /// No description provided for @forgotPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Verification code has been sent to your email'**
  String get forgotPasswordSuccessMessage;

  /// No description provided for @chooseRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Join FixIt'**
  String get chooseRoleTitle;

  /// No description provided for @chooseRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your account type to continue'**
  String get chooseRoleSubtitle;

  /// No description provided for @chooseRoleInfoBox.
  ///
  /// In en, this message translates to:
  /// **'💡 Choose the right account - you can only create one type of account'**
  String get chooseRoleInfoBox;

  /// No description provided for @customerRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerRoleTitle;

  /// No description provided for @customerRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for maintenance services'**
  String get customerRoleSubtitle;

  /// No description provided for @customerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Register as a customer if you\'re looking for professional technicians to fix and maintain your home or office'**
  String get customerRoleDescription;

  /// No description provided for @customerFeature1.
  ///
  /// In en, this message translates to:
  /// **'🔍 Find technicians'**
  String get customerFeature1;

  /// No description provided for @customerFeature2.
  ///
  /// In en, this message translates to:
  /// **'⭐ Rate the service'**
  String get customerFeature2;

  /// No description provided for @customerFeature3.
  ///
  /// In en, this message translates to:
  /// **'💳 Secure payment'**
  String get customerFeature3;

  /// No description provided for @handymanRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Technician'**
  String get handymanRoleTitle;

  /// No description provided for @handymanRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Providing maintenance services'**
  String get handymanRoleSubtitle;

  /// No description provided for @handymanRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Register as a technician if you provide maintenance and repair services and want to reach new customers'**
  String get handymanRoleDescription;

  /// No description provided for @handymanFeature1.
  ///
  /// In en, this message translates to:
  /// **'💼 Get requests'**
  String get handymanFeature1;

  /// No description provided for @handymanFeature2.
  ///
  /// In en, this message translates to:
  /// **'💰 Extra income'**
  String get handymanFeature2;

  /// No description provided for @handymanFeature3.
  ///
  /// In en, this message translates to:
  /// **'📈 Build reputation'**
  String get handymanFeature3;

  /// No description provided for @handymanReviewNote.
  ///
  /// In en, this message translates to:
  /// **'⏰ Your request will be reviewed within 24-48 hours'**
  String get handymanReviewNote;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orDivider;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @registerCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Customer Account'**
  String get registerCustomerTitle;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get step1Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get step1Subtitle;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get step2Title;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'How can we reach you?'**
  String get step2Subtitle;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Secure Your Account'**
  String get step3Title;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password'**
  String get step3Subtitle;

  /// No description provided for @stepPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get stepPersonalInfo;

  /// No description provided for @stepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get stepContact;

  /// No description provided for @stepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get stepSecurity;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNamePlaceholder;

  /// No description provided for @governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get governorate;

  /// No description provided for @governoratePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select your governorate'**
  String get governoratePlaceholder;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address'**
  String get address;

  /// No description provided for @addressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Street, District, City'**
  String get addressPlaceholder;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordPlaceholder;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get agreeToTerms;

  /// No description provided for @termsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsLink;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @previousButton.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🎉'**
  String get createAccountButton;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsClose.
  ///
  /// In en, this message translates to:
  /// **'Got it, Close'**
  String get termsClose;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome! 🎉'**
  String get registerSuccessTitle;

  /// No description provided for @dateOfBirthPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with your basic information'**
  String get dateOfBirthPlaceholder;

  /// No description provided for @registerSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been created successfully'**
  String get registerSuccessMessage;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get validationNameRequired;

  /// No description provided for @validationNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameShort;

  /// No description provided for @validationGovernorateRequired.
  ///
  /// In en, this message translates to:
  /// **'Governorate is required'**
  String get validationGovernorateRequired;

  /// No description provided for @validationAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get validationAddressRequired;

  /// No description provided for @validationPasswordShort8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordShort8;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @validationTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the terms and conditions'**
  String get validationTermsRequired;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @cityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get cityPlaceholder;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @regionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get regionPlaceholder;

  /// No description provided for @validationCityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get validationCityRequired;

  /// No description provided for @validationRegionRequired.
  ///
  /// In en, this message translates to:
  /// **'Region is required'**
  String get validationRegionRequired;

  /// No description provided for @validationDobRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get validationDobRequired;

  /// No description provided for @registerHandymanTitle.
  ///
  /// In en, this message translates to:
  /// **'Register as Professional Technician'**
  String get registerHandymanTitle;

  /// No description provided for @handymanStep1.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get handymanStep1;

  /// No description provided for @handymanStep2.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get handymanStep2;

  /// No description provided for @handymanStep3.
  ///
  /// In en, this message translates to:
  /// **'Professional Info'**
  String get handymanStep3;

  /// No description provided for @handymanStep4.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get handymanStep4;

  /// No description provided for @handymanStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Your Basic Information'**
  String get handymanStep1Title;

  /// No description provided for @handymanStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your personal details to get started'**
  String get handymanStep1Subtitle;

  /// No description provided for @handymanStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Where do you work?'**
  String get handymanStep2Title;

  /// No description provided for @handymanStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your work location so we can connect you with nearby customers'**
  String get handymanStep2Subtitle;

  /// No description provided for @handymanStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Your Professional Information'**
  String get handymanStep3Title;

  /// No description provided for @handymanStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience and specializations'**
  String get handymanStep3Subtitle;

  /// No description provided for @handymanStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get handymanStep4Title;

  /// No description provided for @handymanStep4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Last step! Upload your documents'**
  String get handymanStep4Subtitle;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get experienceYears;

  /// No description provided for @experiencePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select years of experience'**
  String get experiencePlaceholder;

  /// No description provided for @experienceLess1.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 year'**
  String get experienceLess1;

  /// No description provided for @experience1to3.
  ///
  /// In en, this message translates to:
  /// **'1-3 years'**
  String get experience1to3;

  /// No description provided for @experience3to5.
  ///
  /// In en, this message translates to:
  /// **'3-5 years'**
  String get experience3to5;

  /// No description provided for @experience5to10.
  ///
  /// In en, this message translates to:
  /// **'5-10 years'**
  String get experience5to10;

  /// No description provided for @experience10plus.
  ///
  /// In en, this message translates to:
  /// **'More than 10 years'**
  String get experience10plus;

  /// No description provided for @specializations.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specializations;

  /// No description provided for @specializationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can select more than one specialization'**
  String get specializationsSubtitle;

  /// No description provided for @searchSpecialization.
  ///
  /// In en, this message translates to:
  /// **'Search for specialization...'**
  String get searchSpecialization;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selectedCount;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @hourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate (EGP)'**
  String get hourlyRate;

  /// No description provided for @hourlyRatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Example: 150'**
  String get hourlyRatePlaceholder;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'About Me (optional)'**
  String get bio;

  /// No description provided for @bioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Write a brief summary about your experience and skills...'**
  String get bioPlaceholder;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID (clear photo)'**
  String get nationalId;

  /// No description provided for @uploadNationalId.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload National ID photo'**
  String get uploadNationalId;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo (optional)'**
  String get profilePhoto;

  /// No description provided for @uploadProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload your profile photo'**
  String get uploadProfilePhoto;

  /// No description provided for @submitRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Request 🎉'**
  String get submitRequestButton;

  /// No description provided for @handymanApprovalNotice.
  ///
  /// In en, this message translates to:
  /// **'📋 Your request will be reviewed within 24-48 hours'**
  String get handymanApprovalNotice;

  /// No description provided for @handymanSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted! 🎉'**
  String get handymanSuccessTitle;

  /// No description provided for @handymanSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'We will contact you soon after reviewing your request'**
  String get handymanSuccessMessage;

  /// No description provided for @validationExperienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Years of experience is required'**
  String get validationExperienceRequired;

  /// No description provided for @validationSpecializationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one specialization'**
  String get validationSpecializationRequired;

  /// No description provided for @validationHourlyRateRequired.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate is required'**
  String get validationHourlyRateRequired;

  /// No description provided for @validationNationalIdRequired.
  ///
  /// In en, this message translates to:
  /// **'National ID photo is required'**
  String get validationNationalIdRequired;

  /// No description provided for @registerAsProHandyman.
  ///
  /// In en, this message translates to:
  /// **'Register as a professional technician'**
  String get registerAsProHandyman;

  /// No description provided for @approvalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Request is Under Review'**
  String get approvalPendingTitle;

  /// No description provided for @approvalPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering! Our team is currently reviewing your data and documents.'**
  String get approvalPendingSubtitle;

  /// No description provided for @approvalCheckPersonalData.
  ///
  /// In en, this message translates to:
  /// **'Personal data received'**
  String get approvalCheckPersonalData;

  /// No description provided for @approvalCheckDocuments.
  ///
  /// In en, this message translates to:
  /// **'Required documents uploaded'**
  String get approvalCheckDocuments;

  /// No description provided for @approvalCheckReview.
  ///
  /// In en, this message translates to:
  /// **'Admin review (24 hours)'**
  String get approvalCheckReview;

  /// No description provided for @approvalBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get approvalBackToLogin;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code\nsent to your email'**
  String get otpSubtitle;

  /// No description provided for @otpExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in'**
  String get otpExpiresIn;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @otpDidntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get otpDidntReceive;

  /// No description provided for @otpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code to email'**
  String get otpResendButton;

  /// No description provided for @otpIncompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get otpIncompleteMessage;

  /// No description provided for @otpSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully!'**
  String get otpSuccessMessage;

  /// No description provided for @otpResentMessage.
  ///
  /// In en, this message translates to:
  /// **'Code resent to your email'**
  String get otpResentMessage;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How can we serve you today?'**
  String get homeSubtitle;

  /// No description provided for @homeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'✨ Fast & Reliable Service'**
  String get homeBannerTitle;

  /// No description provided for @homeBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get the best professional technicians in your area with one tap'**
  String get homeBannerSubtitle;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeTopHandymen.
  ///
  /// In en, this message translates to:
  /// **'Top Technicians'**
  String get homeTopHandymen;

  /// No description provided for @homeTopHandymenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highest rated in your area'**
  String get homeTopHandymenSubtitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @homeCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeCategoryAll;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a service...'**
  String get homeSearchHint;

  /// No description provided for @homeBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get homeBookNow;

  /// No description provided for @homeHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'EGP / hr'**
  String get homeHourlyRate;

  /// No description provided for @homeReviews.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get homeReviews;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navProfile;

  /// No description provided for @profileMenuProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileMenuProfile;

  /// No description provided for @profileMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileMenuEdit;

  /// No description provided for @profileMenuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileMenuHelp;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @logoutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmYes;

  /// No description provided for @logoutConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutConfirmNo;

  /// No description provided for @browseCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get browseCategoriesTitle;

  /// No description provided for @browsePopularServices.
  ///
  /// In en, this message translates to:
  /// **'Popular Services'**
  String get browsePopularServices;

  /// No description provided for @browseSearchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get browseSearchResults;

  /// No description provided for @browseShowPopular.
  ///
  /// In en, this message translates to:
  /// **'Show Popular'**
  String get browseShowPopular;

  /// No description provided for @browseTechnicianCount.
  ///
  /// In en, this message translates to:
  /// **'technicians'**
  String get browseTechnicianCount;

  /// No description provided for @browseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get browseEmptyTitle;

  /// No description provided for @browseEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any service matching your search'**
  String get browseEmptySubtitle;

  /// No description provided for @requestHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Request History'**
  String get requestHistoryTitle;

  /// No description provided for @requestHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get requestHistoryEmptyTitle;

  /// No description provided for @requestHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no requests in this category'**
  String get requestHistoryEmptySubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusActive;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @requestTrackAction.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get requestTrackAction;

  /// No description provided for @requestRateAction.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get requestRateAction;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// No description provided for @profileStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get profileStatTotal;

  /// No description provided for @profileStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get profileStatCompleted;

  /// No description provided for @profileStatActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileStatActive;

  /// No description provided for @profileMenuRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get profileMenuRequests;

  /// No description provided for @profileMenuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileMenuNotifications;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutTitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAll;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications in this section'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notifRequestAcceptedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted'**
  String get notifRequestAcceptedTitle;

  /// No description provided for @notifRequestAcceptedBody.
  ///
  /// In en, this message translates to:
  /// **'Technician Mohamed Ali accepted your request #123 and will arrive on time'**
  String get notifRequestAcceptedBody;

  /// No description provided for @notifTechOnWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician On The Way'**
  String get notifTechOnWayTitle;

  /// No description provided for @notifTechOnWayBody.
  ///
  /// In en, this message translates to:
  /// **'Mohamed Ali is on his way and is expected to arrive within 15 minutes'**
  String get notifTechOnWayBody;

  /// No description provided for @notifRateUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rating Matters'**
  String get notifRateUsTitle;

  /// No description provided for @notifRateUsBody.
  ///
  /// In en, this message translates to:
  /// **'Your request #120 has been completed. Please rate the service'**
  String get notifRateUsBody;

  /// No description provided for @notifCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Completed'**
  String get notifCompletedTitle;

  /// No description provided for @notifCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Your request #120 has been completed successfully. You can now rate the service'**
  String get notifCompletedBody;

  /// No description provided for @notifCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Cancelled'**
  String get notifCancelledTitle;

  /// No description provided for @notifCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Your request #115 has been cancelled as requested'**
  String get notifCancelledBody;

  /// No description provided for @notifNewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get notifNewRequestTitle;

  /// No description provided for @notifNewRequestBody.
  ///
  /// In en, this message translates to:
  /// **'Your request #123 was created successfully and we are searching for a suitable technician'**
  String get notifNewRequestBody;

  /// No description provided for @notifWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FixIt'**
  String get notifWelcomeTitle;

  /// No description provided for @notifWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for joining! We are here to make your life easier by connecting you with the best technicians'**
  String get notifWelcomeBody;

  /// No description provided for @notifTime5Min.
  ///
  /// In en, this message translates to:
  /// **'5 minutes ago'**
  String get notifTime5Min;

  /// No description provided for @notifTime10Min.
  ///
  /// In en, this message translates to:
  /// **'10 minutes ago'**
  String get notifTime10Min;

  /// No description provided for @notifTime2Hours.
  ///
  /// In en, this message translates to:
  /// **'2 hours ago'**
  String get notifTime2Hours;

  /// No description provided for @notifTime3Hours.
  ///
  /// In en, this message translates to:
  /// **'3 hours ago'**
  String get notifTime3Hours;

  /// No description provided for @notifTime4Hours.
  ///
  /// In en, this message translates to:
  /// **'4 hours ago'**
  String get notifTime4Hours;

  /// No description provided for @notifTimeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifTimeYesterday;

  /// No description provided for @notifTime3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days ago'**
  String get notifTime3Days;

  /// No description provided for @handymanProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician Profile'**
  String get handymanProfileTitle;

  /// No description provided for @handymanSpecialtyPlumber.
  ///
  /// In en, this message translates to:
  /// **'Professional Plumber'**
  String get handymanSpecialtyPlumber;

  /// No description provided for @handymanAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get handymanAboutTitle;

  /// No description provided for @handymanAboutText.
  ///
  /// In en, this message translates to:
  /// **'Specialized plumber with over 8 years of experience. I provide water and drainage network installation and maintenance services with the highest quality standards.'**
  String get handymanAboutText;

  /// No description provided for @handymanServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get handymanServicesTitle;

  /// No description provided for @handymanContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get handymanContactTitle;

  /// No description provided for @handymanPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get handymanPhoneLabel;

  /// No description provided for @handymanPhoneHidden.
  ///
  /// In en, this message translates to:
  /// **'Will appear after request acceptance'**
  String get handymanPhoneHidden;

  /// No description provided for @handymanAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Work Area'**
  String get handymanAreaLabel;

  /// No description provided for @handymanWorkArea.
  ///
  /// In en, this message translates to:
  /// **'Cairo - Nasr City and surrounding areas'**
  String get handymanWorkArea;

  /// No description provided for @handymanHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get handymanHoursLabel;

  /// No description provided for @handymanWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Sat - Thu: 8 AM - 8 PM'**
  String get handymanWorkHours;

  /// No description provided for @handymanReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get handymanReviewsTitle;

  /// No description provided for @handymanReviewsLabel.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get handymanReviewsLabel;

  /// No description provided for @handymanStatYears.
  ///
  /// In en, this message translates to:
  /// **'Years Exp'**
  String get handymanStatYears;

  /// No description provided for @handymanStatJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get handymanStatJobs;

  /// No description provided for @handymanStatSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get handymanStatSuccess;

  /// No description provided for @handymanShowAllReviews.
  ///
  /// In en, this message translates to:
  /// **'Show All Reviews'**
  String get handymanShowAllReviews;

  /// No description provided for @handymanWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get handymanWriteReview;

  /// No description provided for @serviceLeak.
  ///
  /// In en, this message translates to:
  /// **'Leak Repair'**
  String get serviceLeak;

  /// No description provided for @servicePipes.
  ///
  /// In en, this message translates to:
  /// **'Pipe Installation'**
  String get servicePipes;

  /// No description provided for @serviceSanitary.
  ///
  /// In en, this message translates to:
  /// **'Sanitary Maintenance'**
  String get serviceSanitary;

  /// No description provided for @serviceDrainage.
  ///
  /// In en, this message translates to:
  /// **'Drain Unblocking'**
  String get serviceDrainage;

  /// No description provided for @serviceHeater.
  ///
  /// In en, this message translates to:
  /// **'Heater Installation'**
  String get serviceHeater;

  /// No description provided for @serviceWaterNet.
  ///
  /// In en, this message translates to:
  /// **'Water Network Maintenance'**
  String get serviceWaterNet;

  /// No description provided for @reviewModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get reviewModalTitle;

  /// No description provided for @reviewModalQuestion.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with'**
  String get reviewModalQuestion;

  /// No description provided for @reviewModalHint.
  ///
  /// In en, this message translates to:
  /// **'Share the details of your experience...'**
  String get reviewModalHint;

  /// No description provided for @reviewModalSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get reviewModalSubmit;

  /// No description provided for @review1Text.
  ///
  /// In en, this message translates to:
  /// **'Excellent work and high professionalism. The leak was fixed quickly and accurately.'**
  String get review1Text;

  /// No description provided for @review2Text.
  ///
  /// In en, this message translates to:
  /// **'Respectful technician who keeps appointments. Installed the heater with great efficiency.'**
  String get review2Text;

  /// No description provided for @review3Text.
  ///
  /// In en, this message translates to:
  /// **'Excellent and fast service. Fixed the problem on the first try.'**
  String get review3Text;

  /// No description provided for @reviewDate1Week.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get reviewDate1Week;

  /// No description provided for @reviewDate2Weeks.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get reviewDate2Weeks;

  /// No description provided for @reviewDate3Weeks.
  ///
  /// In en, this message translates to:
  /// **'3 weeks ago'**
  String get reviewDate3Weeks;

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'New Service Request'**
  String get bookingTitle;

  /// No description provided for @bookingServiceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get bookingServiceDetailsTitle;

  /// No description provided for @bookingServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get bookingServiceType;

  /// No description provided for @bookingServiceTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select service type'**
  String get bookingServiceTypeHint;

  /// No description provided for @bookingHandymanLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Technician (Optional)'**
  String get bookingHandymanLabel;

  /// No description provided for @bookingHandymanHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a specific technician or leave empty'**
  String get bookingHandymanHint;

  /// No description provided for @bookingDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get bookingDescLabel;

  /// No description provided for @bookingDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem in detail...'**
  String get bookingDescHint;

  /// No description provided for @bookingDateTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferred Appointment'**
  String get bookingDateTimeTitle;

  /// No description provided for @bookingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bookingDateLabel;

  /// No description provided for @bookingDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get bookingDateHint;

  /// No description provided for @bookingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get bookingTimeLabel;

  /// No description provided for @bookingTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get bookingTimeHint;

  /// No description provided for @bookingLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get bookingLocationTitle;

  /// No description provided for @bookingCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get bookingCityLabel;

  /// No description provided for @bookingCityHint.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get bookingCityHint;

  /// No description provided for @bookingAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get bookingAreaLabel;

  /// No description provided for @bookingAreaHint.
  ///
  /// In en, this message translates to:
  /// **'Select area'**
  String get bookingAreaHint;

  /// No description provided for @bookingAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed Address (Optional)'**
  String get bookingAddressLabel;

  /// No description provided for @bookingAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Building number, street...'**
  String get bookingAddressHint;

  /// No description provided for @bookingImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem Photos (Max 3)'**
  String get bookingImagesTitle;

  /// No description provided for @bookingAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get bookingAddImage;

  /// No description provided for @bookingImageUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get bookingImageUploaded;

  /// No description provided for @bookingUrgentLabel.
  ///
  /// In en, this message translates to:
  /// **'Urgent Request'**
  String get bookingUrgentLabel;

  /// No description provided for @bookingUrgentDesc.
  ///
  /// In en, this message translates to:
  /// **'Your request will be given priority'**
  String get bookingUrgentDesc;

  /// No description provided for @bookingPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get bookingPaymentTitle;

  /// No description provided for @bookingPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Cash payment only to the technician after service completion'**
  String get bookingPaymentDesc;

  /// No description provided for @bookingSubmitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get bookingSubmitBtn;

  /// No description provided for @bookingRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get bookingRequired;

  /// No description provided for @bookingFillRequired.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get bookingFillRequired;

  /// No description provided for @bookingSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get bookingSuccessTitle;

  /// No description provided for @bookingSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are searching for a suitable technician'**
  String get bookingSuccessSubtitle;

  /// No description provided for @bookingSuccessBtn.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get bookingSuccessBtn;

  /// No description provided for @catPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get catPlumbing;

  /// No description provided for @catElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get catElectricity;

  /// No description provided for @catCarpentry.
  ///
  /// In en, this message translates to:
  /// **'Carpentry'**
  String get catCarpentry;

  /// No description provided for @catPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get catPainting;

  /// No description provided for @catAC.
  ///
  /// In en, this message translates to:
  /// **'Air Conditioning'**
  String get catAC;

  /// No description provided for @cityCairo.
  ///
  /// In en, this message translates to:
  /// **'Cairo'**
  String get cityCairo;

  /// No description provided for @cityGiza.
  ///
  /// In en, this message translates to:
  /// **'Giza'**
  String get cityGiza;

  /// No description provided for @cityAlex.
  ///
  /// In en, this message translates to:
  /// **'Alexandria'**
  String get cityAlex;

  /// No description provided for @areaNasr.
  ///
  /// In en, this message translates to:
  /// **'Nasr City'**
  String get areaNasr;

  /// No description provided for @areaMaadi.
  ///
  /// In en, this message translates to:
  /// **'Maadi'**
  String get areaMaadi;

  /// No description provided for @areaZamalek.
  ///
  /// In en, this message translates to:
  /// **'Zamalek'**
  String get areaZamalek;

  /// No description provided for @searchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResultsTitle;

  /// No description provided for @searchFilterBtn.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get searchFilterBtn;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get searchResultsCount;

  /// No description provided for @searchResultsCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'technicians'**
  String get searchResultsCountSuffix;

  /// No description provided for @searchAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get searchAvailable;

  /// No description provided for @searchBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get searchBusy;

  /// No description provided for @searchExpLabel.
  ///
  /// In en, this message translates to:
  /// **'exp'**
  String get searchExpLabel;

  /// No description provided for @searchRateLabel.
  ///
  /// In en, this message translates to:
  /// **'per hour'**
  String get searchRateLabel;

  /// No description provided for @searchCurrency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get searchCurrency;

  /// No description provided for @searchBookBtn.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get searchBookBtn;

  /// No description provided for @searchSortRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get searchSortRecommended;

  /// No description provided for @searchSortRating.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get searchSortRating;

  /// No description provided for @searchSortPrice.
  ///
  /// In en, this message translates to:
  /// **'Lowest Price'**
  String get searchSortPrice;

  /// No description provided for @searchSortExp.
  ///
  /// In en, this message translates to:
  /// **'Most Experienced'**
  String get searchSortExp;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get searchEmptyTitle;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we couldn\'t find any technician matching your search'**
  String get searchEmptySubtitle;

  /// No description provided for @searchEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get searchEmptyAction;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Results'**
  String get filterTitle;

  /// No description provided for @filterAvailableOnly.
  ///
  /// In en, this message translates to:
  /// **'Available Only'**
  String get filterAvailableOnly;

  /// No description provided for @filterMinRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get filterMinRating;

  /// No description provided for @filterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get filterApply;

  /// No description provided for @browseCategoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get browseCategoriesSearchHint;

  /// No description provided for @browseClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get browseClearSearch;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionApp.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settingsSectionApp;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTerms;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteTitle;

  /// No description provided for @settingsDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This action cannot be undone.'**
  String get settingsDeleteConfirm;

  /// No description provided for @settingsDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteCancel;

  /// No description provided for @settingsDeleteConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteConfirmBtn;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @settingsPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get settingsPersonalInfo;

  /// No description provided for @settingsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get settingsFullName;

  /// No description provided for @settingsPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get settingsPhone;

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get settingsEmail;

  /// No description provided for @settingsProfessionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Professional Info'**
  String get settingsProfessionalInfo;

  /// No description provided for @settingsSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Main Specialty'**
  String get settingsSpecialty;

  /// No description provided for @settingsBio.
  ///
  /// In en, this message translates to:
  /// **'Professional Bio'**
  String get settingsBio;

  /// No description provided for @settingsHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Hourly Rate (EGP)'**
  String get settingsHourlyRate;

  /// No description provided for @settingsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get settingsExperience;

  /// No description provided for @settingsWorkArea.
  ///
  /// In en, this message translates to:
  /// **'Work Area'**
  String get settingsWorkArea;

  /// No description provided for @settingsGovernorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get settingsGovernorate;

  /// No description provided for @settingsAreas.
  ///
  /// In en, this message translates to:
  /// **'Areas (you can enter multiple)'**
  String get settingsAreas;

  /// No description provided for @settingsWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get settingsWorkHours;

  /// No description provided for @settingsFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get settingsFrom;

  /// No description provided for @settingsTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get settingsTo;

  /// No description provided for @settingsNotifRequests.
  ///
  /// In en, this message translates to:
  /// **'New Request Notifications'**
  String get settingsNotifRequests;

  /// No description provided for @settingsNotifRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts when new requests arrive'**
  String get settingsNotifRequestsDesc;

  /// No description provided for @settingsNotifMessages.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get settingsNotifMessages;

  /// No description provided for @settingsNotifMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts when new messages arrive'**
  String get settingsNotifMessagesDesc;

  /// No description provided for @settingsNotifRatings.
  ///
  /// In en, this message translates to:
  /// **'Rating Notifications'**
  String get settingsNotifRatings;

  /// No description provided for @settingsNotifRatingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts when you get a new rating'**
  String get settingsNotifRatingsDesc;

  /// No description provided for @settingsAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get settingsAvailability;

  /// No description provided for @settingsAvailableToggle.
  ///
  /// In en, this message translates to:
  /// **'Available for new requests'**
  String get settingsAvailableToggle;

  /// No description provided for @settingsAvailableToggleDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn off if you are currently unavailable'**
  String get settingsAvailableToggleDesc;

  /// No description provided for @settingsSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get settingsSaveBtn;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get settingsSaved;

  /// No description provided for @govCairo.
  ///
  /// In en, this message translates to:
  /// **'Cairo'**
  String get govCairo;

  /// No description provided for @govGiza.
  ///
  /// In en, this message translates to:
  /// **'Giza'**
  String get govGiza;

  /// No description provided for @govAlex.
  ///
  /// In en, this message translates to:
  /// **'Alexandria'**
  String get govAlex;

  /// No description provided for @govDakahlia.
  ///
  /// In en, this message translates to:
  /// **'Dakahlia'**
  String get govDakahlia;

  /// No description provided for @catElectric.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get catElectric;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get editProfileChangePhoto;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get editProfileName;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get editProfileNameHint;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editProfilePhone;

  /// No description provided for @editProfilePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get editProfilePhoneHint;

  /// No description provided for @editProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get editProfileEmail;

  /// No description provided for @editProfileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get editProfileEmailHint;

  /// No description provided for @editProfileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get editProfileEmailInvalid;

  /// No description provided for @editProfileSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get editProfileSaveBtn;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved successfully'**
  String get editProfileSaved;

  /// No description provided for @areaNewCairo.
  ///
  /// In en, this message translates to:
  /// **'New Cairo'**
  String get areaNewCairo;

  /// No description provided for @areaHeliopolis.
  ///
  /// In en, this message translates to:
  /// **'Heliopolis'**
  String get areaHeliopolis;

  /// No description provided for @areaShoubra.
  ///
  /// In en, this message translates to:
  /// **'Shoubra'**
  String get areaShoubra;

  /// No description provided for @trackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Request'**
  String get trackTitle;

  /// No description provided for @trackStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get trackStatusTitle;

  /// No description provided for @trackServiceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get trackServiceDetailsTitle;

  /// No description provided for @trackServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get trackServiceType;

  /// No description provided for @trackLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get trackLocation;

  /// No description provided for @trackPreferredTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time'**
  String get trackPreferredTime;

  /// No description provided for @trackExpectedPrice.
  ///
  /// In en, this message translates to:
  /// **'Expected Price'**
  String get trackExpectedPrice;

  /// No description provided for @trackStepCreated.
  ///
  /// In en, this message translates to:
  /// **'Request Created'**
  String get trackStepCreated;

  /// No description provided for @trackStepCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your request was created successfully'**
  String get trackStepCreatedDesc;

  /// No description provided for @trackStepPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get trackStepPending;

  /// No description provided for @trackStepPendingTime.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get trackStepPendingTime;

  /// No description provided for @trackStepPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Looking for a suitable technician for your service'**
  String get trackStepPendingDesc;

  /// No description provided for @trackStepAssigned.
  ///
  /// In en, this message translates to:
  /// **'To Be Assigned'**
  String get trackStepAssigned;

  /// No description provided for @trackStepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get trackStepCompleted;

  /// No description provided for @trackStepWaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting completion'**
  String get trackStepWaiting;

  /// No description provided for @trackPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Searching for a Technician'**
  String get trackPendingTitle;

  /// No description provided for @trackPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'We are finding the best available technician in your area. You will be notified once a technician accepts your request'**
  String get trackPendingDesc;

  /// No description provided for @trackCancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get trackCancelBtn;

  /// No description provided for @trackCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get trackCancelTitle;

  /// No description provided for @trackCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get trackCancelConfirm;

  /// No description provided for @trackCancelKeep.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get trackCancelKeep;

  /// No description provided for @trackCancelConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get trackCancelConfirmBtn;

  /// No description provided for @trackStepAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted'**
  String get trackStepAccepted;

  /// No description provided for @trackStepAcceptedDesc.
  ///
  /// In en, this message translates to:
  /// **'The technician accepted your request'**
  String get trackStepAcceptedDesc;

  /// No description provided for @trackStepInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get trackStepInProgress;

  /// No description provided for @trackStepInProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'The technician is on the way'**
  String get trackStepInProgressDesc;

  /// No description provided for @trackHandymanTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician Info'**
  String get trackHandymanTitle;

  /// No description provided for @trackCallBtn.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get trackCallBtn;

  /// No description provided for @trackWhatsappBtn.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get trackWhatsappBtn;

  /// No description provided for @trackReportBtn.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get trackReportBtn;

  /// No description provided for @trackReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get trackReportTitle;

  /// No description provided for @trackReportMessage.
  ///
  /// In en, this message translates to:
  /// **'We will contact you shortly to follow up'**
  String get trackReportMessage;

  /// No description provided for @trackReportConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get trackReportConfirmBtn;

  /// No description provided for @trackCompletionDate.
  ///
  /// In en, this message translates to:
  /// **'Completion Date'**
  String get trackCompletionDate;

  /// No description provided for @trackFinalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final Price'**
  String get trackFinalPrice;

  /// No description provided for @trackStepDoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Service completed successfully'**
  String get trackStepDoneDesc;

  /// No description provided for @trackStepCompletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Request completed successfully'**
  String get trackStepCompletedDesc;

  /// No description provided for @trackCompletedBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Completed!'**
  String get trackCompletedBannerTitle;

  /// No description provided for @trackCompletedBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We hope you are satisfied with the service provided'**
  String get trackCompletedBannerSubtitle;

  /// No description provided for @ratingPrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with the technician?'**
  String get ratingPrompt;

  /// No description provided for @ratingSubmitBtn.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get ratingSubmitBtn;

  /// No description provided for @ratingAlreadyRated.
  ///
  /// In en, this message translates to:
  /// **'Thank you! You have already rated this request'**
  String get ratingAlreadyRated;

  /// No description provided for @ratingThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! You gave'**
  String get ratingThanks;

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get ratingStars;

  /// No description provided for @ratingCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Your comment (optional)'**
  String get ratingCommentLabel;

  /// No description provided for @ratingCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with the handyman...'**
  String get ratingCommentHint;

  /// No description provided for @trackStepCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request Cancelled'**
  String get trackStepCancelled;

  /// No description provided for @trackStepCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'The request was cancelled by the customer'**
  String get trackStepCancelledDesc;

  /// No description provided for @trackRequestedTime.
  ///
  /// In en, this message translates to:
  /// **'Requested Time'**
  String get trackRequestedTime;

  /// No description provided for @trackRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get trackRequestStatus;

  /// No description provided for @trackCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Cancelled'**
  String get trackCancelledTitle;

  /// No description provided for @trackCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'This request has been cancelled and will not be completed. You can create a new request at any time.'**
  String get trackCancelledBody;

  /// No description provided for @trackCancelledReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get trackCancelledReason;

  /// No description provided for @trackCancelledByCustomer.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by customer'**
  String get trackCancelledByCustomer;

  /// No description provided for @trackRebookBtn.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get trackRebookBtn;

  /// No description provided for @portfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolioTitle;

  /// No description provided for @portfolioLatestProjects.
  ///
  /// In en, this message translates to:
  /// **'Latest Projects'**
  String get portfolioLatestProjects;

  /// No description provided for @portfolioEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Projects Yet'**
  String get portfolioEmptyTitle;

  /// No description provided for @portfolioEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The technician hasn\'t added any portfolio photos yet'**
  String get portfolioEmptySubtitle;

  /// No description provided for @portfolioProjectsCount.
  ///
  /// In en, this message translates to:
  /// **'projects'**
  String get portfolioProjectsCount;

  /// No description provided for @portfolioViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get portfolioViewAll;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'reviews'**
  String get reviewsTotalLabel;

  /// No description provided for @reviews5Stars.
  ///
  /// In en, this message translates to:
  /// **'5 Stars'**
  String get reviews5Stars;

  /// No description provided for @reviews4Stars.
  ///
  /// In en, this message translates to:
  /// **'4 Stars'**
  String get reviews4Stars;

  /// No description provided for @reviews3Stars.
  ///
  /// In en, this message translates to:
  /// **'3 Stars'**
  String get reviews3Stars;

  /// No description provided for @reviews2Stars.
  ///
  /// In en, this message translates to:
  /// **'2 Stars'**
  String get reviews2Stars;

  /// No description provided for @reviews1Star.
  ///
  /// In en, this message translates to:
  /// **'1 Star'**
  String get reviews1Star;

  /// No description provided for @reviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Reviews'**
  String get reviewsEmptyTitle;

  /// No description provided for @reviewsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No reviews match the selected filter'**
  String get reviewsEmptySubtitle;

  /// No description provided for @categoryResultsTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Technicians for'**
  String get categoryResultsTitlePrefix;

  /// No description provided for @categoryFilterAllAreas.
  ///
  /// In en, this message translates to:
  /// **'All Areas'**
  String get categoryFilterAllAreas;

  /// No description provided for @categoryFilterTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get categoryFilterTopRated;

  /// No description provided for @categoryFilterNearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get categoryFilterNearest;

  /// No description provided for @categoryFilterMostExp.
  ///
  /// In en, this message translates to:
  /// **'Most Experienced'**
  String get categoryFilterMostExp;

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Technicians Found'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No technicians available in this category right now'**
  String get categoryEmptySubtitle;

  /// No description provided for @handymanNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get handymanNavHome;

  /// No description provided for @handymanNavJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get handymanNavJobs;

  /// No description provided for @handymanNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get handymanNavProfile;

  /// No description provided for @handymanGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get handymanGreeting;

  /// No description provided for @handymanStatEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get handymanStatEarnings;

  /// No description provided for @handymanStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get handymanStatCompleted;

  /// No description provided for @handymanStatRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get handymanStatRating;

  /// No description provided for @handymanAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Available for Work'**
  String get handymanAvailableTitle;

  /// No description provided for @handymanAvailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will receive new requests'**
  String get handymanAvailableSubtitle;

  /// No description provided for @handymanUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get handymanUnavailableTitle;

  /// No description provided for @handymanUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You won\'t receive new requests'**
  String get handymanUnavailableSubtitle;

  /// No description provided for @handymanNextJobLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Job'**
  String get handymanNextJobLabel;

  /// No description provided for @handymanHeroNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get handymanHeroNavigate;

  /// No description provided for @handymanHeroDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get handymanHeroDetails;

  /// No description provided for @requestNewSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get requestNewSectionTitle;

  /// No description provided for @requestNewLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get requestNewLabel;

  /// No description provided for @requestAcceptBtn.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get requestAcceptBtn;

  /// No description provided for @requestDetailsBtn.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get requestDetailsBtn;

  /// No description provided for @requestAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get requestAcceptTitle;

  /// No description provided for @requestAcceptMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to accept this request?'**
  String get requestAcceptMessage;

  /// No description provided for @requestAcceptConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get requestAcceptConfirmBtn;

  /// No description provided for @requestEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No New Requests'**
  String get requestEmptyTitle;

  /// No description provided for @requestEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when new requests arrive'**
  String get requestEmptySubtitle;

  /// No description provided for @notifHandymanTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician Notifications'**
  String get notifHandymanTitle;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifMarkAllRead;

  /// No description provided for @notifFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifFilterAll;

  /// No description provided for @notifFilterBooking.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get notifFilterBooking;

  /// No description provided for @notifFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get notifFilterPayment;

  /// No description provided for @notifFilterSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notifFilterSystem;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no notifications in this section'**
  String get notifEmptySubtitle;

  /// No description provided for @notifHandymanNewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'New Service Request'**
  String get notifHandymanNewRequestTitle;

  /// No description provided for @notifHandymanNewRequestBody.
  ///
  /// In en, this message translates to:
  /// **'There is a new service request #125 available near you in Maadi.'**
  String get notifHandymanNewRequestBody;

  /// No description provided for @notifHandymanReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Job Reminder'**
  String get notifHandymanReminderTitle;

  /// No description provided for @notifHandymanReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You have a scheduled maintenance job in 15 minutes with customer \"Sara Ahmed\".'**
  String get notifHandymanReminderBody;

  /// No description provided for @notifHandymanRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'New Rating ⭐'**
  String get notifHandymanRatingTitle;

  /// No description provided for @notifHandymanRatingBody.
  ///
  /// In en, this message translates to:
  /// **'A customer rated your service for request #120. You got 5 stars!'**
  String get notifHandymanRatingBody;

  /// No description provided for @notifHandymanPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Collected'**
  String get notifHandymanPaymentTitle;

  /// No description provided for @notifHandymanPaymentBody.
  ///
  /// In en, this message translates to:
  /// **'Payment for request #120 was collected successfully and added to your balance.'**
  String get notifHandymanPaymentBody;

  /// No description provided for @notifHandymanCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Cancelled by Customer'**
  String get notifHandymanCancelTitle;

  /// No description provided for @notifHandymanCancelBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry, the customer cancelled request #115.'**
  String get notifHandymanCancelBody;

  /// No description provided for @notifHandymanLevelUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Up!'**
  String get notifHandymanLevelUpTitle;

  /// No description provided for @notifHandymanLevelUpBody.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You have reached the \"Expert Technician\" level thanks to your excellent ratings.'**
  String get notifHandymanLevelUpBody;

  /// No description provided for @notifHandymanWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome as a Certified Technician!'**
  String get notifHandymanWelcomeTitle;

  /// No description provided for @notifHandymanWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has been activated as a professional technician. Start receiving customer requests and increase your income.'**
  String get notifHandymanWelcomeBody;

  /// No description provided for @newReqTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get newReqTitle;

  /// No description provided for @newReqCustomerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get newReqCustomerInfo;

  /// No description provided for @newReqNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newReqNewCustomer;

  /// No description provided for @newReqCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get newReqCall;

  /// No description provided for @newReqMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get newReqMessage;

  /// No description provided for @newReqServiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get newReqServiceDetails;

  /// No description provided for @newReqServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get newReqServiceType;

  /// No description provided for @newReqDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get newReqDateTime;

  /// No description provided for @newReqLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get newReqLocation;

  /// No description provided for @newReqAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get newReqAddress;

  /// No description provided for @newReqAddressLocked.
  ///
  /// In en, this message translates to:
  /// **'Address will show after accepting'**
  String get newReqAddressLocked;

  /// No description provided for @newReqPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get newReqPrice;

  /// No description provided for @newReqProblemDesc.
  ///
  /// In en, this message translates to:
  /// **'Problem Description'**
  String get newReqProblemDesc;

  /// No description provided for @newReqProblemImages.
  ///
  /// In en, this message translates to:
  /// **'Problem Images'**
  String get newReqProblemImages;

  /// No description provided for @newReqRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get newReqRejectTitle;

  /// No description provided for @newReqRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this request?'**
  String get newReqRejectMessage;

  /// No description provided for @newReqRejectBtn.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get newReqRejectBtn;

  /// No description provided for @newReqRejectConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get newReqRejectConfirmBtn;

  /// No description provided for @jobsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get jobsTitle;

  /// No description provided for @jobFilterActive.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get jobFilterActive;

  /// No description provided for @jobFilterScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get jobFilterScheduled;

  /// No description provided for @jobFilterHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get jobFilterHistory;

  /// No description provided for @jobStatusActive.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get jobStatusActive;

  /// No description provided for @jobStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get jobStatusScheduled;

  /// No description provided for @jobToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get jobToday;

  /// No description provided for @jobTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get jobTomorrow;

  /// No description provided for @jobRegularCustomer.
  ///
  /// In en, this message translates to:
  /// **'Regular Customer'**
  String get jobRegularCustomer;

  /// No description provided for @jobPlumbingMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Plumbing - Maintenance'**
  String get jobPlumbingMaintenance;

  /// No description provided for @jobPlumbingInstall.
  ///
  /// In en, this message translates to:
  /// **'Plumbing - Installation'**
  String get jobPlumbingInstall;

  /// No description provided for @jobPlumbingLeak.
  ///
  /// In en, this message translates to:
  /// **'Plumbing - Leak Detection'**
  String get jobPlumbingLeak;

  /// No description provided for @jobCompleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get jobCompleteBtn;

  /// No description provided for @jobDetailsBtn.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get jobDetailsBtn;

  /// No description provided for @jobViewDetailsBtn.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get jobViewDetailsBtn;

  /// No description provided for @jobsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Jobs'**
  String get jobsEmptyTitle;

  /// No description provided for @jobsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have no jobs in this category'**
  String get jobsEmptySubtitle;

  /// No description provided for @jobDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetailsTitle;

  /// No description provided for @jobCustomerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get jobCustomerInfo;

  /// No description provided for @jobCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Job'**
  String get jobCompleteTitle;

  /// No description provided for @jobCompleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this job as complete?'**
  String get jobCompleteConfirm;

  /// No description provided for @jobPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get jobPrice;

  /// No description provided for @customerNew.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get customerNew;

  /// No description provided for @customerReturning.
  ///
  /// In en, this message translates to:
  /// **'Returning Customer'**
  String get customerReturning;

  /// No description provided for @profileCategory.
  ///
  /// In en, this message translates to:
  /// **'Professional Plumber'**
  String get profileCategory;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified Technician'**
  String get profileVerified;

  /// No description provided for @profileEditBtn.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditBtn;

  /// No description provided for @profileStatJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get profileStatJobs;

  /// No description provided for @profileStatRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get profileStatRating;

  /// No description provided for @profileStatYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get profileStatYears;

  /// No description provided for @profileStatRate.
  ///
  /// In en, this message translates to:
  /// **'EGP/hr'**
  String get profileStatRate;

  /// No description provided for @profileActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'February Activity'**
  String get profileActivityTitle;

  /// No description provided for @profileActivityBadge.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get profileActivityBadge;

  /// No description provided for @profileStatCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get profileStatCompletion;

  /// No description provided for @profileStatExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get profileStatExcellent;

  /// No description provided for @profileStatSuccessJobs.
  ///
  /// In en, this message translates to:
  /// **'Successful Jobs'**
  String get profileStatSuccessJobs;

  /// No description provided for @profileStatMoreThanJan.
  ///
  /// In en, this message translates to:
  /// **'+3 vs January'**
  String get profileStatMoreThanJan;

  /// No description provided for @profileAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get profileAboutTitle;

  /// No description provided for @profileAboutText.
  ///
  /// In en, this message translates to:
  /// **'Specialized plumber with over 8 years of experience. I provide installation and maintenance services for water and drainage networks to the highest quality standards.'**
  String get profileAboutText;

  /// No description provided for @profilePortfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get profilePortfolioTitle;

  /// No description provided for @profileFeedCategory.
  ///
  /// In en, this message translates to:
  /// **'Gas Heater Installation'**
  String get profileFeedCategory;

  /// No description provided for @profileFeedDate.
  ///
  /// In en, this message translates to:
  /// **'February 12, 2026'**
  String get profileFeedDate;

  /// No description provided for @profileFeedTitle.
  ///
  /// In en, this message translates to:
  /// **'50L Water Heater Installed Successfully'**
  String get profileFeedTitle;

  /// No description provided for @profileFeedText.
  ///
  /// In en, this message translates to:
  /// **'Old heater removed and new one installed with valve and connection replacements to ensure no leaks. Job completed in one hour.'**
  String get profileFeedText;

  /// No description provided for @profileShowAllPosts.
  ///
  /// In en, this message translates to:
  /// **'View All Posts'**
  String get profileShowAllPosts;

  /// No description provided for @profileContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get profileContactTitle;

  /// No description provided for @profileWorkArea.
  ///
  /// In en, this message translates to:
  /// **'Work Area'**
  String get profileWorkArea;

  /// No description provided for @profileWorkAreaValue.
  ///
  /// In en, this message translates to:
  /// **'Cairo - Nasr City & Nearby Areas'**
  String get profileWorkAreaValue;

  /// No description provided for @profileWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get profileWorkHours;

  /// No description provided for @profileWorkHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Sat - Thu: 8 AM - 8 PM'**
  String get profileWorkHoursValue;

  /// No description provided for @profileReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest Reviews'**
  String get profileReviewsTitle;

  /// No description provided for @profileReview1.
  ///
  /// In en, this message translates to:
  /// **'Excellent work and high professionalism. Leak fixed quickly and accurately. Highly recommended.'**
  String get profileReview1;

  /// No description provided for @profileReview1Date.
  ///
  /// In en, this message translates to:
  /// **'1 week ago'**
  String get profileReview1Date;

  /// No description provided for @profileReview2.
  ///
  /// In en, this message translates to:
  /// **'Respectful technician, punctual. Installed the heater efficiently and at a fair price.'**
  String get profileReview2;

  /// No description provided for @profileReview2Date.
  ///
  /// In en, this message translates to:
  /// **'2 weeks ago'**
  String get profileReview2Date;

  /// No description provided for @profileReview3.
  ///
  /// In en, this message translates to:
  /// **'Excellent and fast service. Fixed the problem on the first visit. Thank you!'**
  String get profileReview3;

  /// No description provided for @profileReview3Date.
  ///
  /// In en, this message translates to:
  /// **'3 weeks ago'**
  String get profileReview3Date;

  /// No description provided for @profileShowAllReviews.
  ///
  /// In en, this message translates to:
  /// **'View All Reviews'**
  String get profileShowAllReviews;

  /// No description provided for @profileMenuCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get profileMenuCompleted;

  /// No description provided for @profileMenuReviews.
  ///
  /// In en, this message translates to:
  /// **'Ratings & Reviews'**
  String get profileMenuReviews;

  /// No description provided for @profileMenuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileMenuSettings;

  /// No description provided for @profileMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileMenuLogout;

  /// No description provided for @timePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a time'**
  String get timePickerTitle;

  /// No description provided for @timePickerAm.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get timePickerAm;

  /// No description provided for @timePickerPm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get timePickerPm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @datePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get datePickerTitle;

  /// No description provided for @portfolioDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get portfolioDeleteTitle;

  /// No description provided for @portfolioDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get portfolioDeleteConfirm;

  /// No description provided for @portfolioDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get portfolioDeleteBtn;

  /// No description provided for @portfolioAddBtn.
  ///
  /// In en, this message translates to:
  /// **'Add New Photo'**
  String get portfolioAddBtn;

  /// No description provided for @portfolioMaxReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 photos reached'**
  String get portfolioMaxReached;

  /// No description provided for @portfolioUploadNote.
  ///
  /// In en, this message translates to:
  /// **'Max 10 photos • High quality preferred'**
  String get portfolioUploadNote;

  /// No description provided for @portfolioAddSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Portfolio'**
  String get portfolioAddSheetTitle;

  /// No description provided for @portfolioPickImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to pick image'**
  String get portfolioPickImage;

  /// No description provided for @portfolioItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Project Title'**
  String get portfolioItemTitle;

  /// No description provided for @portfolioItemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Installed 50L water heater'**
  String get portfolioItemTitleHint;

  /// No description provided for @portfolioItemDesc.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get portfolioItemDesc;

  /// No description provided for @portfolioItemDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the work done...'**
  String get portfolioItemDescHint;

  /// No description provided for @portfolioAddBtnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add to Portfolio'**
  String get portfolioAddBtnConfirm;

  /// No description provided for @updateJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Job Status'**
  String get updateJobTitle;

  /// No description provided for @updateJobSelectStatus.
  ///
  /// In en, this message translates to:
  /// **'Select New Status'**
  String get updateJobSelectStatus;

  /// No description provided for @updateJobStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get updateJobStatusInProgress;

  /// No description provided for @updateJobStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get updateJobStatusCompleted;

  /// No description provided for @updateJobPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Please collect the agreed amount in cash from the customer before leaving'**
  String get updateJobPaymentNote;

  /// No description provided for @updateJobPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Estimated amount'**
  String get updateJobPaymentAmount;

  /// No description provided for @updateJobNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion Notes (Optional)'**
  String get updateJobNotesLabel;

  /// No description provided for @updateJobNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write any notes about the work done, materials used, or recommendations for the customer...'**
  String get updateJobNotesHint;

  /// No description provided for @updateJobPhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion Photos (Optional)'**
  String get updateJobPhotosTitle;

  /// No description provided for @updateJobPhotosNote.
  ///
  /// In en, this message translates to:
  /// **'Adding photos of completed work increases customer trust and improves your rating'**
  String get updateJobPhotosNote;

  /// No description provided for @updateJobPhotosBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Photos (up to 5)'**
  String get updateJobPhotosBtn;

  /// No description provided for @updateJobConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Update'**
  String get updateJobConfirmTitle;

  /// No description provided for @updateJobConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to update the job status?'**
  String get updateJobConfirmMessage;

  /// No description provided for @updateJobConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get updateJobConfirmBtn;

  /// No description provided for @updateJobSubmitBtn.
  ///
  /// In en, this message translates to:
  /// **'Confirm Update'**
  String get updateJobSubmitBtn;

  /// No description provided for @completedJobsBadge.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedJobsBadge;

  /// No description provided for @completedJobsTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed Jobs'**
  String get completedJobsTitle;

  /// No description provided for @completedJobsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Jobs'**
  String get completedJobsTotal;

  /// No description provided for @completedJobsAvgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get completedJobsAvgRating;

  /// No description provided for @completedJobsTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get completedJobsTotalEarned;

  /// No description provided for @completedJobPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get completedJobPaid;

  /// No description provided for @completedJobsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Completed Jobs'**
  String get completedJobsEmptyTitle;

  /// No description provided for @completedJobsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed any jobs yet'**
  String get completedJobsEmptySubtitle;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// No description provided for @helpContactTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get helpContactTitle;

  /// No description provided for @helpContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us anytime'**
  String get helpContactSubtitle;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFaqTitle;

  /// No description provided for @helpFaqBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I book a handyman?'**
  String get helpFaqBookingTitle;

  /// No description provided for @helpFaqBookingDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn the booking steps'**
  String get helpFaqBookingDesc;

  /// No description provided for @helpFaqPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'How does payment work?'**
  String get helpFaqPaymentTitle;

  /// No description provided for @helpFaqPaymentDesc.
  ///
  /// In en, this message translates to:
  /// **'Available payment methods'**
  String get helpFaqPaymentDesc;

  /// No description provided for @helpFaqCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I cancel a request?'**
  String get helpFaqCancelTitle;

  /// No description provided for @helpFaqCancelDesc.
  ///
  /// In en, this message translates to:
  /// **'Cancellation and refund policy'**
  String get helpFaqCancelDesc;

  /// No description provided for @helpFaqQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'What if I\'m not satisfied?'**
  String get helpFaqQualityTitle;

  /// No description provided for @helpFaqQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Quality guarantee and complaints'**
  String get helpFaqQualityDesc;

  /// No description provided for @profileMenuPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get profileMenuPortfolio;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get contactPhone;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get contactEmail;

  /// No description provided for @faqBookingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Choose a Service'**
  String get faqBookingStep1Title;

  /// No description provided for @faqBookingStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Browse available services from the home page or explore page and choose the service you need.'**
  String get faqBookingStep1Desc;

  /// No description provided for @faqBookingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Specify the Details'**
  String get faqBookingStep2Title;

  /// No description provided for @faqBookingStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem clearly, add photos if needed, then choose a suitable date and location.'**
  String get faqBookingStep2Desc;

  /// No description provided for @faqBookingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Pick a Handyman'**
  String get faqBookingStep3Title;

  /// No description provided for @faqBookingStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Browse available handymen, view their ratings and prices, then choose the best fit.'**
  String get faqBookingStep3Desc;

  /// No description provided for @faqBookingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Confirm the Booking'**
  String get faqBookingStep4Title;

  /// No description provided for @faqBookingStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Review the request details and confirm. You will receive a notification once the handyman accepts.'**
  String get faqBookingStep4Desc;

  /// No description provided for @faqPaymentStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Cash Payment'**
  String get faqPaymentStep1Title;

  /// No description provided for @faqPaymentStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Payment is made in cash directly to the handyman after the service is completed.'**
  String get faqPaymentStep1Desc;

  /// No description provided for @faqPaymentStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Agreed Price'**
  String get faqPaymentStep2Title;

  /// No description provided for @faqPaymentStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'The price is set in advance based on the service type and hours of work.'**
  String get faqPaymentStep2Desc;

  /// No description provided for @faqPaymentStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Payment Receipt'**
  String get faqPaymentStep3Title;

  /// No description provided for @faqPaymentStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'You will receive a notification confirming payment once the handyman logs the amount.'**
  String get faqPaymentStep3Desc;

  /// No description provided for @faqCancelStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Before Acceptance'**
  String get faqCancelStep1Title;

  /// No description provided for @faqCancelStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'You can cancel the request for free at any time before the handyman accepts.'**
  String get faqCancelStep1Desc;

  /// No description provided for @faqCancelStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. After Acceptance'**
  String get faqCancelStep2Title;

  /// No description provided for @faqCancelStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Cancellation after acceptance is possible by notifying the handyman and contacting support.'**
  String get faqCancelStep2Desc;

  /// No description provided for @faqCancelStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. After Handyman Arrives'**
  String get faqCancelStep3Title;

  /// No description provided for @faqCancelStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Cancelling after the handyman arrives may require a small compensation fee.'**
  String get faqCancelStep3Desc;

  /// No description provided for @faqQualityStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Talk to the Handyman'**
  String get faqQualityStep1Title;

  /// No description provided for @faqQualityStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Let the handyman know about the issue first and give them a chance to fix it.'**
  String get faqQualityStep1Desc;

  /// No description provided for @faqQualityStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Submit a Report'**
  String get faqQualityStep2Title;

  /// No description provided for @faqQualityStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'You can submit a report from the request tracking page if the issue remains.'**
  String get faqQualityStep2Desc;

  /// No description provided for @faqQualityStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Quality Guarantee'**
  String get faqQualityStep3Title;

  /// No description provided for @faqQualityStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'We guarantee the quality of our services and work to resolve every complaint as fast as possible.'**
  String get faqQualityStep3Desc;

  /// No description provided for @editProfilePersonalSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get editProfilePersonalSection;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settingsLightMode;

  /// No description provided for @settingsLanguageAr.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageAr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageEn;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your job efficiently'**
  String get quickActionsSubtitle;

  /// No description provided for @jobCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Mark this job as completed and collect payment'**
  String get jobCompleteDesc;

  /// No description provided for @trackReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Report an issue with this job'**
  String get trackReportDesc;

  /// No description provided for @jobCompleteTip.
  ///
  /// In en, this message translates to:
  /// **'Make sure to collect payment and add completion photos for better ratings.'**
  String get jobCompleteTip;

  /// No description provided for @updateJobInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Information'**
  String get updateJobInfoTitle;

  /// No description provided for @updateJobInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for updating'**
  String get updateJobInfoSubtitle;

  /// No description provided for @updateJobTip1.
  ///
  /// In en, this message translates to:
  /// **'Add clear photos of the completed work'**
  String get updateJobTip1;

  /// No description provided for @updateJobTip2.
  ///
  /// In en, this message translates to:
  /// **'Include notes about any additional work done'**
  String get updateJobTip2;

  /// No description provided for @updateJobTip3.
  ///
  /// In en, this message translates to:
  /// **'Collect payment before marking as complete'**
  String get updateJobTip3;

  /// No description provided for @portfolioStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Stats'**
  String get portfolioStatsTitle;

  /// No description provided for @portfolioStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your work showcase'**
  String get portfolioStatsSubtitle;

  /// No description provided for @portfolioProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get portfolioProjects;

  /// No description provided for @portfolioRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get portfolioRemaining;

  /// No description provided for @portfolioMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get portfolioMax;

  /// No description provided for @portfolioTip.
  ///
  /// In en, this message translates to:
  /// **'Add high-quality photos of your best work to attract more customers'**
  String get portfolioTip;

  /// No description provided for @helpQuickTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get helpQuickTipsTitle;

  /// No description provided for @helpTipResponse.
  ///
  /// In en, this message translates to:
  /// **'Our support team typically responds within 24 hours'**
  String get helpTipResponse;

  /// No description provided for @helpTipCall.
  ///
  /// In en, this message translates to:
  /// **'For urgent issues, call us directly for faster assistance'**
  String get helpTipCall;

  /// No description provided for @helpTipChat.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is the fastest way to reach our support team'**
  String get helpTipChat;

  /// No description provided for @helpFaqStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Step by Step'**
  String get helpFaqStepsTitle;

  /// Subtitle for FAQ steps section showing the number of steps
  ///
  /// In en, this message translates to:
  /// **'Follow these {count} simple steps'**
  String helpFaqStepsSubtitle(int count);

  /// No description provided for @helpFaqStepsCount.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get helpFaqStepsCount;

  /// No description provided for @editProfilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to change your profile picture'**
  String get editProfilePhotoHint;

  /// No description provided for @editProfileTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Tips'**
  String get editProfileTipsTitle;

  /// No description provided for @editProfileTipPhoto.
  ///
  /// In en, this message translates to:
  /// **'Use a clear, professional photo to build trust with customers'**
  String get editProfileTipPhoto;

  /// No description provided for @editProfileTipPhone.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone number updated to receive important notifications'**
  String get editProfileTipPhone;

  /// No description provided for @editProfileTipLocation.
  ///
  /// In en, this message translates to:
  /// **'Accurate location helps customers find you easily'**
  String get editProfileTipLocation;

  /// No description provided for @contactHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re Here to Help'**
  String get contactHeaderTitle;

  /// No description provided for @contactHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reach out to us anytime, we\'re available 24/7'**
  String get contactHeaderSubtitle;

  /// No description provided for @contactWorkingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get contactWorkingHours;

  /// No description provided for @contactSaturdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Saturday - Thursday'**
  String get contactSaturdayThursday;

  /// No description provided for @contactFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get contactFriday;

  /// No description provided for @contactClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get contactClosed;

  /// No description provided for @contactFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get contactFollowUs;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password for your account'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetPasswordNewPassword;

  /// No description provided for @resetPasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get resetPasswordNewPasswordHint;

  /// No description provided for @resetPasswordConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get resetPasswordConfirmPassword;

  /// No description provided for @resetPasswordConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get resetPasswordConfirmPasswordHint;

  /// No description provided for @resetPasswordRequirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Password must contain:'**
  String get resetPasswordRequirementsTitle;

  /// No description provided for @resetPasswordReqMinLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get resetPasswordReqMinLength;

  /// No description provided for @resetPasswordReqUppercase.
  ///
  /// In en, this message translates to:
  /// **'At least one uppercase letter (A-Z)'**
  String get resetPasswordReqUppercase;

  /// No description provided for @resetPasswordReqLowercase.
  ///
  /// In en, this message translates to:
  /// **'At least one lowercase letter (a-z)'**
  String get resetPasswordReqLowercase;

  /// No description provided for @resetPasswordReqNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number (0-9)'**
  String get resetPasswordReqNumber;

  /// No description provided for @resetPasswordReqSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least one special character (!@#\$%)'**
  String get resetPasswordReqSpecial;

  /// No description provided for @resetPasswordRequirementsNotMet.
  ///
  /// In en, this message translates to:
  /// **'Password does not meet all requirements'**
  String get resetPasswordRequirementsNotMet;

  /// No description provided for @resetPasswordSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get resetPasswordSaveButton;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @startJobBtn.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJobBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
