import 'dart:async';
import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_otp_field.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/buttons/app_primary_button.dart';
import '../../data/models/requests/forgot_password_request.dart';
import '../../data/models/requests/verify_otp_request.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

// ══════════════════════════════════════════════════════════════
// OtpView — layout router
// ══════════════════════════════════════════════════════════════
class OtpView extends StatelessWidget {
  final String? email;
  final String? sentOtp;

  const OtpView({
    super.key,
    this.email,
    this.sentOtp,
  });

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? OtpTabletBody(email: email, sentOtp: sentOtp,)
          : OtpMobileBody(email: email, sentOtp: sentOtp,),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all state, animations, logic
// ══════════════════════════════════════════════════════════════
abstract class _OtpBase<T extends StatefulWidget> extends State<T> with TickerProviderStateMixin {
  String? get email;
  String? get sentOtp;
  String otpCode = '';
  String? currentOtp;

  static const _timerDuration = 3 * 60;
  int  secondsLeft = _timerDuration;
  bool canResend   = false;
  Timer? _timer;

  // Icon entry — elastic pop
  late final AnimationController entryCtrl;
  late final Animation<double>   entryScale;
  late final Animation<double>   entryOpacity;

  // Float
  late final AnimationController floatCtrl;
  late final Animation<double>   floatY;

  // Glow
  late final AnimationController glowCtrl;
  late final Animation<double>   glowRadius;
  late final Animation<double>   glowOpacity;

  // Page entry stagger
  late final AnimationController pageCtrl;
  late final List<Animation<double>> pageFade;
  late final List<Animation<Offset>>  pageSlide;
  static const _n = 6;

  @override
  void initState() {
    super.initState();
    currentOtp = sentOtp;
    _startTimer();

    // Icon entry
    entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    entryScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl, curve: Curves.elasticOut));
    entryOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    // Float
    floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    floatY = Tween<double>(begin: -5.0, end: 5.0).animate(
        CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut));

    // Glow
    glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    glowRadius = Tween<double>(begin: 10.0, end: 26.0).animate(
        CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut));
    glowOpacity = Tween<double>(begin: 0.15, end: 0.35).animate(
        CurvedAnimation(parent: glowCtrl, curve: Curves.easeInOut));

    // Page stagger
    pageCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    pageFade = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: pageCtrl,
        curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });
    pageSlide = List.generate(_n, (i) {
      final s = (i * 0.12).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.16), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: pageCtrl,
        curve: Interval(s, (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    entryCtrl.forward();
    pageCtrl.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    entryCtrl.dispose();
    floatCtrl.dispose();
    glowCtrl.dispose();
    pageCtrl.dispose();
    super.dispose();
  }

  Widget pa(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: pageFade[idx],
      child: SlideTransition(position: pageSlide[idx], child: child),
    );
  }

  // ── Timer ─────────────────────────────────────────────────
  void _startTimer() {

    setState(() {
      secondsLeft = _timerDuration;
      canResend = false;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }

        setState(() {
          if (secondsLeft > 0) {
            secondsLeft--;
          } else {
            canResend = true;
            t.cancel();
          }
        });
      },
    );
  }

  String get timerText {
    final m = secondsLeft ~/ 60;
    final s = secondsLeft % 60;
    return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Actions ───────────────────────────────────────────────
  Future<void> onVerify(AppLocalizations l10n,) async {

    if (otpCode.length < 6) {

      AppSnackBar.show(
        context,
        message:
        l10n.otpIncompleteMessage,
        type:
        AppSnackType.warning,
      );

      return;
    }

    context.read<AuthCubit>().verifyOtp(VerifyOtpRequest(
      email: email!,
      otp: otpCode,
    ),
    );
  }

  Widget buildOtpPreview() {

    if (currentOtp == null || currentOtp!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange,
        ),
      ),
      child: Text(
        'OTP: $currentOtp',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void onResend(AppLocalizations l10n) {

    if (!canResend) return;

    context.read<AuthCubit>().forgotPassword(
      ForgotPasswordRequest(
        email: email!,
      ),
    );

    _startTimer();
    debugPrint('AFTER RESEND => canResend = $canResend');
  }

  // ── Shared widgets ────────────────────────────────────────
  Widget buildIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([entryCtrl, floatCtrl, glowCtrl]),
      builder: (_, __) => FadeTransition(
        opacity: entryOpacity,
        child: Transform.scale(
          scale: entryScale.value,
          child: Transform.translate(
            offset: Offset(0, floatY.value),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo
                Container(
                  width: 110.w, height: 110.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: AppColors.primary[60]!
                          .withOpacity(glowOpacity.value),
                      blurRadius: glowRadius.value,
                      spreadRadius: glowRadius.value * 0.25,
                    )],
                  ),
                ),
                // Soft ring
                Container(
                  width: 110.w, height: 110.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary[60]!.withOpacity(0.10),
                  ),
                ),
                // Inner gradient circle
                Container(
                  width: 78.w, height: 78.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                    ),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary[60]!.withOpacity(0.35),
                      blurRadius: 16, offset: const Offset(0, 6),
                    )],
                  ),
                  child: Icon(Icons.mark_email_unread_outlined,
                      size: 34.sp, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimer(BuildContext context, AppLocalizations l10n) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.otpExpiresIn,
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
        SizedBox(width: 6.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(timerText,
              key: ValueKey(timerText),
              style: textTheme.bodyLarge?.copyWith(
                color: secondsLeft <= 30
                    ? colorScheme.error
                    : AppColors.primary[60],
                fontWeight: FontWeight.w700,
              )),
        ),
      ],
    );
  }

  Widget buildResend(BuildContext context, AppLocalizations l10n) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      Text(l10n.otpDidntReceive,
          style: textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant)),
      SizedBox(height: 6.h),
      GestureDetector(
        onTap: canResend ? () => onResend(l10n) : null,
        child: AnimatedOpacity(
          opacity: canResend ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 300),
          child: Text(l10n.otpResendButton,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.primary[60],
                fontWeight: FontWeight.w700,
              )),
        ),
      ),
    ]);
  }

  Widget buildBackButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40.w, height: 40.w,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward_rounded,
            color: colorScheme.onSurface, size: 20.sp),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// OtpMobileBody
// ══════════════════════════════════════════════════════════════
class OtpMobileBody extends StatefulWidget {
  final String? email;
  final String? sentOtp;

  const OtpMobileBody({
    super.key,
    this.email,
    this.sentOtp,
  });

  @override
  State<OtpMobileBody> createState() => _OtpMobileBodyState();
}

class _OtpMobileBodyState extends _OtpBase<OtpMobileBody> {
  @override
  String? get email => widget.email;
  @override
  String? get sentOtp => widget.sentOtp;

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final emailStr    = email ?? 'ahmed.***@gmail.com';

    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {

          state.whenOrNull(

            message: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type:
                AppSnackType.success,
              );

              Navigator.pushReplacementNamed(
                context,
                AppRoutes.resetPassword,
                arguments: {
                  'email': email,
                  'otp': otpCode,
                },
              );
            },

            forgotPasswordSuccess: (message, token) {

              setState(() {
                currentOtp = token;
                otpCode = '';
              });

              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.success,
              );
            },

            error: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type:
                AppSnackType.error,
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
                              child: Column(
                                children: [
                                  pa(
                                    0,
                                    Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child: buildBackButton(context),
                                    ),
                                  ),

                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        pa(1, buildIcon()),
                                        SizedBox(height: 28.h),

                                        pa(
                                          2,
                                          Text(
                                            l10n.otpTitle,
                                            style: textTheme.displayMedium,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),

                                        pa(
                                          3,
                                          _EmailSubtitle(
                                            l10n: l10n,
                                            email: emailStr,
                                            textTheme: textTheme,
                                            colorScheme: colorScheme,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),

                                        if (sentOtp != null) ...[
                                          buildOtpPreview(),
                                          SizedBox(height: 16.h),
                                        ],
                                        SizedBox(height: 36.h),

                                        pa(4,
                                          AppOtpField(
                                            key: ValueKey(currentOtp),
                                            onChanged: (code) {
                                              setState(() {
                                                otpCode = code;
                                              });
                                            },
                                            onCompleted: (code) {
                                              setState(() {
                                                otpCode = code;
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 24.h),

                                        pa(5, buildTimer(context, l10n)),
                                        SizedBox(height: 24.h),

                                        AppPrimaryButton(
                                          label: l10n.otpVerifyButton,
                                          onPressed: () => onVerify(l10n),
                                          isLoading: context.watch<AuthCubit>()
                                              .state
                                              .maybeWhen(
                                            loading: () => true,
                                            orElse: () => false,
                                          ),
                                          enabled: otpCode.length == 6 && !canResend,                                        ),
                                        SizedBox(height: 20.h),

                                        buildResend(context, l10n),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
          },);
  }
}

// ══════════════════════════════════════════════════════════════
// OtpTabletBody — centered card on gradient bg
// ══════════════════════════════════════════════════════════════
class OtpTabletBody extends StatefulWidget {
  final String? email;
  final String? sentOtp;

  const OtpTabletBody({
    super.key,
    this.email,
    this.sentOtp,
  });
  @override
  State<OtpTabletBody> createState() => _OtpTabletBodyState();
}

class _OtpTabletBodyState extends _OtpBase<OtpTabletBody> {
  @override
  String? get email => widget.email;
  @override
  String? get sentOtp => widget.sentOtp;

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final emailStr    = email ?? 'ahmed.***@gmail.com';


    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {

          state.whenOrNull(

            message: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type:
                AppSnackType.success,
              );

              Navigator.pushReplacementNamed(
                context,
                AppRoutes.resetPassword,
                arguments: {
                  'email': email,
                  'otp': otpCode,
                },
              );
            },

            forgotPasswordSuccess: (message, token) {

              setState(() {
                currentOtp = token;
                otpCode = '';
              });

              AppSnackBar.show(
                context,
                message: message,
                type: AppSnackType.success,
              );
            },

            error: (message) {

              AppSnackBar.show(
                context,
                message: message,
                type:
                AppSnackType.error,
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
                          vertical: AppSpacing.xl.h),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: EdgeInsets.all(40.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface.withOpacity(0.95)
                              : Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [BoxShadow(
                            color: AppColors.primary[60]!.withOpacity(0.12),
                            blurRadius: 40, offset: const Offset(0, 12),
                          )
                          ],
                          border: Border.all(
                              color: AppColors.primary[60]!.withOpacity(0.10)),
                        ),
                        child: Column(children: [
                          // Back button
                          pa(0, Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: buildBackButton(context),
                          )),
                          SizedBox(height: 24.h),

                          // Animated icon — bigger on tablet
                          pa(1, buildIcon()),
                          SizedBox(height: 28.h),

                          pa(2, Text(l10n.otpTitle,
                              style: textTheme.displayMedium,
                              textAlign: TextAlign.center)),
                          SizedBox(height: 12.h),

                          pa(3, _EmailSubtitle(
                              l10n: l10n, email: emailStr,
                              textTheme: textTheme, colorScheme: colorScheme)),
                          SizedBox(height: 36.h),

                          if (sentOtp != null) ...[
                            buildOtpPreview(),
                            SizedBox(height: 16.h),
                          ],

                          pa(4, AppOtpField(
                            onChanged: (code) => setState(() => otpCode = code),
                              onCompleted: (code) {
                                setState(() {
                                  otpCode = code;
                                });
                              },
                          )),
                          SizedBox(height: 24.h),

                          pa(5, buildTimer(context, l10n)),
                          SizedBox(height: 24.h),

                          AppPrimaryButton(
                            label: l10n.otpVerifyButton,
                            onPressed: () => onVerify(l10n),
                            isLoading: context
                                .watch<AuthCubit>()
                                .state
                                .maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            ),
                            enabled: otpCode.length == 6 && !canResend,                          ),
                          SizedBox(height: 20.h),

                          buildResend(context, l10n),
                          SizedBox(height: 8.h),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },);
  }
}

// ══════════════════════════════════════════════════════════════
// _EmailSubtitle — shared
// ══════════════════════════════════════════════════════════════
class _EmailSubtitle extends StatelessWidget {
  final AppLocalizations l10n;
  final String           email;
  final TextTheme        textTheme;
  final ColorScheme      colorScheme;

  const _EmailSubtitle({
    required this.l10n, required this.email,
    required this.textTheme, required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant, height: 1.7),
        children: [
          TextSpan(text: l10n.otpSubtitle),
          const TextSpan(text: '\n'),
          TextSpan(text: email,
              style: GoogleFonts.cairo(
                color: AppColors.primary[60],
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}