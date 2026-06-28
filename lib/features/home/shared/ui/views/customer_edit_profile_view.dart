import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/l10n/translation/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/utils/widgets/app_main_background.dart';
import '../../../../../core/utils/widgets/app_avatar_picker.dart';
import '../../../../../core/utils/widgets/app_form_widgets.dart';
import '../../../../../core/utils/widgets/app_page_header.dart';
import '../../../../customer/data/models/requests/update_profile_request.dart';
import '../../../../customer/presentation/cubit/customer_cubit.dart';
import '../../../../customer/presentation/cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// SharedEditProfileView — layout router
// Shared between customer and handyman.
//
// Customer:  accentColor: AppColors.primary[60]!, isHandyman: false
// Handyman:  accentColor: AppColors.accent[60]!,  isHandyman: true
// ══════════════════════════════════════════════════════════════
class CustomerEditProfileView extends StatelessWidget {
  final Color accentColor;
  final bool isHandyman;

  const CustomerEditProfileView({
    super.key,
    this.accentColor = const Color(0xFFFF6B35),
    this.isHandyman = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? _EditProfileTabletBody(accentColor: accentColor, isHandyman: isHandyman)
          : _EditProfileMobileBody(accentColor: accentColor, isHandyman: isHandyman),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _EditProfileBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  Color get accentColor;
  bool get isHandyman;

  // ── Common fields ─────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController(text: '+20 123 456 7890');
  final emailCtrl = TextEditingController(text: 'text@example.com');
  final addressCtrl = TextEditingController();

  final nameFocus = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();

  // String? city = 'cairo';
  // String? area = 'nasr_city';
  XFile? avatarFile;
  bool isSaving = false;

  // ── Handyman-only fields ──────────────────────────────────
  final bioCtrl = TextEditingController(text: 'فني سباكة محترف مع خبرة ٨ سنوات.');
  final rateCtrl = TextEditingController(text: '150');
  final expCtrl = TextEditingController(text: '8');
  String? specialty = 'plumbing';

  // ── Entry animation ───────────────────────────────────────
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<CustomerCubit>().getProfile();
    });

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    entryFade = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.40).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ));
    });

    entrySlide = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(
          start.clamp(0.0, 1.0),
          (start + 0.45).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    rateCtrl.dispose();
    expCtrl.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Widget animatedSection(int i, Widget child) {
    final idx = i.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(
        position: entrySlide[idx],
        child: child,
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────
  Future<void> saveProfile(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    await context.read<CustomerCubit>().updateProfile(
      UpdateProfileRequest(
        fullName: nameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        avatar: avatarFile?.path ?? '',
      ),
    );
  }

  // ── Build header ──────────────────────────────────────────
  Widget buildHeader(bool isDark, AppLocalizations l10n) {
    return AppPageHeader(
      isDark: isDark,
      title: l10n.editProfileTitle,
      accentColor: accentColor,
    );
  }

  // ── Build avatar ──────────────────────────────────────────
  Widget buildAvatar(AppLocalizations l10n) {
    return AppAvatarPicker(
      imageFile: avatarFile,
      changeLabel: l10n.editProfileChangePhoto,
      onPicked: (f) => setState(() => avatarFile = f),
      accentColor: accentColor,
    );
  }

  // ── Card with section title ───────────────────────────────
  Widget buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accentColor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18.sp, color: accentColor),
            SizedBox(width: 8.w),
            Text(
              title,
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ]),
          SizedBox(height: 18.h),
          child,
        ],
      ),
    );
  }

  // ── Personal info fields ──────────────────────────────────
  Widget buildPersonalFields(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: l10n.editProfileName, required: true),
        AppFormTextField(
          controller: nameCtrl,
          hint: l10n.editProfileNameHint,
          isDark: isDark,
          accentColor: accentColor,
          focusNode: nameFocus,
          nextFocusNode: phoneFocus,
          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(label: l10n.editProfilePhone, required: true),
        AppFormTextField(
          controller: phoneCtrl,
          hint: l10n.editProfilePhoneHint,
          isDark: isDark,
          accentColor: accentColor,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          focusNode: phoneFocus,
          nextFocusNode: emailFocus,
          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(label: l10n.editProfileEmail, required: true),
        AppFormTextField(
          controller: emailCtrl,
          hint: l10n.editProfileEmailHint,
          isDark: isDark,
          accentColor: accentColor,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          focusNode: emailFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.bookingRequired;
            if (!v.contains('@')) return l10n.editProfileEmailInvalid;
            return null;
          },
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(
          label: 'العنوان',
          required: true,
        ),

        AppFormTextField(
          controller: addressCtrl,
          hint: 'ادخل العنوان',
          isDark: isDark,
          accentColor: accentColor,
          validator: (v) =>
          (v == null || v.trim().isEmpty)
              ? l10n.bookingRequired
              : null,
        ),
      ],
    );
  }

  // ── Handyman-only professional fields ─────────────────────
  Widget buildProfessionalFields(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: l10n.settingsSpecialty, required: true),
        AppFormDropdown<String>(
          value: specialty,
          hint: l10n.settingsSpecialty,
          isDark: isDark,
          accentColor: accentColor,
          items: [
            DropdownMenuItem(value: 'plumbing', child: _dropdownText(l10n.catPlumbing)),
            DropdownMenuItem(value: 'electric', child: _dropdownText(l10n.catElectric)),
            DropdownMenuItem(value: 'carpentry', child: _dropdownText(l10n.catCarpentry)),
            DropdownMenuItem(value: 'painting', child: _dropdownText(l10n.catPainting)),
            DropdownMenuItem(value: 'ac', child: _dropdownText(l10n.catAC)),
          ],
          onChanged: (v) => setState(() => specialty = v),
          validator: (v) => v == null ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(label: l10n.settingsBio, required: false),
        AppFormTextArea(
          controller: bioCtrl,
          hint: l10n.settingsBio,
          isDark: isDark,
        ),
        SizedBox(height: 16.h),

        Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFieldLabel(label: l10n.settingsHourlyRate, required: true),
                AppFormTextField(
                  controller: rateCtrl,
                  hint: '150',
                  isDark: isDark,
                  accentColor: accentColor,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFieldLabel(label: l10n.settingsExperience, required: true),
                AppFormTextField(
                  controller: expCtrl,
                  hint: '5',
                  isDark: isDark,
                  accentColor: accentColor,
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ── Save button ───────────────────────────────────────────
  Widget buildSaveButton(AppLocalizations l10n) {
    return _SaveButton(
      label: l10n.editProfileSaveBtn,
      accent: accentColor,
      isLoading: isSaving,
      onTap: () => saveProfile(l10n),
    );
  }

  Widget _dropdownText(String t) => Text(
    t,
    style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w500),
  );
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _EditProfileMobileBody extends StatefulWidget {
  final Color accentColor;
  final bool isHandyman;

  const _EditProfileMobileBody({
    required this.accentColor,
    required this.isHandyman,
  });

  @override
  State<_EditProfileMobileBody> createState() => _EditProfileMobileBodyState();
}

class _EditProfileMobileBodyState extends _EditProfileBase<_EditProfileMobileBody> {
  @override
  Color get accentColor => widget.accentColor;
  @override
  bool get isHandyman => widget.isHandyman;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          state.whenOrNull(
            profileLoaded: (profile) {
              nameCtrl.text = profile.fullName;
              phoneCtrl.text = profile.phone;
              emailCtrl.text = profile.email;
              addressCtrl.text = profile.address;
            },

            message: (message) {
              setState(() => isSaving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message,style: TextStyle(color: Colors.white),),
                  backgroundColor: AppColors.success,
                ),
              );

              Navigator.pop(context);
            },

            error: (message) {
              setState(() => isSaving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message,style: TextStyle(color: Colors.white),),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  animatedSection(0, buildHeader(isDark, l10n)),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        AppSpacing.xl.h,
                        AppSpacing.xl.w,
                        AppSpacing.xxl.h,
                      ),
                      children: [
                        // Avatar
                        Center(child: buildAvatar(l10n)),
                        SizedBox(height: 32.h),

                        // Personal info card
                        animatedSection(
                          1,
                          buildSectionCard(
                            isDark: isDark,
                            title: l10n.editProfilePersonalSection,
                            icon: Icons.person_outline_rounded,
                            child: buildPersonalFields(isDark, l10n),
                          ),
                        ),

                        // Handyman-only: Professional info
                        if (isHandyman) ...[
                          SizedBox(height: 20.h),
                          animatedSection(
                            2,
                            buildSectionCard(
                              isDark: isDark,
                              title: l10n.settingsProfessionalInfo,
                              icon: Icons.work_outline_rounded,
                              child: buildProfessionalFields(isDark, l10n),
                            ),
                          ),
                        ],

                        SizedBox(height: 28.h),

                        // Save button
                        animatedSection(3, buildSaveButton(l10n)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );

  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body
// ══════════════════════════════════════════════════════════════
class _EditProfileTabletBody extends StatefulWidget {
  final Color accentColor;
  final bool isHandyman;

  const _EditProfileTabletBody({
    required this.accentColor,
    required this.isHandyman,
  });

  @override
  State<_EditProfileTabletBody> createState() => _EditProfileTabletBodyState();
}

class _EditProfileTabletBodyState extends _EditProfileBase<_EditProfileTabletBody> {
  @override
  Color get accentColor => widget.accentColor;
  @override
  bool get isHandyman => widget.isHandyman;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<CustomerCubit, CustomerState>(
        listener: (context, state) {
          state.whenOrNull(
            profileLoaded: (profile) {
              nameCtrl.text = profile.fullName;
              phoneCtrl.text = profile.phone;
              emailCtrl.text = profile.email;
              addressCtrl.text = profile.address;
            },

            message: (message) {
              setState(() => isSaving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message,style: TextStyle(color: Colors.white),),
                  backgroundColor: AppColors.success,
                ),
              );

              Navigator.pop(context);
            },

            error: (message) {
              setState(() => isSaving = false);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message,style: TextStyle(color: Colors.white),),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
          );
        },

        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  animatedSection(0, buildHeader(isDark, l10n)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSpacing.xl.w),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column - Avatar + Tips
                              Expanded(
                                flex: 35,
                                child: Column(
                                  children: [
                                    // Avatar card
                                    animatedSection(
                                      1,
                                      Container(
                                        padding: EdgeInsets.all(20.w),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurface : Colors.white,
                                          borderRadius: BorderRadius.circular(20.r),
                                          border: Border.all(color: accentColor.withOpacity(0.08)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                                              blurRadius: 12,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            buildAvatar(l10n),
                                            SizedBox(height: 16.h),
                                            Text(
                                              l10n.editProfilePhotoHint,
                                              style: textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),

                                    // Tips card
                                    animatedSection(
                                      2,
                                      _TipsCard(
                                        accent: accentColor,
                                        isDark: isDark,
                                        textTheme: textTheme,
                                        l10n: l10n,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24.w),

                              // Right column - Form
                              Expanded(
                                flex: 65,
                                child: Column(
                                  children: [
                                    // Personal info card
                                    animatedSection(
                                      1,
                                      buildSectionCard(
                                        isDark: isDark,
                                        title: l10n.editProfilePersonalSection,
                                        icon: Icons.person_outline_rounded,
                                        child: buildPersonalFields(isDark, l10n),
                                      ),
                                    ),

                                    // Handyman-only: Professional info
                                    if (isHandyman) ...[
                                      SizedBox(height: 20.h),
                                      animatedSection(
                                        2,
                                        buildSectionCard(
                                          isDark: isDark,
                                          title: l10n.settingsProfessionalInfo,
                                          icon: Icons.work_outline_rounded,
                                          child: buildProfessionalFields(isDark, l10n),
                                        ),
                                      ),
                                    ],

                                    SizedBox(height: 28.h),

                                    // Save button
                                    animatedSection(3, buildSaveButton(l10n)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SaveButton
// ══════════════════════════════════════════════════════════════
class _SaveButton extends StatefulWidget {
  final String label;
  final Color accent;
  final bool isLoading;
  final VoidCallback onTap;

  const _SaveButton({
    required this.label,
    required this.accent,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.97)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _ctrl.forward(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 54.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.accent, widget.accent.withOpacity(0.82)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
              width: 24.w,
              height: 24.h,
              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_rounded, size: 20.sp, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TipsCard — tablet left panel tips
// ══════════════════════════════════════════════════════════════
class _TipsCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const _TipsCard({
    required this.accent,
    required this.isDark,
    required this.textTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: accent.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.15), accent.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.tips_and_updates_outlined, color: accent, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.editProfileTipsTitle,
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _TipItem(
            icon: Icons.photo_camera_outlined,
            text: l10n.editProfileTipPhoto,
            accent: accent,
            colorScheme: colorScheme,
          ),
          SizedBox(height: 12.h),
          _TipItem(
            icon: Icons.phone_outlined,
            text: l10n.editProfileTipPhone,
            accent: accent,
            colorScheme: colorScheme,
          ),
          SizedBox(height: 12.h),
          _TipItem(
            icon: Icons.location_on_outlined,
            text: l10n.editProfileTipLocation,
            accent: accent,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TipItem
// ══════════════════════════════════════════════════════════════
class _TipItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color accent;
  final ColorScheme colorScheme;

  const _TipItem({
    required this.icon,
    required this.text,
    required this.accent,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.sp, color: accent),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
