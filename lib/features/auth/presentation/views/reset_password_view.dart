import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/constants/enums/app_enums.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/animations/animated_action_icon.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_password_field.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';
import '../../../../core/utils/widgets/buttons/app_gradient_button.dart';
import '../../data/models/requests/reset_password_request.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

// ══════════════════════════════════════════════════════════════
// ResetPasswordView — layout router
// ══════════════════════════════════════════════════════════════
class ResetPasswordView extends StatelessWidget {
  final AppUserType userType;

  final String email;
  final String token;

  const ResetPasswordView({
    super.key,
    required this.email,
    required this.token,
    this.userType = AppUserType.customer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? ResetPasswordTabletBody(
              userType: userType,
              email: email,
              token: token,
            )
          : ResetPasswordMobileBody(
              userType: userType,
              email: email,
              token: token,
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Password validation model
// ══════════════════════════════════════════════════════════════
class PasswordValidation {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordValidation({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  factory PasswordValidation.fromPassword(String password) {
    return PasswordValidation(
      hasMinLength: password.length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(password),
      hasLowercase: RegExp(r'[a-z]').hasMatch(password),
      hasNumber: RegExp(r'[0-9]').hasMatch(password),
      hasSpecialChar: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
    );
  }

  bool get isValid =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialChar;
}

// ══════════════════════════════════════════════════════════════
// Shared base — logic + animations + role colors
// ══════════════════════════════════════════════════════════════
abstract class _ResetBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  // bool isLoading       = false;
  PasswordValidation validation = const PasswordValidation(
    hasMinLength: false,
    hasUppercase: false,
    hasLowercase: false,
    hasNumber: false,
    hasSpecialChar: false,
  );

  // ── Role-aware colors (implemented by each body) ────────
  bool get isHandyman;
  Color get primaryColor =>
      isHandyman ? AppColors.accent[60]! : AppColors.primary[60]!;
  Color get secondaryColor =>
      isHandyman ? AppColors.accent[40]! : AppColors.secondary[60]!;
  Gradient get submitGradient =>
      LinearGradient(colors: [primaryColor, secondaryColor]);

  // ── Entry stagger ──────────────────────────────────────
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 6;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Stagger animations
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Listen to password changes
    passwordCtrl.addListener(_updateValidation);
    entryCtrl.forward();
  }

  void _updateValidation() {
    setState(() {
      validation = PasswordValidation.fromPassword(passwordCtrl.text);
    });
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    passwordCtrl.removeListener(_updateValidation);
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Widget a(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Validators ─────────────────────────────────────────
  String? validatePassword(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.validationPasswordRequired;
    if (!validation.isValid) return l10n.resetPasswordRequirementsNotMet;
    return null;
  }

  String? validateConfirm(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.validationPasswordRequired;
    if (v != passwordCtrl.text) return l10n.validationPasswordMismatch;
    return null;
  }

  // ── Submit ─────────────────────────────────────────────
  Future<void> onSave(AppLocalizations l10n, String email, String token) async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      AppSnackBar.show(
        context,
        message: l10n.loginValidationWarningMessage,
        type: AppSnackType.warning,
      );

      return;
    }

    final request = ResetPasswordRequest(
      email: email,
      otp: token,
      newPassword: passwordCtrl.text,
      confirmNewPassword: confirmCtrl.text,
    );

    context.read<AuthCubit>().resetPassword(request);
  }

  // ── Shared requirements widget ─────────────────────────
  Widget buildRequirements(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withOpacity(0.80)
            : AppColors.bgTertiary.withOpacity(0.60),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resetPasswordRequirementsTitle,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          _buildRequirementItem(
            l10n.resetPasswordReqMinLength,
            validation.hasMinLength,
          ),
          _buildRequirementItem(
            l10n.resetPasswordReqUppercase,
            validation.hasUppercase,
          ),
          _buildRequirementItem(
            l10n.resetPasswordReqLowercase,
            validation.hasLowercase,
          ),
          _buildRequirementItem(
            l10n.resetPasswordReqNumber,
            validation.hasNumber,
          ),
          _buildRequirementItem(
            l10n.resetPasswordReqSpecial,
            validation.hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet ? AppColors.success : Colors.transparent,
              border: Border.all(
                color: isMet
                    ? AppColors.success
                    : Theme.of(context).colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isMet
                  ? Icon(Icons.check_rounded, size: 12.sp, color: Colors.white)
                  : const SizedBox.shrink(),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: isMet
                  ? AppColors.success
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ResetPasswordMobileBody
// ══════════════════════════════════════════════════════════════
class ResetPasswordMobileBody extends StatefulWidget {
  final AppUserType userType;

  final String email;
  final String token;

  const ResetPasswordMobileBody({
    super.key,
    required this.userType,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordMobileBody> createState() =>
      _ResetPasswordMobileBodyState();
}

class _ResetPasswordMobileBodyState
    extends _ResetBase<ResetPasswordMobileBody> {
  @override
  bool get isHandyman => widget.userType == AppUserType.handyman;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          message: (message) {
            AppSnackBar.show(
              context,
              message: message,
              type: AppSnackType.success,
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl.w,
                    vertical: AppSpacing.xl.h,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Back button ─────────────────────────
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: AppBackButton(
                            isDark: isDark,
                            tapColor: primaryColor,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── Animated icon ────────────────────────
                        a(
                          1,
                          AnimatedActionIcon(
                            icon: Icons.lock_reset_rounded,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // ── Title ────────────────────────────────
                        a(
                          2,
                          Text(
                            l10n.resetPasswordTitle,
                            style: textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // ── Subtitle ─────────────────────────────
                        a(
                          3,
                          Text(
                            l10n.resetPasswordSubtitle,
                            style: textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // ── Password field ───────────────────────
                        a(
                          4,
                          AppPasswordField(
                            label: l10n.resetPasswordNewPassword,
                            hintText: l10n.resetPasswordNewPasswordHint,
                            controller: passwordCtrl,
                            userType: widget.userType,
                            validator: (v) => validatePassword(v, l10n),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── Confirm password field ───────────────
                        a(
                          5,
                          AppPasswordField(
                            label: l10n.resetPasswordConfirmPassword,
                            hintText: l10n.resetPasswordConfirmPasswordHint,
                            controller: confirmCtrl,
                            userType: widget.userType,
                            validator: (v) => validateConfirm(v, l10n),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // ── Requirements ─────────────────────────
                        buildRequirements(l10n),
                        SizedBox(height: 28.h),

                        // ── Submit button ────────────────────────
                        AppGradientButton(
                          label: l10n.resetPasswordSaveButton,
                          gradient: submitGradient,
                          shadowColor: primaryColor.withOpacity(0.30),
                          isLoading: context.watch<AuthCubit>().state.maybeWhen(
                            loading: () => true,
                            orElse: () => false,
                          ),
                          onTap: () => onSave(l10n, widget.email, widget.token),
                        ),
                      ],
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
// ResetPasswordTabletBody — centered card on gradient bg
// ══════════════════════════════════════════════════════════════
class ResetPasswordTabletBody extends StatefulWidget {
  final AppUserType userType;

  final String email;
  final String token;

  const ResetPasswordTabletBody({
    super.key,
    required this.userType,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordTabletBody> createState() =>
      _ResetPasswordTabletBodyState();
}

class _ResetPasswordTabletBodyState
    extends _ResetBase<ResetPasswordTabletBody> {
  @override
  bool get isHandyman => widget.userType == AppUserType.handyman;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          message: (message) {
            AppSnackBar.show(
              context,
              message: message,
              type: AppSnackType.success,
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
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
                      horizontal: AppSpacing.xl.w,
                      vertical: AppSpacing.xl.h,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: EdgeInsets.all(40.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withOpacity(0.95)
                            : Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withOpacity(0.10),
                        ),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Back button ─────────────────────────
                            a(
                              0,
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AppBackButton(
                                  isDark: isDark,
                                  tapColor: primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Animated icon ────────────────────────
                            a(
                              1,
                              AnimatedActionIcon(
                                icon: Icons.lock_reset_rounded,
                                primaryColor: primaryColor,
                                secondaryColor: secondaryColor,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Title ────────────────────────────────
                            a(
                              2,
                              Text(
                                l10n.resetPasswordTitle,
                                style: textTheme.displayLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10.h),

                            // ── Subtitle ─────────────────────────────
                            a(
                              3,
                              Text(
                                l10n.resetPasswordSubtitle,
                                style: textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // ── Password field ───────────────────────
                            a(
                              4,
                              AppPasswordField(
                                label: l10n.resetPasswordNewPassword,
                                hintText: l10n.resetPasswordNewPasswordHint,
                                controller: passwordCtrl,
                                userType: widget.userType,
                                validator: (v) => validatePassword(v, l10n),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // ── Confirm password field ───────────────
                            a(
                              5,
                              AppPasswordField(
                                label: l10n.resetPasswordConfirmPassword,
                                hintText: l10n.resetPasswordConfirmPasswordHint,
                                controller: confirmCtrl,
                                userType: widget.userType,
                                validator: (v) => validateConfirm(v, l10n),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // ── Requirements ─────────────────────────
                            buildRequirements(l10n),
                            SizedBox(height: 28.h),

                            // ── Submit button ────────────────────────
                            AppGradientButton(
                              label: l10n.resetPasswordSaveButton,
                              gradient: submitGradient,
                              shadowColor: primaryColor.withOpacity(0.30),
                              isLoading: context
                                  .watch<AuthCubit>()
                                  .state
                                  .maybeWhen(
                                    loading: () => true,
                                    orElse: () => false,
                                  ),
                              onTap: () =>
                                  onSave(l10n, widget.email, widget.token),
                            ),
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
