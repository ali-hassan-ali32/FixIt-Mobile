import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/di/di.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_logo_header.dart';
import '../../../../core/utils/widgets/app_password_field.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../../core/utils/widgets/buttons/app_primary_button.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/buttons/app_text_button.dart';
import '../../../../core/utils/widgets/app_checkbox.dart';
import '../../data/models/requests/login_request.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';



// ══════════════════════════════════════════════════════════════
// LoginView — layout router
// ══════════════════════════════════════════════════════════════
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const LoginTabletBody()
          : const LoginMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base state — animations + logic, zero duplication
// ══════════════════════════════════════════════════════════════
abstract class _LoginBaseState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneFocus = FocusNode();
  final passwordFocus = FocusNode();

  bool rememberMe = false;


  late final AnimationController entryCtrl;
  late final List<Animation<double>> fadeAnims;
  late final List<Animation<Offset>> slideAnims;

  static const _n = 8;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    fadeAnims = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.40).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    slideAnims = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    entryCtrl.forward();

    // final customerCubit = context.read<CustomerCubit>();
    // customerCubit.getProfile();
    // customerCubit.getRequests();
    // customerCubit.getStatistics();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Widget a(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: fadeAnims[idx],
      child: SlideTransition(
        position: slideAnims[idx],
        child: child,
      ),
    );
  }

  String? validatePhone(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.validationPhoneRequired;

    final c = v.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^(0020|20)?01[0125][0-9]{8}$').hasMatch(c)) {
      return l10n.validationPhoneInvalid;
    }

    return null;
  }

  String? validatePassword(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.validationPasswordRequired;
    if (v.length < 6) return l10n.validationPasswordShort;
    return null;
  }

  Future<void> onLogin(
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

    final request = LoginRequest(
      phoneNumber:
      phoneCtrl.text.trim(),
      password:
      passwordCtrl.text,
    );

    context.read<AuthCubit>().login(request);
  }
}

// ══════════════════════════════════════════════════════════════
// LoginMobileBody
// ══════════════════════════════════════════════════════════════
class LoginMobileBody extends StatefulWidget {
  const LoginMobileBody({super.key});

  @override
  State<LoginMobileBody> createState() => _LoginMobileBodyState();
}

class _LoginMobileBodyState extends _LoginBaseState<LoginMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {

        state.whenOrNull(

          success: (user) async {

            await getIt<SecureStorageService>().saveToken(user.token,);

            await getIt<SecureStorageService>()
                .saveRole(
              user.role,
            );

            final token = await getIt<SecureStorageService>().getToken();

            debugPrint(
              'TOKEN => $token',
            );

            AppSnackBar.show(
              context,
              message: 'Login successful',
              type: AppSnackType.success,
            );

            await setRememberMe(
              rememberMe,
            );

            if (!context.mounted) return;

            switch (
            user.role.toLowerCase()
            ) {

              case 'customer':

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.customerHome,
                );
                break;

              case 'handyman':

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.handymanHome,
                );
                break;

              default:

                AppSnackBar.show(
                  context,
                  message:
                  'Unknown user role: ${user.role}',
                  type:
                  AppSnackType.error,
                );
            }
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
                        SizedBox(height: 32.h),

                        a(
                          0,
                          AppLogoHeader(
                            title: l10n.loginWelcomeBack,
                            subtitle: l10n.loginSubtitle,
                          ),
                        ),
                        SizedBox(height: 40.h),

                        a(
                          1,
                          AppTextField(
                            label: l10n.phoneNumber,
                            hintText: l10n.phonePlaceholder,
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            validator: (v) => validatePhone(v, l10n),
                          ),
                        ),
                        SizedBox(height: 18.h),

                        a(
                          2,
                          AppPasswordField(
                            label: l10n.password,
                            hintText: l10n.passwordHint,
                            controller: passwordCtrl,
                            validator: (v) => validatePassword(v, l10n),
                          ),
                        ),
                        SizedBox(height: 4.h),

                        a(
                          3,
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: AppTextButton(
                              label: l10n.forgotPassword,
                              onPressed: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.forgotPassword),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        a(
                          4,
                          AppCheckbox(
                            label: l10n.rememberMe,
                            value: rememberMe,
                            onChanged: (v) => setState(() => rememberMe = v),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // a(5, buildRoleSwitch()),
                        SizedBox(height: 24.h),

                        a(
                          6,
                          AppPrimaryButton(
                            label: l10n.loginButton,
                            onPressed: () => onLogin(l10n),
                            isLoading:
                            context.watch<AuthCubit>().state
                                .maybeWhen(
                              loading: () => true,
                              orElse: () => false,
                            ),                          ),
                        ),
                        SizedBox(height: 28.h),

                        a(
                          7,
                          _RegisterRow(
                            textTheme: textTheme,
                            l10n: l10n,
                          ),
                        ),
                      ],
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
// LoginTabletBody — split panel: brand left / form right
// ══════════════════════════════════════════════════════════════
class LoginTabletBody extends StatefulWidget {
  const LoginTabletBody({super.key});

  @override
  State<LoginTabletBody> createState() => _LoginTabletBodyState();
}

class _LoginTabletBodyState extends _LoginBaseState<LoginTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {

        state.whenOrNull(

          success: (user) async {

            await getIt<SecureStorageService>()
                .saveToken(
              user.token,
            );

            await getIt<SecureStorageService>()
                .saveRole(
              user.role,
            );

            await setRememberMe(
              rememberMe,
            );

            if (!context.mounted) return;

            switch (
            user.role.toLowerCase()
            ) {

              case 'customer':

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.customerHome,
                );
                break;

              case 'handyman':

                Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.handymanHome,
                );
                break;

              default:

                AppSnackBar.show(
                  context,
                  message:
                  'Unknown user role: ${user.role}',
                  type:
                  AppSnackType.error,
                );
            }
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 35,
                      child: a(
                        0,
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary[60]!,
                                AppColors.secondary[60]!.withOpacity(0.88),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (b) => const LinearGradient(
                                      colors: [Colors.white, Color(0xFFFFE8D6)],
                                    ).createShader(b),
                                    child: Text(
                                      'FixIt',
                                      style: GoogleFonts.cairo(
                                        fontSize: 80.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -2,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 28.h),
                                  Text(
                                    l10n.splashTagline,
                                    style: GoogleFonts.cairo(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    l10n.splashSubtitle,
                                    style: GoogleFonts.cairo(
                                      fontSize: 15.sp,
                                      color: Colors.white.withOpacity(0.88),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 65,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.w,
                          vertical: 40.h,
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              a(
                                1,
                                Column(
                                  children: [
                                    Text(
                                      l10n.loginWelcomeBack,
                                      style: textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      l10n.loginSubtitle,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 36.h),

                              a(
                                2,
                                AppTextField(
                                  label: l10n.phoneNumber,
                                  hintText: l10n.phonePlaceholder,
                                  controller: phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  validator: (v) => validatePhone(v, l10n),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              a(
                                3,
                                AppPasswordField(
                                  label: l10n.password,
                                  hintText: l10n.passwordHint,
                                  controller: passwordCtrl,
                                  validator: (v) => validatePassword(v, l10n),
                                ),
                              ),
                              SizedBox(height: 8.h),

                              a(
                                4,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppCheckbox(
                                      label: l10n.rememberMe,
                                      value: rememberMe,
                                      onChanged: (v) =>
                                          setState(() => rememberMe = v),
                                    ),
                                    AppTextButton(
                                      label: l10n.forgotPassword,
                                      onPressed: () => Navigator.of(context)
                                          .pushNamed(AppRoutes.forgotPassword),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // a(5, buildRoleSwitch()),
                              SizedBox(height: 24.h),

                              a(
                                6,
                                AppPrimaryButton(
                                  label: l10n.loginButton,
                                  onPressed: () => onLogin(l10n),
                                  isLoading:
                                  context.watch<AuthCubit>().state
                                      .maybeWhen(
                                    loading: () => true,
                                    orElse: () => false,
                                  ),
                                ),
                              ),
                              SizedBox(height: 28.h),

                              a(
                                7,
                                _RegisterRow(
                                  textTheme: textTheme,
                                  l10n: l10n,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _RegisterRow — shared by both layouts
// ══════════════════════════════════════════════════════════════
class _RegisterRow extends StatefulWidget {
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _RegisterRow({
    required this.textTheme,
    required this.l10n,
  });

  @override
  State<_RegisterRow> createState() => _RegisterRowState();
}

class _RegisterRowState extends State<_RegisterRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(
    CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
    ),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.l10n.noAccount,
          style: widget.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12.h),
        GestureDetector(
          onTapDown: (_) {
            _ctrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _ctrl.reverse();
            Navigator.of(context).pushNamed(AppRoutes.chooseRole);
          },
          onTapCancel: () => _ctrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary[60]!.withOpacity(0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Text(
                widget.l10n.registerButton,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary[60],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}