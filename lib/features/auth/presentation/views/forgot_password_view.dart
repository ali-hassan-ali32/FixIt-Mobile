import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/animations/animated_action_icon.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/buttons/app_primary_button.dart';
import '../../data/models/requests/forgot_password_request.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

// ══════════════════════════════════════════════════════════════
// ForgotPasswordView — layout router
// ══════════════════════════════════════════════════════════════
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const ForgotPasswordTabletBody()
          : const ForgotPasswordMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — logic + animations
// ══════════════════════════════════════════════════════════════
abstract class _ForgotBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  final formKey    = GlobalKey<FormState>();
  final emailCtrl  = TextEditingController();
  // bool  isLoading  = false;

  // Entry stagger
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>>  entrySlide;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    entryFade = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s, (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Widget a(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  String? validateEmail(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.validationEmailRequired;
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(v.trim())) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  Future<void> onSend(
      AppLocalizations l10n,
      ) async {

    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {

      AppSnackBar.show(
        context,
        message:
        l10n.loginValidationWarningMessage,
        type: AppSnackType.warning,
      );

      return;
    }

    final request = ForgotPasswordRequest(email: emailCtrl.text.trim(),);

    context
        .read<AuthCubit>()
        .forgotPassword(request);
  }
  // Shared widgets
  Widget buildIcon() => AnimatedActionIcon(
    icon: Icons.mail_outline_rounded,
    primaryColor: AppColors.primary[60]!,
    secondaryColor: AppColors.secondary[60]!,
  );

  Widget buildBackLink(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    return _BackLink(
      label: l10n.backToLogin,
      colorScheme: colorScheme,
      textTheme: textTheme,
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ForgotPasswordMobileBody
// ══════════════════════════════════════════════════════════════
class ForgotPasswordMobileBody extends StatefulWidget {
  const ForgotPasswordMobileBody({super.key});

  @override
  State<ForgotPasswordMobileBody> createState() =>
      _ForgotPasswordMobileBodyState();
}

class _ForgotPasswordMobileBodyState
    extends _ForgotBase<ForgotPasswordMobileBody> {

  @override
  Widget build(BuildContext context) {
    final l10n      = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {

          state.whenOrNull(
            success: (user) {

            },

            forgotPasswordSuccess: (message, token) {

              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.success,
              );

              Navigator.pushReplacementNamed(
                context,
                AppRoutes.otp,
                arguments: {
                  'email': emailCtrl.text.trim(),
                  'sentOtp': token,
                },
              );
            },

            error: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.error,
              );
            },
          );
        },

        builder: (context, state) {
          return Scaffold(
            body: AppAuthBackground(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl.w,
                        vertical: AppSpacing.xl.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - (AppSpacing.xl.h * 2),
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                a(0, buildIcon()),
                                SizedBox(height: 24.h),

                                a(
                                  1,
                                  Text(
                                    l10n.forgotPasswordTitle,
                                    style: textTheme.displayLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                a(
                                  2,
                                  Text(
                                    l10n.forgotPasswordSubtitle,
                                    style: textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 40.h),

                                a(
                                  3,
                                  AppTextField(
                                    label: l10n.email,
                                    hintText: l10n.emailPlaceholder,
                                    controller: emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.left,
                                    validator: (v) => validateEmail(v, l10n),
                                  ),
                                ),
                                SizedBox(height: 24.h),

                                a(
                                  4,
                                  Column(
                                    children: [
                                      AppPrimaryButton(
                                        label: l10n.sendOtpButton,
                                        onPressed: () => onSend(l10n),
                                        isLoading:
                                        context.watch<AuthCubit>().state
                                            .maybeWhen(
                                          loading: () => true,
                                          orElse: () => false,
                                        ),
                                      ),
                                      SizedBox(height: 24.h),
                                      buildBackLink(context, l10n),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
    );

  }
}

// ══════════════════════════════════════════════════════════════
// ForgotPasswordTabletBody — centered card on gradient bg
// ══════════════════════════════════════════════════════════════
class ForgotPasswordTabletBody extends StatefulWidget {
  const ForgotPasswordTabletBody({super.key});

  @override
  State<ForgotPasswordTabletBody> createState() =>
      _ForgotPasswordTabletBodyState();
}

class _ForgotPasswordTabletBodyState extends _ForgotBase<ForgotPasswordTabletBody> {

  @override
  Widget build(BuildContext context) {
    final l10n      = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {

          state.whenOrNull(

              forgotPasswordSuccess: (message, token) {

                AppSnackBar.show(
                  context,
                  message: message,
                  type: AppSnackType.success,
                );

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.otp,
                  arguments: {
                    'email': emailCtrl.text.trim(),
                    'sentOtp': token,
                  },
                );
              },

            error: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.error,
              );
            },
          );
        },

        builder: (context, state) {
          return Scaffold(
            body: AppAuthBackground(
              child: SizedBox.expand(
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl.w, vertical: AppSpacing.xl.h),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: EdgeInsets.all(40.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface.withOpacity(0.95)
                              : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [BoxShadow(
                              color: AppColors.primary[60]!.withOpacity(0.12),
                              blurRadius: 40, offset: const Offset(0, 12))],
                          border: Border.all(
                              color: AppColors.primary[60]!.withOpacity(0.10)),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              a(0, buildIcon()),
                              SizedBox(height: 24.h),

                              a(1, Text(l10n.forgotPasswordTitle,
                                  style: textTheme.displayLarge,
                                  textAlign: TextAlign.center)),
                              SizedBox(height: 12.h),

                              a(2, Text(l10n.forgotPasswordSubtitle,
                                  style: textTheme.bodyLarge,
                                  textAlign: TextAlign.center)),
                              SizedBox(height: 36.h),

                              a(3, AppTextField(
                                label: l10n.email,
                                hintText: l10n.emailPlaceholder,
                                controller: emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,
                                validator: (v) => validateEmail(v, l10n),
                              )),
                              SizedBox(height: 28.h),

                              a(4, Column(children: [
                                AppPrimaryButton(
                                  label: l10n.sendOtpButton,
                                  onPressed: () => onSend(l10n),
                                  isLoading:
                                  context.watch<AuthCubit>().state
                                      .maybeWhen(
                                    loading: () => true,
                                    orElse: () => false,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                buildBackLink(context, l10n),
                              ])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _BackLink — shared extracted widget
// ══════════════════════════════════════════════════════════════
class _BackLink extends StatefulWidget {
  final String      label;
  final ColorScheme colorScheme;
  final TextTheme   textTheme;
  final VoidCallback onTap;

  const _BackLink({
    required this.label, required this.colorScheme,
    required this.textTheme, required this.onTap,
  });

  @override
  State<_BackLink> createState() => _BackLinkState();
}

class _BackLinkState extends State<_BackLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.94)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp:   (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_rounded,
                size: 18.sp, color: widget.colorScheme.onSurfaceVariant),
            SizedBox(width: 6.w),
            Text(widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: widget.colorScheme.onSurfaceVariant,
                )),
          ],
        ),
      ),
    );
  }
}