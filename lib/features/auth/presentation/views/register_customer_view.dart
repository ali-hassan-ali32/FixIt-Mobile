import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/di/di.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../lookups/domain/entities/lookup_item_entity.dart';
import '../../../lookups/presentation/cubit/lookup_cubit.dart';
import '../../../lookups/presentation/cubit/lookup_state.dart';

import '../../presentation/cubit/auth_cubit.dart';
import '../../presentation/cubit/auth_state.dart';

import '../../data/models/requests/register_customer_request.dart';


import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_date_field.dart';
import '../../../../core/utils/widgets/app_dropdown_field.dart';
import '../../../../core/utils/widgets/app_info.dart';
import '../../../../core/utils/widgets/app_logo_header.dart';
import '../../../../core/utils/widgets/app_password_field.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/app_step_header.dart';
import '../../../../core/utils/widgets/app_step_navigation.dart';
import '../../../../core/utils/widgets/app_step_progress_bar.dart';
import '../../../../core/utils/widgets/app_terms_modal.dart';
import '../../../../core/utils/widgets/app_text_field.dart';


class RegisterCustomerView extends StatelessWidget {
  const RegisterCustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const RegisterCustomerTabletBody()
          : const RegisterCustomerMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base state — all logic & animations, zero duplication
// ══════════════════════════════════════════════════════════════
abstract class _RegCustomerBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  // Step
  int currentStep = 1;
  static const totalSteps = 3;

  // Form keys
  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();
  final step3Key = GlobalKey<FormState>();

  // Step 1
  final nameCtrl  = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  DateTime? dob;

  // Step 2
  LookupItemEntity? selectedCity;
  LookupItemEntity? selectedRegion;
  final addressLineCtrl = TextEditingController();

  // Step 3
  final passwordCtrl        = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  bool agreeToTerms         = false;

  // Step transition animation
  late AnimationController stepCtrl;
  late Animation<double>   stepFade;
  late Animation<Offset>   stepSlide;

  // Page entry animation
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>>  entrySlide;
  static const _n = 4;

  @override
  void initState() {
    super.initState();

    // Entry stagger
    entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
      ));
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.15).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s, (s + 0.50).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ));
    });

    // Step transition
    stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    stepFade  = CurvedAnimation(parent: stepCtrl, curve: Curves.easeOut);
    stepSlide = Tween<Offset>(
        begin: const Offset(0.06, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: stepCtrl, curve: Curves.easeOut));

    // Step Fetch Lookup Data
    context.read<LookupCubit>().loadCities();

    entryCtrl.forward();
    stepCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    stepCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    addressLineCtrl.dispose();
    super.dispose();
  }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Navigation ────────────────────────────────────────────
  void nextStep(AppLocalizations l10n) {
    FocusScope.of(context).unfocus();
    final keys = [step1Key, step2Key, step3Key];
    if (!keys[currentStep - 1].currentState!.validate()) {
      AppSnackBar.show(context,
          message: l10n.loginValidationWarningMessage,
          type: AppSnackType.warning);
      return;
    }
    if (currentStep == totalSteps) { onSubmit(l10n); return; }
    HapticFeedback.selectionClick();
    setState(() => currentStep++);
    stepCtrl.forward(from: 0);
  }

  void prevStep() {
    if (currentStep <= 1) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    setState(() => currentStep--);
    stepCtrl.forward(from: 0);
  }

  Future<void> onSubmit(AppLocalizations l10n,) async {

    if (!agreeToTerms) {
      AppSnackBar.show(
        context,
        message: l10n.validationTermsRequired,
        type: AppSnackType.warning,
      );
      return;
    }

    final request = RegisterCustomerRequest(
      fullName: nameCtrl.text.trim(),
      phoneNumber: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
      confirmPassword: confirmPasswordCtrl.text,
      birthDate: dob!,
      cityId: selectedCity!.id,
      regionId: selectedRegion!.id,
      addressLine: addressLineCtrl.text.trim(),
    );

    context.read<AuthCubit>().registerCustomer(request);
  }

  // ── Validators ────────────────────────────────────────────
  String? vName(String? v, AppLocalizations l)    =>
      (v == null || v.trim().isEmpty) ? l.validationNameRequired :
      v.trim().length < 2 ? l.validationNameShort : null;
  String? vEmail(String? v, AppLocalizations l)   =>
      (v == null || v.trim().isEmpty) ? l.validationEmailRequired :
      !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(v.trim())
          ? l.validationEmailInvalid : null;
  String? vPhone(String? v, AppLocalizations l)   {
    if (v == null || v.trim().isEmpty) return l.validationPhoneRequired;
    final c = v.replaceAll(RegExp(r'[\s\-\+]'), '');
    return RegExp(r'^(0020|20)?01[0125][0-9]{8}$').hasMatch(c)
        ? null : l.validationPhoneInvalid;
  }
  String? vDob(DateTime? v, AppLocalizations l)   => v == null ? l.validationDobRequired : null;
  String? vCity(String? v, AppLocalizations l)    => (v == null || v.isEmpty) ? l.validationCityRequired : null;
  String? vRegion(String? v, AppLocalizations l)  => (v == null || v.isEmpty) ? l.validationRegionRequired : null;
  String? vPass(String? v, AppLocalizations l)    =>
      (v == null || v.isEmpty) ? l.validationPasswordRequired :
      v.length < 8 ? l.validationPasswordShort8 : null;
  String? vConfirm(String? v, AppLocalizations l) =>
      (v == null || v.isEmpty) ? l.validationPasswordRequired :
      v != passwordCtrl.text ? l.validationPasswordMismatch : null;

  // ── Step forms ────────────────────────────────────────────
  Widget buildStep1(AppLocalizations l10n) => Form(
    key: step1Key,
    child: Column(children: [
      AppStepHeader(
          icon: Icons.person_outline_rounded,
          gradient: [AppColors.primary[60]!, AppColors.secondary[60]!],
          title: l10n.step1Title, subtitle: l10n.step1Subtitle),
      SizedBox(height: 24.h),
      AppTextField(label: l10n.fullName, hintText: l10n.fullNamePlaceholder,
          controller: nameCtrl, validator: (v) => vName(v, l10n)),
      SizedBox(height: 16.h),
      AppTextField(label: l10n.email, hintText: l10n.emailPlaceholder,
          controller: emailCtrl, keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          validator: (v) => vEmail(v, l10n)),
      SizedBox(height: 16.h),
      AppTextField(label: l10n.phoneNumber, hintText: l10n.phonePlaceholder,
          controller: phoneCtrl, keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr, textAlign: TextAlign.left,
          validator: (v) => vPhone(v, l10n)),
      SizedBox(height: 16.h),
      AppDateField(label: l10n.dateOfBirth, hintText: l10n.dateOfBirthPlaceholder,
          selectedDate: dob,
          onDateSelected: (d) => setState(() => dob = d),
          validator: (v) => vDob(v, l10n)),
      SizedBox(height: 24.h),
      AppStepNavigation(nextLabel: l10n.nextButton,
          onNext: () => nextStep(l10n)),
    ]),
  );

  Widget buildStep2(AppLocalizations l10n) {
    final lookupState = context.watch<LookupCubit>().state;

    final List<LookupItemEntity> cities =
    lookupState.maybeWhen(
      loaded: (
          cities,
          regions,
          categories,
          ) =>
      cities,
      orElse: () => <LookupItemEntity>[],
    );

    final List<LookupItemEntity> regions =
    lookupState.maybeWhen(
      loaded: (
          cities,
          regions,
          categories,
          ) =>
      regions,
      orElse: () => <LookupItemEntity>[],
    );


    return Form(
      key: step2Key,
      child: Column(children: [
        AppStepHeader(
            icon: Icons.location_on_outlined,
            gradient: [AppColors.primary[60]!, AppColors.secondary[60]!],
            title: l10n.step2Title, subtitle: l10n.step2Subtitle),
        SizedBox(height: 24.h),
        if (lookupState is LookupLoading)
          const Center(child: CircularProgressIndicator(),),

        AppDropdownField<String>(
          label: l10n.city,
          hintText: l10n.cityPlaceholder,
          value: selectedCity?.name,
          items: cities.map((e) => e.name).toList(),
          onChanged: (v) {
            setState(() {
              selectedCity = cities.firstWhere((e) => e.name == v,);

              selectedRegion = null;

              context.read<LookupCubit>().loadRegions(selectedCity!.id,);
            });
          },
          validator: (v) => vCity(v, l10n),
        ),
        SizedBox(height: 16.h),
        AppDropdownField<String>(
            label: l10n.region,
            hintText: l10n.regionPlaceholder,
            value: selectedRegion?.name,
            items: regions.map((e) => e.name,).toList(),
            onChanged:  (v) {
              setState(() {
                selectedRegion = regions.firstWhere((e) => e.name == v,);
              });
            },
            validator: (v) => vRegion(v, l10n)),

        SizedBox(height: 16.h),
        AppTextField(
          label: l10n.addressLine,
          hintText: l10n.addressLinePlaceholder,
          controller: addressLineCtrl,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? l10n.validationAddressRequired
              : null,
        ),

        SizedBox(height: 24.h),
        AppStepNavigation(nextLabel: l10n.nextButton,
            previousLabel: l10n.previousButton,
            onNext: () => nextStep(l10n), onPrevious: prevStep),
      ]),
    );
  }

  Widget buildStep3(AppLocalizations l10n) => Form(
    key: step3Key,
    child: Column(children: [
      AppStepHeader(
          icon: Icons.lock_outline_rounded,
          gradient: [AppColors.secondary[50]!, AppColors.primary[60]!],
          title: l10n.step3Title, subtitle: l10n.step3Subtitle),
      SizedBox(height: 24.h),
      AppPasswordField(label: l10n.password, hintText: l10n.passwordHint,
          controller: passwordCtrl, validator: (v) => vPass(v, l10n)),
      SizedBox(height: 16.h),
      AppPasswordField(label: l10n.confirmPassword,
          hintText: l10n.confirmPasswordPlaceholder,
          controller: confirmPasswordCtrl,
          validator: (v) => vConfirm(v, l10n)),
      SizedBox(height: 20.h),
      _TermsRow(
        agreeToTerms: agreeToTerms,
        onChanged: (v) => setState(() => agreeToTerms = v),
        onTermsTap: () => AppTermsModal.show(context),
        l10n: l10n,
      ),
      if (!agreeToTerms) ...[
        SizedBox(height: 8.h),
        AppInfoBox(
            message: l10n.validationTermsRequired,
            type: AppInfoBoxType.warning),
      ],
      SizedBox(height: 24.h),
      AppStepNavigation(
          nextLabel: l10n.createAccountButton,
          previousLabel: l10n.previousButton,
          onNext: () => nextStep(l10n),
          onPrevious: prevStep,
        isLoading: context.watch<AuthCubit>().state
            .maybeWhen(
          loading: () => true,
          orElse: () => false,
        ),),
    ]),
  );

  Widget buildCurrentStep(AppLocalizations l10n) {
    Widget step;
    switch (currentStep) {
      case 1: step = buildStep1(l10n); break;
      case 2: step = buildStep2(l10n); break;
      default: step = buildStep3(l10n);
    }
    return FadeTransition(
      opacity: stepFade,
      child: SlideTransition(position: stepSlide, child: step),
    );
  }

  Widget buildLoginLink(AppLocalizations l10n) =>
      _LoginLink(l10n: l10n,
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(AppRoutes.login));

  List<String> stepLabels(AppLocalizations l10n) => [
    l10n.stepPersonalInfo,
    l10n.stepContact,
    l10n.stepSecurity,
  ];
}

// ══════════════════════════════════════════════════════════════
// RegisterCustomerMobileBody
// ══════════════════════════════════════════════════════════════
class RegisterCustomerMobileBody extends StatefulWidget {
  const RegisterCustomerMobileBody({super.key});

  @override
  State<RegisterCustomerMobileBody> createState() =>
      _RegisterCustomerMobileBodyState();
}

class _RegisterCustomerMobileBodyState
    extends _RegCustomerBase<RegisterCustomerMobileBody> {

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (user) async {
            AppSnackBar.show(
              context,
              message: l10n.registerSuccessMessage,
              type: AppSnackType.success,
            );

            if (!context.mounted) return;

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.customerHome,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl.w, vertical: AppSpacing.xl.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    ea(0, AppLogoHeader(
                        title: l10n.registerCustomerTitle,
                        subtitle: l10n.createNewAccount,
                        logoSize: 36)),
                    SizedBox(height: 24.h),
                    ea(1, AppStepProgressBar(
                        currentStep: currentStep,
                        steps: stepLabels(l10n))),
                    SizedBox(height: 28.h),
                    ea(2, buildCurrentStep(l10n)),
                    SizedBox(height: 24.h),
                    ea(3, buildLoginLink(l10n)),
                    SizedBox(height: 24.h),
                  ],
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
// RegisterCustomerTabletBody
// Left: brand panel with step indicator. Right: form.
// ══════════════════════════════════════════════════════════════
class RegisterCustomerTabletBody extends StatefulWidget {
  const RegisterCustomerTabletBody({super.key});

  @override
  State<RegisterCustomerTabletBody> createState() =>
      _RegisterCustomerTabletBodyState();
}

class _RegisterCustomerTabletBodyState
    extends _RegCustomerBase<RegisterCustomerTabletBody> {

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final labels = stepLabels(l10n);

    return BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {

          state.whenOrNull(

            success: (user) async {

              AppSnackBar.show(
                context,
                message: l10n.registerSuccessMessage,
                type: AppSnackType.success,
              );


              if (!context.mounted) return;

              Navigator.pushReplacementNamed(
                context,
                AppRoutes.customerHome,
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
            body: Row(
              children: [
                // ── Left: brand + step overview (35%) ───────
                Expanded(
                  flex: 35,
                  child: _TabletSidePanel(
                    currentStep: currentStep,
                    totalSteps: _RegCustomerBase.totalSteps,
                    stepLabels: labels,
                    entryCtrl: entryCtrl,
                  ),
                ),

                // ── Right: form (65%) ────────────────────────
                Expanded(
                  flex: 65,
                  child: AppAuthBackground(
                    showPattern: false,
                    child: SizedBox.expand(
                      child: SafeArea(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.w, vertical: 32.h),
                            child: Column(
                              children: [
                                ea(0, AppStepProgressBar(
                                    currentStep: currentStep,
                                    steps: labels)),
                                SizedBox(height: 28.h),
                                ea(1, buildCurrentStep(l10n)),
                                SizedBox(height: 24.h),
                                ea(2, buildLoginLink(l10n)),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TabletSidePanel — brand + animated step overview
// ══════════════════════════════════════════════════════════════
class _TabletSidePanel extends StatefulWidget {
  final int                  currentStep;
  final int                  totalSteps;
  final List<String>         stepLabels;
  final AnimationController  entryCtrl;

  const _TabletSidePanel({
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.entryCtrl,
  });

  @override
  State<_TabletSidePanel> createState() => _TabletSidePanelState();
}

class _TabletSidePanelState extends State<_TabletSidePanel>
    with SingleTickerProviderStateMixin {

  late final AnimationController _floatCtrl;
  late final Animation<double>   _floatY;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatY = Tween<double>(begin: -8.0, end: 8.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _floatCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary[60]!,
            AppColors.secondary[60]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating logo
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: widget.entryCtrl,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
                child: AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _floatY.value),
                    child: Container(
                      width: 88.w, height: 88.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35), width: 2),
                      ),
                      child: Center(
                        child: Text('FixIt',
                            style: GoogleFonts.cairo(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Brand text
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: widget.entryCtrl,
                    curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
                child: Text('إنشاء حساب',
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 8.h),
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: widget.entryCtrl,
                    curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
                child: Text('خطوة بخطوة\nحتى تنضم لمجتمعنا',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.82),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: 40.h),

              // Animated step list
              ...List.generate(widget.totalSteps, (i) {
                final stepNum   = i + 1;
                final isDone    = stepNum < widget.currentStep;
                final isActive  = stepNum == widget.currentStep;
                return _StepRow(
                  stepNum: stepNum,
                  label: widget.stepLabels[i],
                  isDone: isDone,
                  isActive: isActive,
                  entryCtrl: widget.entryCtrl,
                  delay: 0.4 + i * 0.12,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step row inside side panel ────────────────────────────────
class _StepRow extends StatelessWidget {
  final int                  stepNum;
  final String               label;
  final bool                 isDone;
  final bool                 isActive;
  final AnimationController  entryCtrl;
  final double               delay;

  const _StepRow({
    required this.stepNum, required this.label,
    required this.isDone,  required this.isActive,
    required this.entryCtrl, required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.35).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: entryCtrl,
            curve: Interval(delay.clamp(0.0, 1.0), end,
                curve: Curves.easeOut)));
    final slide = Tween<Offset>(
        begin: const Offset(-0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: entryCtrl,
        curve: Interval(delay.clamp(0.0, 1.0), end,
            curve: Curves.easeOutCubic)));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36.w, height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.white
                      : isDone
                      ? Colors.white.withOpacity(0.35)
                      : Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(
                          isActive ? 1.0 : isDone ? 0.5 : 0.3),
                      width: 1.5),
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded,
                      size: 16.sp,
                      color: Colors.white)
                      : Text('$stepNum',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? AppColors.primary[60]
                            : Colors.white.withOpacity(0.7),
                      )),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: isActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: Colors.white
                          .withOpacity(isActive ? 1.0 : 0.65),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TermsRow — shared
// ══════════════════════════════════════════════════════════════
class _TermsRow extends StatelessWidget {
  final bool             agreeToTerms;
  final ValueChanged<bool> onChanged;
  final VoidCallback     onTermsTap;
  final AppLocalizations l10n;

  const _TermsRow({
    required this.agreeToTerms,
    required this.onChanged,
    required this.onTermsTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 24.w, height: 24.h,
          child: Checkbox(
            value: agreeToTerms,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary[60],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r)),
          ),
        ),
        SizedBox(width: 8.w),
        Text(l10n.agreeToTerms, style: textTheme.bodyLarge),
        GestureDetector(
          onTap: onTermsTap,
          child: Text(l10n.termsLink,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.primary[60],
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary[60],
              )),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _LoginLink — shared
// ══════════════════════════════════════════════════════════════
class _LoginLink extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback     onTap;

  const _LoginLink({required this.l10n, required this.onTap});

  @override
  State<_LoginLink> createState() => _LoginLinkState();
}

class _LoginLinkState extends State<_LoginLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.94)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.l10n.alreadyHaveAccountLogin,
            style: textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w400)),
        SizedBox(width: 4.w),
        GestureDetector(
          onTapDown: (_) {
            _ctrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
          onTapCancel: () => _ctrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Text(widget.l10n.signInLink,
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary[60],
                )),
          ),
        ),
      ],
    );
  }
}