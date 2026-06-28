import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_avatar_picker.dart';
import '../../../../core/utils/widgets/app_form_widgets.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../data/models/requests/update_handyman_profile_request.dart';
import '../cubit/handyman_cubit.dart';
import '../cubit/handyman_state.dart';

// ══════════════════════════════════════════════════════════════
// HandymanEditProfileView — handyman-only edit profile
// Uses HandymanCubit exclusively; no customer logic.
// ══════════════════════════════════════════════════════════════
class HandymanEditProfileView extends StatelessWidget {
  const HandymanEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? const _EditProfileTabletBody()
          : const _EditProfileMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class — handyman only
// ══════════════════════════════════════════════════════════════
abstract class _EditProfileBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {

  Color get accent => AppColors.accent[60]!;

  // ── Form key & controllers ────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameCtrl  = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final bioCtrl   = TextEditingController();
  final rateCtrl  = TextEditingController();

  final nameFocus  = FocusNode();
  final phoneFocus = FocusNode();
  final emailFocus = FocusNode();

  // ── Handyman-specific state ───────────────────────────────
  XFile?  avatarFile;
  bool    isSaving     = false;
  bool    isAvailable  = true;
  String? specialty;

  // ── Entry animation ───────────────────────────────────────
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>>  entrySlide;
  static const int _sectionCount = 5;

  @override
  void initState() {
    super.initState();

    // Load current profile to pre-fill fields
    Future.microtask(() {
      if (mounted) context.read<HandymanCubit>().getProfile();
    });

    // Entry stagger
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    entryFade = List.generate(_sectionCount, (i) {
      final s = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s.clamp(0.0, 1.0), (s + 0.40).clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ));
    });
    entrySlide = List.generate(_sectionCount, (i) {
      final s = i * 0.12;
      return Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s.clamp(0.0, 1.0), (s + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
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
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  Widget animatedSection(int i, Widget child) {
    final idx = i.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Save ──────────────────────────────────────────────────
  Future<void> saveProfile(AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    await context.read<HandymanCubit>().updateProfile(
      UpdateHandymanProfileRequest(
        fullName:    nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        phoneNumber: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        email:       emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
        bio:         bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
        basePrice:   double.tryParse(rateCtrl.text.trim()),
        isAvailable: isAvailable,
        avatar:      avatarFile?.path,
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget buildHeader(bool isDark, AppLocalizations l10n) {
    return AppPageHeader(
      isDark: isDark,
      title: l10n.editProfileTitle,
      accentColor: accent,
    );
  }

  // ── Avatar ────────────────────────────────────────────────
  Widget buildAvatar(AppLocalizations l10n) {
    return AppAvatarPicker(
      imageFile: avatarFile,
      changeLabel: l10n.editProfileChangePhoto,
      onPicked: (f) => setState(() => avatarFile = f),
      accentColor: accent,
    );
  }

  // ── Section card ──────────────────────────────────────────
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
        border: Border.all(color: accent.withOpacity(0.08)),
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
          Row(children: [
            Icon(icon, size: 18.sp, color: accent),
            SizedBox(width: 8.w),
            Text(title,
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          SizedBox(height: 18.h),
          child,
        ],
      ),
    );
  }

  // ── Personal fields ───────────────────────────────────────
  Widget buildPersonalFields(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFieldLabel(label: l10n.editProfileName, required: true),
        AppFormTextField(
          controller: nameCtrl,
          hint: l10n.editProfileNameHint,
          isDark: isDark,
          accentColor: accent,
          focusNode: nameFocus,
          nextFocusNode: phoneFocus,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(label: l10n.editProfilePhone, required: true),
        AppFormTextField(
          controller: phoneCtrl,
          hint: l10n.editProfilePhoneHint,
          isDark: isDark,
          accentColor: accent,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          focusNode: phoneFocus,
          nextFocusNode: emailFocus,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        AppFieldLabel(label: l10n.editProfileEmail, required: true),
        AppFormTextField(
          controller: emailCtrl,
          hint: l10n.editProfileEmailHint,
          isDark: isDark,
          accentColor: accent,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          focusNode: emailFocus,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return l10n.bookingRequired;
            if (!v.contains('@')) return l10n.editProfileEmailInvalid;
            return null;
          },
        ),
      ],
    );
  }

  // ── Professional fields (handyman-specific) ───────────────
  Widget buildProfessionalFields(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Specialty
        AppFieldLabel(label: l10n.settingsSpecialty, required: true),
        AppFormDropdown<String>(
          value: specialty,
          hint: l10n.settingsSpecialty,
          isDark: isDark,
          accentColor: accent,
          items: [
            DropdownMenuItem(value: 'plumbing',  child: _dropText(l10n.catPlumbing)),
            DropdownMenuItem(value: 'electric',  child: _dropText(l10n.catElectric)),
            DropdownMenuItem(value: 'carpentry', child: _dropText(l10n.catCarpentry)),
            DropdownMenuItem(value: 'painting',  child: _dropText(l10n.catPainting)),
            DropdownMenuItem(value: 'ac',        child: _dropText(l10n.catAC)),
          ],
          onChanged: (v) => setState(() => specialty = v),
          validator: (v) => v == null ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 16.h),

        // Bio
        AppFieldLabel(label: l10n.settingsBio, required: false),
        AppFormTextArea(
          controller: bioCtrl,
          hint: l10n.settingsBio,
          isDark: isDark,
        ),
        SizedBox(height: 16.h),

        // Base price
        AppFieldLabel(label: l10n.settingsHourlyRate, required: true),
        AppFormTextField(
          controller: rateCtrl,
          hint: '150',
          isDark: isDark,
          accentColor: accent,
          keyboardType: TextInputType.number,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
        ),
        SizedBox(height: 20.h),

        // isAvailable toggle
        _AvailabilityToggle(
          isAvailable: isAvailable,
          accent: accent,
          isDark: isDark,
          onChanged: (v) {
            HapticFeedback.selectionClick();
            setState(() => isAvailable = v);
          },
        ),
      ],
    );
  }

  // ── Save button ───────────────────────────────────────────
  Widget buildSaveButton(AppLocalizations l10n) {
    return _SaveButton(
      label: l10n.editProfileSaveBtn,
      accent: accent,
      isLoading: isSaving,
      onTap: () => saveProfile(l10n),
    );
  }

  Widget _dropText(String t) => Text(
        t,
        style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w500),
      );
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _EditProfileMobileBody extends StatefulWidget {
  const _EditProfileMobileBody();

  @override
  State<_EditProfileMobileBody> createState() => _EditProfileMobileBodyState();
}

class _EditProfileMobileBodyState
    extends _EditProfileBase<_EditProfileMobileBody> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return BlocListener<HandymanCubit, HandymanState>(
      listener: (context, state) {
        state.whenOrNull(
          profileLoaded: (profile) {
            nameCtrl.text  = profile.fullName;
            phoneCtrl.text = profile.phoneNumber;
            emailCtrl.text = profile.email;
            bioCtrl.text   = profile.bio ?? '';
            rateCtrl.text  = profile.basePrice.toStringAsFixed(0);
            setState(() {
              isAvailable = profile.isAvailable;
              specialty = profile.category
                  .toLowerCase()
                  .replaceAll(' ', '');
            });
          },
          message: (message) {
            setState(() => isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.success,
            ));
            Navigator.pop(context);
          },
          error: (message) {
            setState(() => isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.danger,
            ));
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

                      SizedBox(height: 20.h),

                      // Professional info card
                      animatedSection(
                        2,
                        buildSectionCard(
                          isDark: isDark,
                          title: l10n.settingsProfessionalInfo,
                          icon: Icons.work_outline_rounded,
                          child: buildProfessionalFields(isDark, l10n),
                        ),
                      ),

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
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body
// ══════════════════════════════════════════════════════════════
class _EditProfileTabletBody extends StatefulWidget {
  const _EditProfileTabletBody();

  @override
  State<_EditProfileTabletBody> createState() => _EditProfileTabletBodyState();
}

class _EditProfileTabletBodyState
    extends _EditProfileBase<_EditProfileTabletBody> {

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final l10n       = AppLocalizations.of(context)!;
    final textTheme  = Theme.of(context).textTheme;

    return BlocListener<HandymanCubit, HandymanState>(
      listener: (context, state) {
        state.whenOrNull(
          profileLoaded: (profile) {
            nameCtrl.text  = profile.fullName;
            phoneCtrl.text = profile.phoneNumber;
            emailCtrl.text = profile.email;
            bioCtrl.text   = profile.bio ?? '';
            rateCtrl.text  = profile.basePrice.toStringAsFixed(0);
            setState(() {
              isAvailable = profile.isAvailable;
              specialty   = profile.category;
            });
          },
          message: (message) {
            setState(() => isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.success,
            ));
            Navigator.pop(context);
          },
          error: (message) {
            setState(() => isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message,
                  style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.danger,
            ));
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
                            // ── Left: Avatar + Tips ───────────────────
                            Expanded(
                              flex: 35,
                              child: Column(
                                children: [
                                  animatedSection(
                                    1,
                                    Container(
                                      padding: EdgeInsets.all(20.w),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkSurface
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                            color: accent.withOpacity(0.08)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                                isDark ? 0.15 : 0.05),
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
                                            style:
                                                textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  animatedSection(
                                    2,
                                    _TipsCard(
                                      accent: accent,
                                      isDark: isDark,
                                      textTheme: textTheme,
                                      l10n: l10n,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 24.w),

                            // ── Right: Form ───────────────────────────
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

                                  SizedBox(height: 20.h),

                                  // Professional info card
                                  animatedSection(
                                    2,
                                    buildSectionCard(
                                      isDark: isDark,
                                      title: l10n.settingsProfessionalInfo,
                                      icon: Icons.work_outline_rounded,
                                      child:
                                          buildProfessionalFields(isDark, l10n),
                                    ),
                                  ),

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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AvailabilityToggle — isAvailable field UI
// ══════════════════════════════════════════════════════════════
class _AvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final Color accent;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _AvailabilityToggle({
    required this.isAvailable,
    required this.accent,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isAvailable
            ? accent.withOpacity(0.08)
            : (isDark
                ? AppColors.darkSurface.withOpacity(0.5)
                : Colors.grey.withOpacity(0.07)),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isAvailable
              ? accent.withOpacity(0.30)
              : Colors.grey.withOpacity(0.20),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Pulsing dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable ? accent : Colors.grey,
              boxShadow: isAvailable
                  ? [
                      BoxShadow(
                          color: accent.withOpacity(0.45),
                          blurRadius: 8,
                          spreadRadius: 2)
                    ]
                  : [],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'متاح للعمل' : 'غير متاح',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isAvailable
                        ? accent
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ),
                Text(
                  isAvailable
                      ? 'سيظهر اسمك للعملاء الجدد'
                      : 'لن تتلقى طلبات جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isAvailable,
            activeColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
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
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
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
                child:
                    Icon(Icons.tips_and_updates_outlined, color: accent, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Text(l10n.editProfileTipsTitle,
                  style:
                      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
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
