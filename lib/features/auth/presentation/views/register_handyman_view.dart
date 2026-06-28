import 'dart:io';

import 'package:fix_it/config/constants/enums/app_enums.dart';
import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/di/di.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/app_auth_background.dart';
import '../../../../core/utils/widgets/app_category_selector.dart';
import '../../../../core/utils/widgets/app_date_field.dart';
import '../../../../core/utils/widgets/app_dropdown_field.dart';
import '../../../../core/utils/widgets/app_file_uploader.dart';
import '../../../../core/utils/widgets/app_info.dart';
import '../../../../core/utils/widgets/app_logo_header.dart';
import '../../../../core/utils/widgets/app_password_field.dart';
import '../../../../core/utils/widgets/app_snack_bar.dart';
import '../../../../core/utils/widgets/app_step_header.dart';
import '../../../../core/utils/widgets/app_step_navigation.dart';
import '../../../../core/utils/widgets/app_step_progress_bar.dart';
import '../../../../core/utils/widgets/app_terms_checkbox.dart';
import '../../../../core/utils/widgets/app_terms_modal.dart';
import '../../../../core/utils/widgets/app_text_field.dart';
import '../../../lookups/domain/entities/lookup_item_entity.dart';
import '../../../lookups/presentation/cubit/lookup_cubit.dart';
import '../../../lookups/presentation/cubit/lookup_state.dart';
import '../../data/models/requests/register_handyman_request.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterHandymanView extends StatelessWidget {
  const RegisterHandymanView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const RegisterHandymanTabletBody()
          : const RegisterHandymanMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all logic, validators, step builders
// ══════════════════════════════════════════════════════════════
abstract class _RegHandymanBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  int currentStep = 1;
  static const totalSteps = 4;

  final step1Key = GlobalKey<FormState>();
  final step2Key = GlobalKey<FormState>();
  final step3Key = GlobalKey<FormState>();
  final step4Key = GlobalKey<FormState>();

  // Step 1
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  DateTime? dob;

  // Step 2
  LookupItemEntity? selectedCity;
  LookupItemEntity? selectedRegion;
  LookupItemEntity? selectedCategory;
  final addressLineCtrl = TextEditingController();

  // Step 3
  String? selectedExperience;
  List<String> selectedCategoryIds = [];
  final rateCtrl = TextEditingController();
  // final bioCtrl  = TextEditingController();

  // Step 4
  bool nationalIdSelected = false;
  bool profilePhotoSelected = false;
  bool agreeToTerms = false;
  final ImagePicker picker = ImagePicker();
  File? profilePhoto;
  String? profilePhotoName;
  File? nationalIdPhoto;
  String? nationalIdPhotoName;

  // Entry stagger
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  // Step transition
  late AnimationController stepCtrl;
  late Animation<double> stepFade;
  late Animation<Offset> stepSlide;

  static const _n = 5;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.14).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.50).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    stepFade = CurvedAnimation(parent: stepCtrl, curve: Curves.easeOut);
    stepSlide = Tween<Offset>(
      begin: const Offset(0.06, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: stepCtrl, curve: Curves.easeOut));

    entryCtrl.forward();
    stepCtrl.forward();

    // Fetch Lookup Data
    _loadLookups();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    stepCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    final lookupCubit = context.read<LookupCubit>();

    await lookupCubit.loadCities();
    await lookupCubit.loadCategories();
  }

  Future<void> pickNationalIdPhoto() async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        nationalIdPhoto = File(image.path);
        nationalIdPhotoName = image.name;
        nationalIdSelected = true;
      });
    }
  }

  Future<void> pickProfilePhoto() async {
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profilePhoto = File(image.path);
        profilePhotoName = image.name;
        profilePhotoSelected = true;
      });
    }
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
    final keys = [step1Key, step2Key, step3Key, step4Key];
    if (!keys[currentStep - 1].currentState!.validate()) {
      AppSnackBar.show(
        context,
        message: l10n.loginValidationWarningMessage,
        type: AppSnackType.warning,
      );
      return;
    }
    if (currentStep == totalSteps) {
      onSubmit(l10n);
      return;
    }
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

  int _mapExperienceYears() {
    switch (selectedExperience) {
      case 'أقل من سنة':
        return 0;

      case '1 - 3 سنوات':
        return 2;

      case '3 - 5 سنوات':
        return 4;

      case '5 - 10 سنوات':
        return 7;

      default:
        return 10;
    }
  }

  Future<void> onSubmit(AppLocalizations l10n) async {
    if (!agreeToTerms) {
      AppSnackBar.show(
        context,
        message: l10n.validationTermsRequired,
        type: AppSnackType.warning,
      );
      return;
    }

    final request = RegisterHandymanRequest(
      fullName: nameCtrl.text.trim(),
      phoneNumber: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
      confirmPassword: passwordCtrl.text,
      birthDate: dob!,
      cityId: selectedCity!.id,
      regionId: selectedRegion!.id,
      addressLine: addressLineCtrl.text.trim(),
      categoryId: selectedCategoryIds.first.toString(),
      yearsOfExperience: _mapExperienceYears(),
      nationalIdImageUrl: nationalIdPhoto!.path,
      basePrice: int.tryParse(rateCtrl.text) ?? 0,
    );

    context.read<AuthCubit>().registerHandyman(request);
  }

  // ── Validators ────────────────────────────────────────────
  String? vName(String? v, AppLocalizations l) => v == null || v.trim().isEmpty
      ? l.validationNameRequired
      : v.trim().length < 2
      ? l.validationNameShort
      : null;
  String? vEmail(String? v, AppLocalizations l) => v == null || v.trim().isEmpty
      ? l.validationEmailRequired
      : !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(v.trim())
      ? l.validationEmailInvalid
      : null;
  String? vDob(DateTime? v, AppLocalizations l) =>
      v == null ? l.validationDobRequired : null;

  String? vPhone(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.validationPhoneRequired;
    final c = v.replaceAll(RegExp(r'[\s\-\+]'), '');
    return RegExp(r'^(0020|20)?01[0125][0-9]{8}$').hasMatch(c)
        ? null
        : l.validationPhoneInvalid;
  }

  String? vPassword(String? v, AppLocalizations l) => v == null || v.isEmpty
      ? l.validationPasswordRequired
      : v.length < 8
      ? l.validationPasswordShort8
      : null;
  String? vCity(String? v, AppLocalizations l) =>
      v == null || v.isEmpty ? l.validationCityRequired : null;
  String? vRegion(String? v, AppLocalizations l) =>
      v == null || v.isEmpty ? l.validationRegionRequired : null;
  String? vExp(String? v, AppLocalizations l) =>
      v == null || v.isEmpty ? l.validationExperienceRequired : null;
  String? vCats(List<String> ids, AppLocalizations l) =>
      ids.isEmpty ? l.validationSpecializationRequired : null;
  String? vRate(String? v, AppLocalizations l) =>
      v == null || v.trim().isEmpty ? l.validationHourlyRateRequired : null;
  String? vNatId(bool sel, AppLocalizations l) =>
      !sel ? l.validationNationalIdRequired : null;

  // ── Step builders ─────────────────────────────────────────
  Widget buildStep1(AppLocalizations l10n) => Form(
    key: step1Key,
    child: Column(
      children: [
        AppStepHeader(
          icon: Icons.build_outlined,
          gradient: [AppColors.accent[60]!, AppColors.accent[70]!],
          title: l10n.handymanStep1Title,
          subtitle: l10n.handymanStep1Subtitle,
        ),
        SizedBox(height: 24.h),
        AppTextField(
          label: l10n.fullName,
          hintText: l10n.fullNamePlaceholder,
          controller: nameCtrl,
          userType: AppUserType.handyman,
          validator: (v) => vName(v, l10n),
        ),
        SizedBox(height: 16.h),
        AppTextField(
          label: l10n.email,
          hintText: l10n.emailPlaceholder,
          userType: AppUserType.handyman,
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          validator: (v) => vEmail(v, l10n),
        ),
        SizedBox(height: 16.h),
        AppTextField(
          label: l10n.phoneNumber,
          userType: AppUserType.handyman,
          hintText: l10n.phonePlaceholder,
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          validator: (v) => vPhone(v, l10n),
        ),
        SizedBox(height: 16.h),
        AppPasswordField(
          label: l10n.password,
          userType: AppUserType.handyman,
          hintText: l10n.passwordHint,
          controller: passwordCtrl,
          validator: (v) => vPassword(v, l10n),
        ),

        SizedBox(height: 16.h),
        AppDateField(
          label: l10n.dateOfBirth,
          hintText: l10n.dateOfBirthPlaceholder,
          selectedDate: dob,
          activeColor: AppColors.accent[60]!,
          onDateSelected: (d) => setState(() => dob = d),
          validator: (v) => vDob(v, l10n),
        ),

        SizedBox(height: 24.h),
        AppStepNavigation(
          nextLabel: l10n.nextButton,
          userType: AppUserType.handyman,
          onNext: () => nextStep(l10n),
        ),
      ],
    ),
  );

  Widget buildStep2(AppLocalizations l10n) {
    final lookupState = context.watch<LookupCubit>().state;

    final cities = lookupState.maybeWhen(
      loaded: (cities, regions, categories) => cities,
      orElse: () => <LookupItemEntity>[],
    );

    final regions = lookupState.maybeWhen(
      loaded: (cities, regions, categories) => regions,
      orElse: () => <LookupItemEntity>[],
    );

    return Form(
      key: step2Key,
      child: Column(
        children: [
          AppStepHeader(
            icon: Icons.location_on_outlined,
            gradient: [AppColors.accent[60]!, AppColors.accent[70]!],
            title: l10n.handymanStep2Title,
            subtitle: l10n.handymanStep2Subtitle,
          ),
          SizedBox(height: 24.h),
          AppDropdownField<String>(
            label: l10n.city,
            hintText: l10n.cityPlaceholder,
            value: selectedCity?.name,
            userType: AppUserType.handyman,
            items: cities.map((e) => e.name).toList(),
            onChanged: (value) {
              setState(() {
                selectedCity = cities.firstWhere((e) => e.name == value);
                selectedRegion = null;
              });

              context.read<LookupCubit>().loadRegions(selectedCity!.id);
            },
            validator: (v) => vCity(v, l10n),
          ),
          SizedBox(height: 16.h),
          AppDropdownField<String>(
            label: l10n.region,
            userType: AppUserType.handyman,
            hintText: l10n.regionPlaceholder,
            value: selectedRegion?.name,
            items: regions.map((e) => e.name).toList(),
            onChanged: (v) {
              setState(() {
                selectedRegion = regions.firstWhere((e) => e.name == v);
              });
            },
            validator: (v) => vRegion(v, l10n),
          ),

          SizedBox(height: 16.h),
          AppTextField(
            label: l10n.addressLine,
            userType: AppUserType.handyman,
            hintText: l10n.addressLinePlaceholder,
            controller: addressLineCtrl,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.validationAddressRequired
                : null,
          ),

          SizedBox(height: 24.h),
          AppStepNavigation(
            nextLabel: l10n.nextButton,
            previousLabel: l10n.previousButton,
            userType: AppUserType.handyman,
            onNext: () => nextStep(l10n),
            onPrevious: prevStep,
          ),
        ],
      ),
    );
  }

  Widget buildStep3(AppLocalizations l10n) {
    final lookupState = context.watch<LookupCubit>().state;

    final categories = lookupState.maybeWhen(
      loaded: (cities, regions, categories) => categories,
      orElse: () => <LookupItemEntity>[],
    );

    return Form(
      key: step3Key,
      child: Column(
        children: [
          AppStepHeader(
            icon: Icons.build_outlined,
            gradient: [AppColors.accent[50]!, AppColors.accent[60]!],
            title: l10n.handymanStep3Title,
            subtitle: l10n.handymanStep3Subtitle,
          ),
          SizedBox(height: 24.h),
          AppDropdownField<String>(
            label: l10n.experienceYears,
            userType: AppUserType.handyman,
            hintText: l10n.experiencePlaceholder,
            value: selectedExperience,
            items: [
              l10n.experienceLess1,
              l10n.experience1to3,
              l10n.experience3to5,
              l10n.experience5to10,
              l10n.experience10plus,
            ],
            onChanged: (v) => setState(() => selectedExperience = v),
            validator: (v) => vExp(v, l10n),
          ),
          SizedBox(height: 16.h),
          AppCategorySelector(
            label: l10n.specializations,
            userType: AppUserType.handyman,
            subtitle: l10n.specializationsSubtitle,
            searchHint: l10n.searchSpecialization,
            noResultsText: l10n.noResults,
            categories: categories,
            selectedIds: selectedCategoryIds,
            onChanged: (ids) => setState(() => selectedCategoryIds = ids),
            validator: (ids) => vCats(ids, l10n),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            label: l10n.hourlyRate,
            hintText: l10n.hourlyRatePlaceholder,
            userType: AppUserType.handyman,
            controller: rateCtrl,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            validator: (v) => vRate(v, l10n),
          ),

          SizedBox(height: 24.h),
          AppStepNavigation(
            nextLabel: l10n.nextButton,
            previousLabel: l10n.previousButton,
            userType: AppUserType.handyman,
            onNext: () => nextStep(l10n),
            onPrevious: prevStep,
          ),
        ],
      ),
    );
  }

  Widget buildStep4(AppLocalizations l10n) => Form(
    key: step4Key,
    child: Column(
      children: [
        AppStepHeader(
          icon: Icons.folder_outlined,
          gradient: [AppColors.accent[60]!, AppColors.accent[70]!],
          title: l10n.handymanStep4Title,
          subtitle: l10n.handymanStep4Subtitle,
        ),
        SizedBox(height: 24.h),
        AppFileUploader(
          label: l10n.nationalId,
          hint: l10n.uploadNationalId,
          userType: AppUserType.handyman,
          icon: Icons.badge_outlined,
          isSelected: nationalIdSelected,
          selectedFileName: nationalIdPhotoName ?? l10n.nationalId,
          onTap: pickNationalIdPhoto,
          validator: (_) => nationalIdPhoto == null
              ? l10n.validationNationalIdRequired
              : null,
        ),
        SizedBox(height: 16.h),
        AppFileUploader(
          label: l10n.profilePhoto,
          hint: l10n.uploadProfilePhoto,
          userType: AppUserType.handyman,
          icon: Icons.photo_camera_outlined,
          isSelected: profilePhotoSelected,
          selectedFileName: profilePhotoName ?? l10n.profilePhoto,
          onTap: pickProfilePhoto,
        ),
        SizedBox(height: 20.h),

        AppTermsCheckbox(
          isChecked: agreeToTerms,
          onChanged: (v) => setState(() => agreeToTerms = v),
          termsText: l10n.agreeToTerms,
          linkText: l10n.termsLink,
          onLinkTap: () => AppTermsModal.show(context),
          userType: AppUserType.handyman,
        ),

        if (!agreeToTerms) ...[
          SizedBox(height: 8.h),
          AppInfoBox(
            message: l10n.validationTermsRequired,
            type: AppInfoBoxType.warning,
          ),
        ],

        SizedBox(height: 24.h),
        AppStepNavigation(
          nextLabel: l10n.submitRequestButton,
          userType: AppUserType.handyman,
          previousLabel: l10n.previousButton,
          onNext: () => nextStep(l10n),
          onPrevious: prevStep,
          isLoading: context.watch<AuthCubit>().state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          ),
        ),
      ],
    ),
  );

  Widget buildCurrentStep(AppLocalizations l10n) {
    Widget step;
    switch (currentStep) {
      case 1:
        step = buildStep1(l10n);
        break;
      case 2:
        step = buildStep2(l10n);
        break;
      case 3:
        step = buildStep3(l10n);
        break;
      default:
        step = buildStep4(l10n);
    }
    return FadeTransition(
      opacity: stepFade,
      child: SlideTransition(position: stepSlide, child: step),
    );
  }

  List<String> stepLabels(AppLocalizations l10n) => [
    l10n.handymanStep1,
    l10n.handymanStep2,
    l10n.handymanStep3,
    l10n.handymanStep4,
  ];

  Widget buildLoginLink(AppLocalizations l10n) => _LoginLink(
    l10n: l10n,
    onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
    role: AppUserType.handyman,
  );
}

// ══════════════════════════════════════════════════════════════
// RegisterHandymanMobileBody
// ══════════════════════════════════════════════════════════════
class RegisterHandymanMobileBody extends StatefulWidget {
  const RegisterHandymanMobileBody({super.key});

  @override
  State<RegisterHandymanMobileBody> createState() =>
      _RegisterHandymanMobileBodyState();
}

class _RegisterHandymanMobileBodyState
    extends _RegHandymanBase<RegisterHandymanMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (user) async{
            AppSnackBar.show(
              context,
              message: l10n.handymanSuccessMessage,
              type: AppSnackType.success,
            );

            // await getIt<SecureStorageService>().saveToken(user.token);
            //
            // await getIt<SecureStorageService>().saveRole(user.role);


            if (!context.mounted) return;


            Navigator.pushReplacementNamed(
              context,
              AppRoutes.handymanApprovalPending,
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
                  horizontal: AppSpacing.xl.w,
                  vertical: AppSpacing.xl.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    ea(
                      0,
                      AppLogoHeader(
                        title: l10n.registerHandymanTitle,
                        userType: AppUserType.handyman,
                        subtitle: l10n.registerAsProHandyman,
                        logoSize: 36,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ea(1, AppInfoBox(message: l10n.handymanApprovalNotice)),
                    SizedBox(height: 16.h),
                    ea(
                      2,
                      AppStepProgressBar(
                        userType: AppUserType.handyman,
                        currentStep: currentStep,
                        steps: stepLabels(l10n),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    ea(3, buildCurrentStep(l10n)),
                    SizedBox(height: 24.h),
                    ea(4, buildLoginLink(l10n)),
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
// RegisterHandymanTabletBody
// Left: brand + live step tracker | Right: form (centered, full-bg)
// ══════════════════════════════════════════════════════════════
class RegisterHandymanTabletBody extends StatefulWidget {
  const RegisterHandymanTabletBody({super.key});

  @override
  State<RegisterHandymanTabletBody> createState() =>
      _RegisterHandymanTabletBodyState();
}

class _RegisterHandymanTabletBodyState
    extends _RegHandymanBase<RegisterHandymanTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = stepLabels(l10n);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (user) async {
            AppSnackBar.show(
              context,
              message: l10n.handymanSuccessMessage,
              type: AppSnackType.success,
            );

            // await getIt<SecureStorageService>()
            // .saveToken(user.token);
            //
            // await getIt<SecureStorageService>()
            //     .saveRole(user.role);

            if (!context.mounted) return;

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.handymanApprovalPending,
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
              // ── Left: brand + step tracker (35%) ────────
              Expanded(
                flex: 35,
                child: // After
                AppTabletSidePanel(
                  currentStep: currentStep,
                  stepLabels: labels,
                  entryCtrl: entryCtrl,
                  title: 'إنشاء حساب فني',
                  subtitle: 'خطوة بخطوة\nحتى تنضم لمجتمعنا',
                  userType: AppUserType.handyman,
                ),
              ),

              // ── Right: form — full-height bg, centered (65%) ──
              Expanded(
                flex: 65,
                child: AppAuthBackground(
                  showPattern: false,
                  child: SizedBox.expand(
                    child: SafeArea(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 32.h,
                          ),
                          child: Column(
                            children: [
                              ea(
                                0,
                                AppInfoBox(
                                  message: l10n.handymanApprovalNotice,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ea(
                                1,
                                AppStepProgressBar(
                                  currentStep: currentStep,
                                  userType: AppUserType.handyman,
                                  steps: labels,
                                ),
                              ),
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
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppTabletSidePanel
// Side panel for tablet registration views with animated steps
//
// Usage:
//   AppTabletSidePanel(
//     currentStep: 2,
//     stepLabels: ['البيانات', 'العنوان', 'التأكيد'],
//     entryCtrl: _animationController,
//     title: 'إنشاء حساب فني',
//     subtitle: 'خطوة بخطوة\nحتى تنضم لمجتمعنا',
//     userType: AppUserType.handyman,
//   )
// ══════════════════════════════════════════════════════════════
class AppTabletSidePanel extends StatefulWidget {
  final int currentStep;
  final List<String> stepLabels;
  final AnimationController entryCtrl;
  final String title;
  final String subtitle;
  final String logoText;
  final AppUserType userType;

  const AppTabletSidePanel({
    super.key,
    required this.currentStep,
    required this.stepLabels,
    required this.entryCtrl,
    required this.title,
    required this.subtitle,
    this.logoText = 'FixIt',
    this.userType = AppUserType.customer,
  });

  @override
  State<AppTabletSidePanel> createState() => _AppTabletSidePanelState();
}

class _AppTabletSidePanelState extends State<AppTabletSidePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatY;

  // ── Dynamic Colors ─────────────────────────────────────────
  bool get isHandyman => widget.userType == AppUserType.handyman;

  Color get mainColor =>
      isHandyman ? AppColors.accent[60]! : AppColors.primary[60]!;

  Color get secondaryColor =>
      isHandyman ? AppColors.accent[40]! : AppColors.secondary[60]!;

  @override
  void initState() {
    super.initState();
    _initFloatAnimation();
  }

  void _initFloatAnimation() {
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatY = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, secondaryColor],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Floating Logo ─────────────────────────────
              _buildFloatingLogo(),
              SizedBox(height: 28.h),

              // ── Title & Subtitle ──────────────────────────
              _buildHeaderText(),
              SizedBox(height: 36.h),

              // ── Step List ────────────────────────────────
              _buildStepList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLogo() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: widget.entryCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, _floatY.value),
          child: Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.logoText,
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: widget.entryCtrl,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            widget.subtitle,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.82),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepList() {
    return Column(
      children: List.generate(widget.stepLabels.length, (i) {
        final stepNum = i + 1;
        final isDone = stepNum < widget.currentStep;
        final isActive = stepNum == widget.currentStep;

        return _StepRow(
          stepNum: stepNum,
          label: widget.stepLabels[i],
          isDone: isDone,
          isActive: isActive,
          entryCtrl: widget.entryCtrl,
          delay: 0.35 + i * 0.10,
          mainColor: mainColor,
        );
      }),
    );
  }
}

// ╀─ Step Row ───────────────────────────────────────────────────
class _StepRow extends StatelessWidget {
  final int stepNum;
  final String label;
  final bool isDone;
  final bool isActive;
  final AnimationController entryCtrl;
  final double delay;
  final Color mainColor;

  const _StepRow({
    required this.stepNum,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.entryCtrl,
    required this.delay,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final fade = _buildFadeAnimation();
    final slide = _buildSlideAnimation();

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: Row(
            children: [
              _buildStepCircle(),
              SizedBox(width: 10.w),
              _buildStepLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Animation<double> _buildFadeAnimation() {
    final end = (delay + 0.35).clamp(0.0, 1.0);
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(delay.clamp(0.0, 1.0), end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _buildSlideAnimation() {
    final end = (delay + 0.35).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(-0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(delay.clamp(0.0, 1.0), end, curve: Curves.easeOutCubic),
      ),
    );
  }

  Widget _buildStepCircle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.white
            : isDone
            ? Colors.white.withOpacity(0.30)
            : Colors.white.withOpacity(0.12),
        border: Border.all(
          color: Colors.white.withOpacity(
            isActive
                ? 1.0
                : isDone
                ? 0.45
                : 0.25,
          ),
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check_rounded, size: 15.sp, color: Colors.white)
            : Text(
                '$stepNum',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? mainColor : Colors.white.withOpacity(0.65),
                ),
              ),
      ),
    );
  }

  Widget _buildStepLabel() {
    return Expanded(
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13.sp,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: Colors.white.withOpacity(isActive ? 1.0 : 0.60),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TermsRow — shared
// ══════════════════════════════════════════════════════════════
class _TermsRow extends StatelessWidget {
  final bool agreeToTerms;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsTap;
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
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: agreeToTerms,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary[60],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(l10n.agreeToTerms, style: textTheme.bodyLarge),
        GestureDetector(
          onTap: onTermsTap,
          child: Text(
            l10n.termsLink,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.primary[60],
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary[60],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _LoginLink — shared (role-based color)
// ══════════════════════════════════════════════════════════════
class RoleTheme {
  static Color primary(AppUserType role) {
    switch (role) {
      case AppUserType.customer:
        return AppColors.primary[60]!;
      case AppUserType.handyman:
        return AppColors.accent[60]!;
    }
  }
}

class _LoginLink extends StatefulWidget {
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final AppUserType role;

  const _LoginLink({
    required this.l10n,
    required this.onTap,
    required this.role,
  });

  @override
  State<_LoginLink> createState() => _LoginLinkState();
}

class _LoginLinkState extends State<_LoginLink>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.94,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.l10n.alreadyHaveAccountLogin,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w400),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTapDown: (_) {
            _ctrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _ctrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _ctrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Text(
              widget.l10n.signInLink,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: RoleTheme.primary(widget.role),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
