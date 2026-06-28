import 'package:animations/animations.dart';
import 'package:fix_it/config/constants/enums/app_enums.dart';
import 'package:fix_it/config/di/di.dart';
import 'package:fix_it/config/providers/app_config_provider.dart';
import 'package:fix_it/core/l10n/translation/app_localizations.dart';
import 'package:fix_it/core/router/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/views/choose_role_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/handyman_approval_pending_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/otp_view.dart';
import '../../features/auth/presentation/views/register_customer_view.dart';
import '../../features/auth/presentation/views/register_handyman_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/auth/presentation/views/splash_view.dart';
import '../../features/customer/presentation/cubit/customer_cubit.dart';
import '../../features/customer/presentation/views/customer_book_service_view.dart';
import '../../features/customer/presentation/views/customer_category_search_results_view.dart';
import '../../features/notifications/presentaions/cubit/notification_cubit.dart';
import '../../features/notifications/presentaions/views/customer_notifications_view.dart';
import '../../features/customer/presentation/views/customer_search_results_view.dart';
import '../../features/customer/presentation/views/customer_settings_view.dart';
import '../../features/customer/presentation/views/customer_shell.dart';
import '../../features/customer/presentation/views/customer_track_request_active_view.dart';
import '../../features/customer/presentation/views/customer_track_request_cancelled_view.dart';
import '../../features/customer/presentation/views/customer_track_request_completed_view.dart';
import '../../features/customer/presentation/views/customer_track_request_pending_view.dart';
import '../../features/customer/presentation/views/customer_view_handyman_portfolio_view.dart';
import '../../features/customer/presentation/views/customer_view_handyman_reviews_view.dart';
import '../../features/customer/presentation/views/customer_view_handyman_view.dart';
import '../../features/handyman/presentation/cubit/handyman_cubit.dart';
import '../../features/handyman/presentation/views/handyman_completed_jobs_view.dart';
import '../../features/handyman/presentation/views/handyman_edit_profile_view.dart';
import '../../features/handyman/presentation/views/handyman_manage_portfolio_view.dart';
import '../../features/handyman/presentation/views/handyman_new_request_view.dart';
import '../../features/notifications/presentaions/views/handyman_notifications_view.dart';
import '../../features/handyman/presentation/views/handyman_own_reviews_view.dart';
import '../../features/handyman/presentation/views/handyman_settings_view.dart';
import '../../features/handyman/presentation/views/handyman_shell.dart';
import '../../features/handyman/presentation/views/handyman_update_job_status_view.dart';
import '../../features/handyman/presentation/views/handyman_view_active_job_view.dart';
import '../../features/home/shared/ui/views/shared_contact_us_view.dart';
import '../../features/home/shared/ui/views/customer_edit_profile_view.dart';
import '../../features/home/shared/ui/views/shared_faq_view.dart';
import '../../features/home/shared/ui/views/shared_help_support_view.dart';
import '../../features/lookups/presentation/cubit/lookup_cubit.dart';
import '../theme/app_colors.dart';

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? AppRoutes.splash);

    switch (uri.path) {
      // ── Auth ──────────────────────────────────────────────

      case AppRoutes.splash:
        return _buildRoute(
          settings: settings,
          child: const SplashView(),
          transition: _TransitionType.fade,
        );

      case AppRoutes.login:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const LoginView(),
          ),
        );

      case AppRoutes.forgotPassword:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: const ForgotPasswordView(),
          ),
        );

      case AppRoutes.otp:
        final args = settings.arguments as Map<String, dynamic>?;

        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: OtpView(email: args?['email'],sentOtp: args?['sentOtp'] as String?),
          ),
        );

      case AppRoutes.chooseRole:
        return _buildRoute(settings: settings, child: const ChooseRoleView());

      case AppRoutes.registerCustomer:
        return _buildRoute(
          settings: settings,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AuthCubit>()),

              BlocProvider(create: (_) => getIt<LookupCubit>()),
            ],
            child: const RegisterCustomerView(),
          ),
        );

      case AppRoutes.registerHandyman:
        return _buildRoute(
          settings: settings,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => getIt<AuthCubit>()),

              BlocProvider(create: (_) => getIt<LookupCubit>()),
            ],
            child: const RegisterHandymanView(),
          ),
        );

      case AppRoutes.handymanApprovalPending:
        return _buildRoute(
          settings: settings,
          child: const HandymanApprovalPendingView(),
        );

      case AppRoutes.resetPassword:
        final args = settings.arguments as Map<String, dynamic>;

        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<AuthCubit>(),
            child: ResetPasswordView(
              userType: AppUserType.customer,

              email: args['email'] as String,

              token: args['otp'] as String,
            ),
          ),
        );

      // ── Customer ──────────────────────────────────────────

      case AppRoutes.customerHome:
        return _buildRoute(
          settings: settings,
          transition: _TransitionType.fade,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<CustomerCubit>()
                  ..getProfile()
                  ..getStatistics(),
              ),

              BlocProvider(
                create: (_) => getIt<LookupCubit>()
                  ..loadCategories(),
              ),

              BlocProvider(
                create: (_) => getIt<NotificationCubit>()
                  ..getNotifications(),
              ),
            ],
            child: const CustomerShell(),
          ),
        );

      case AppRoutes.customerNotifications:
        return _buildRoute(
          settings: settings,
          child: const CustomerNotificationsView(),
        );

      case AppRoutes.customerViewHandyman:
        final handymanId = settings.arguments as String?;

        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>(),
            child: CustomerViewHandymanView(
              handymanId: handymanId,
            ),
          ),
        );

      case AppRoutes.customerBookService:
        final handymanId = settings.arguments as String?;

        return _buildRoute(
          settings: settings,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<CustomerCubit>(),
              ),
              BlocProvider(
                create: (_) => getIt<LookupCubit>(),
              ),
            ],
            child: CustomerBookServiceView(
              preselectedHandymanId: handymanId,
            ),
          ),
        );

      case AppRoutes.customerSearchResults:
        final args = settings.arguments as Map<String, dynamic>?;
        final searchQuery = args?['query'] as String?;
        final searchCategoryId = args?['categoryId'] as String?;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()
              ..getHandymen(search: searchQuery, categoryId: searchCategoryId),
            child: CustomerSearchResultsView(
              query: searchQuery,
              categoryId: searchCategoryId,
            ),
          ),
        );

      case AppRoutes.customerSettings:
        return _buildRoute(
          settings: settings,
          child: const CustomerSettingsView(),
        );

      case AppRoutes.customerEditProfileView:
        return _buildRoute(
          settings: settings,
          child: BlocProvider.value(
            value: getIt<CustomerCubit>(),
            child: const CustomerEditProfileView(),
          ),
        );

      case AppRoutes.customerTrackRequestPending:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()..getRequestDetails(id),
            child: CustomerTrackRequestPendingView(requestId: id),
          ),
        );

      case AppRoutes.customerTrackRequestActive:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()..getRequestDetails(id),
            child: CustomerTrackRequestActiveView(requestId: id),
          ),
        );

      case AppRoutes.customerTrackRequestCompleted:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()..getRequestDetails(id),
            child: CustomerTrackRequestCompletedView(requestId: id),
          ),
        );

      case AppRoutes.customerTrackRequestCancelled:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()..getRequestDetails(id),
            child: CustomerTrackRequestCancelledView(requestId: id),
          ),
        );

      case AppRoutes.customerViewHandymanPortfolio:
        final handymanId = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: CustomerViewHandymanPortfolioView(handymanId: handymanId),
        );

      case AppRoutes.customerViewHandymanReviews:
        final handymanId = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>()..getHandymanReviews(handymanId),
            child: CustomerViewHandymanReviewsView(handymanId: handymanId),
          ),
        );

      case AppRoutes.customerCategorySearchResults:
        final args = settings.arguments as Map<String, dynamic>;

        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<CustomerCubit>(),
            child: CustomerCategorySearchResultsView(
              categoryId: args['categoryId'] as String,
              categoryName: args['categoryName'] as String,
            ),
          ),
        );
      // ── Handyman ──────────────────────────────────────────

      case AppRoutes.handymanHome:
        return _buildRoute(
          settings: settings,
          child: const HandymanShell(),
          transition: _TransitionType.fade,
        );

      case AppRoutes.handymanNotifications:
        return _buildRoute(
          settings: settings,
          child: const HandymanNotificationsView(),
          transition: _TransitionType.slide,
        );

      case AppRoutes.handymanActiveJobs:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: HandymanViewActiveJobView(requestId: id,),
        );

      case AppRoutes.handymanViewActiveJob:
        final id = settings.arguments as String? ?? '';
        return _buildRoute(
          settings: settings,
          child: HandymanViewActiveJobView(requestId: id),
        );

      case AppRoutes.handymanViewNewRequest:
        final id = settings.arguments as String;
        return _buildRoute(
          settings: settings,
          child: HandymanViewNewRequestView(requestId: id),
          transition: _TransitionType.slide,
        );

      case AppRoutes.handymanProfile:
        return _buildRoute(settings: settings, child: const HandymanShell());

      case AppRoutes.handymanSettings:
        return _buildRoute(
          settings: settings,
          child: const HandymanSettingsView(),
          transition: _TransitionType.slide,
        );

      case AppRoutes.handymanManagePortfolio:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<HandymanCubit>()..getPortfolio(),
            child: const HandymanManagePortfolioView(),
          ),
        );

      case AppRoutes.handymanEditProfileView:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<HandymanCubit>()..getProfile(),
            child: const HandymanEditProfileView(),
          ),
        );

      case AppRoutes.handymanOwnReviews:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<HandymanCubit>()
              ..getReviews(),
            child: const HandymanOwnReviewsView(),
          ),
        );

      case AppRoutes.handymanUpdateJobStatus:
        final id = settings.arguments as String? ?? '';

        return _buildRoute(
          settings: settings,
          child: BlocProvider.value(
            value: getIt<HandymanCubit>(),
            child: HandymanUpdateJobStatusView(
              requestId: id,
              customerName: '', serviceType: '', date: '', location: '', price: '',
            ),
          ),
        );

      case AppRoutes.handymanCompletedJobs:
        return _buildRoute(
          settings: settings,
          child: BlocProvider(
            create: (_) => getIt<HandymanCubit>()
              ..getJobs()
              ..getStatistics(),
            child: const HandymanCompletedJobsView(),
          ),
        );

      // ── Shared ────────────────────────────────────────────

      case AppRoutes.sharedHelpSupport:
        final isHandyman = settings.arguments as bool? ?? false;
        return _buildRoute(
          settings: settings,
          child: SharedHelpSupportView(
            accentColor: isHandyman
                ? AppColors.accent[60]!
                : AppColors.primary[60]!,
          ),
        );

      case AppRoutes.sharedContactUs:
        final isHandyman = settings.arguments as bool? ?? false;
        return _buildRoute(
          settings: settings,
          child: SharedContactUsView(
            accentColor: isHandyman
                ? AppColors.accent[60]!
                : AppColors.primary[60]!,
          ),
        );

      case AppRoutes.sharedFaqBooking:
        final isHandyman = settings.arguments as bool? ?? false;
        final accent = isHandyman
            ? AppColors.accent[60]!
            : AppColors.primary[60]!;
        return _buildRoute(
          settings: settings,
          child: Builder(
            builder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              return SharedFaqView(
                title: l.helpFaqBookingTitle,
                accentColor: accent,
                steps: [
                  FaqStep(
                    title: l.faqBookingStep1Title,
                    description: l.faqBookingStep1Desc,
                  ),
                  FaqStep(
                    title: l.faqBookingStep2Title,
                    description: l.faqBookingStep2Desc,
                  ),
                  FaqStep(
                    title: l.faqBookingStep3Title,
                    description: l.faqBookingStep3Desc,
                  ),
                  FaqStep(
                    title: l.faqBookingStep4Title,
                    description: l.faqBookingStep4Desc,
                  ),
                ],
              );
            },
          ),
        );

      case AppRoutes.sharedFaqPayment:
        final isHandyman = settings.arguments as bool? ?? false;
        final accent = isHandyman
            ? AppColors.accent[60]!
            : AppColors.primary[60]!;
        return _buildRoute(
          settings: settings,
          child: Builder(
            builder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              return SharedFaqView(
                title: l.helpFaqPaymentTitle,
                accentColor: accent,
                steps: [
                  FaqStep(
                    title: l.faqPaymentStep1Title,
                    description: l.faqPaymentStep1Desc,
                  ),
                  FaqStep(
                    title: l.faqPaymentStep2Title,
                    description: l.faqPaymentStep2Desc,
                  ),
                  FaqStep(
                    title: l.faqPaymentStep3Title,
                    description: l.faqPaymentStep3Desc,
                  ),
                ],
              );
            },
          ),
        );

      case AppRoutes.sharedFaqCancellation:
        final isHandyman = settings.arguments as bool? ?? false;
        final accent = isHandyman
            ? AppColors.accent[60]!
            : AppColors.primary[60]!;
        return _buildRoute(
          settings: settings,
          child: Builder(
            builder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              return SharedFaqView(
                title: l.helpFaqCancelTitle,
                accentColor: accent,
                steps: [
                  FaqStep(
                    title: l.faqCancelStep1Title,
                    description: l.faqCancelStep1Desc,
                  ),
                  FaqStep(
                    title: l.faqCancelStep2Title,
                    description: l.faqCancelStep2Desc,
                  ),
                  FaqStep(
                    title: l.faqCancelStep3Title,
                    description: l.faqCancelStep3Desc,
                  ),
                ],
              );
            },
          ),
        );

      case AppRoutes.sharedFaqQuality:
        final isHandyman = settings.arguments as bool? ?? false;
        final accent = isHandyman
            ? AppColors.accent[60]!
            : AppColors.primary[60]!;
        return _buildRoute(
          settings: settings,
          child: Builder(
            builder: (ctx) {
              final l = AppLocalizations.of(ctx)!;
              return SharedFaqView(
                title: l.helpFaqQualityTitle,
                accentColor: accent,
                steps: [
                  FaqStep(
                    title: l.faqQualityStep1Title,
                    description: l.faqQualityStep1Desc,
                  ),
                  FaqStep(
                    title: l.faqQualityStep2Title,
                    description: l.faqQualityStep2Desc,
                  ),
                  FaqStep(
                    title: l.faqQualityStep3Title,
                    description: l.faqQualityStep3Desc,
                  ),
                ],
              );
            },
          ),
        );

      // ── Default ───────────────────────────────────────────

      default:
        return _buildRoute(
          settings: settings,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.appTitle),
                    FilledButton(
                      onPressed: () {
                        final config = getIt<AppConfigProvider>();
                        config.changeLocale(
                          currentLocale: config.isAr() ? 'en' : 'ar',
                        );
                      },
                      child: const Text('Test'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
    }
  }

  // ── Route Builder ─────────────────────────────────────────
  static Route _buildRoute({
    required RouteSettings settings,
    required Widget child,
    _TransitionType transition = _TransitionType.slide,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (transition) {
          case _TransitionType.slide:
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          case _TransitionType.fade:
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
        }
      },
    );
  }
}

enum _TransitionType { slide, fade }
