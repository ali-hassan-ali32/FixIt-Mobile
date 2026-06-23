import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_time_picker.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';

// ══════════════════════════════════════════════════════════════
// HandymanSettingsView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanSettingsView extends StatelessWidget {
  const HandymanSettingsView({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth >= 600
        ? const _HandymanSettingsTabletBody()
        : const _HandymanSettingsMobileBody(),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _SettingsBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;

  // ── Controllers ────────────────────────────────────────────
  final nameCtrl = TextEditingController(text: 'محمد علي');
  final phoneCtrl = TextEditingController(text: '+٢٠١٢٣٤٥٦٧٨٩٠');
  final emailCtrl = TextEditingController(text: 'mohamed.ali@example.com');
  final bioCtrl = TextEditingController(
    text: 'فني سباكة محترف مع خبرة ٨ سنوات في جميع أعمال السباكة.',
  );
  final rateCtrl = TextEditingController(text: '150');
  final expCtrl = TextEditingController(text: '8');
  final areasCtrl = TextEditingController(
    text: 'مدينة نصر، المعادي، الزمالك، مصر الجديدة',
  );
  final workFromCtrl = TextEditingController(text: '08:00');
  final workToCtrl = TextEditingController(text: '18:00');

  // ── Dropdowns ──────────────────────────────────────────────
  String specialty = 'plumbing';
  String governorate = 'cairo';

  // ── Toggles ────────────────────────────────────────────────
  bool notifRequests = true;
  bool notifMessages = true;
  bool notifRatings = true;
  bool available = true;

  // ── Entry animation ────────────────────────────────────────
  late final AnimationController masterCtrl;
  late final List<Animation<double>> sectionOpacity;
  late final List<Animation<Offset>> sectionSlide;

  static const int sectionCount = 8;

  @override
  void initState() {
    super.initState();
    masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    sectionOpacity = List.generate(sectionCount, (i) {
      final start = i * 0.10;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start,
            (start + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    sectionSlide = List.generate(sectionCount, (i) {
      final start = i * 0.10;
      return Tween<Offset>(
        begin: const Offset(0, 0.18),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start,
            (start + 0.40).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    masterCtrl.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    bioCtrl.dispose();
    rateCtrl.dispose();
    expCtrl.dispose();
    areasCtrl.dispose();
    workFromCtrl.dispose();
    workToCtrl.dispose();
    super.dispose();
  }

  Widget animated(int i, Widget child) => FadeTransition(
    opacity: sectionOpacity[i],
    child: SlideTransition(position: sectionSlide[i], child: child),
  );

  void save() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  // ── Header ────────────────────────────────────────────────
  Widget buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        top + AppSpacing.md.h,
        AppSpacing.lg.w,
        AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: teal.withOpacity(0.10))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(isDark: isDark, tapColor: teal),
          SizedBox(width: 14.w),
          Text(
            l10n.settingsTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ── Section builder ───────────────────────────────────────
  Widget buildSection({
    required bool isDark,
    required TextTheme textTheme,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.lg.h,
        AppSpacing.xl.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: teal.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Personal info section ─────────────────────────────────
  Widget buildPersonalInfo(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsPersonalInfo,
      child: Column(
        children: [
          _Field(
            ctrl: nameCtrl,
            label: l10n.settingsFullName,
            teal: teal,
            isDark: isDark,
          ),
          _Field(
            ctrl: phoneCtrl,
            label: l10n.settingsPhone,
            teal: teal,
            isDark: isDark,
            enabled: false,
          ),
          _Field(
            ctrl: emailCtrl,
            label: l10n.settingsEmail,
            teal: teal,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Professional info section ─────────────────────────────
  Widget buildProfessionalInfo(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsProfessionalInfo,
      child: Column(
        children: [
          _DropdownField(
            label: l10n.settingsSpecialty,
            value: specialty,
            teal: teal,
            isDark: isDark,
            items: {
              'plumbing': l10n.catPlumbing,
              'electric': l10n.catElectric,
              'carpentry': l10n.catCarpentry,
              'painting': l10n.catPainting,
              'ac': l10n.catAC,
            },
            onChanged: (v) => setState(() => specialty = v!),
          ),
          _Field(
            ctrl: bioCtrl,
            label: l10n.settingsBio,
            teal: teal,
            isDark: isDark,
            maxLines: 4,
          ),
          _Field(
            ctrl: rateCtrl,
            label: l10n.settingsHourlyRate,
            teal: teal,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          _Field(
            ctrl: expCtrl,
            label: l10n.settingsExperience,
            teal: teal,
            isDark: isDark,
            keyboardType: TextInputType.number,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Work area section ─────────────────────────────────────
  Widget buildWorkArea(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsWorkArea,
      child: Column(
        children: [
          _DropdownField(
            label: l10n.settingsGovernorate,
            value: governorate,
            teal: teal,
            isDark: isDark,
            items: {
              'cairo': l10n.govCairo,
              'giza': l10n.govGiza,
              'alex': l10n.govAlex,
              'dakahlia': l10n.govDakahlia,
            },
            onChanged: (v) => setState(() => governorate = v!),
          ),
          _Field(
            ctrl: areasCtrl,
            label: l10n.settingsAreas,
            teal: teal,
            isDark: isDark,
            maxLines: 3,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Work hours section ────────────────────────────────────
  Widget buildWorkHours(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsWorkHours,
      child: Column(
        children: [
          _TimeField(
            ctrl: workFromCtrl,
            label: l10n.settingsFrom,
            teal: teal,
            isDark: isDark,
          ),
          _TimeField(
            ctrl: workToCtrl,
            label: l10n.settingsTo,
            teal: teal,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Notifications section ─────────────────────────────────
  Widget buildNotifications(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsNotifications,
      child: Column(
        children: [
          _ToggleRow(
            title: l10n.settingsNotifRequests,
            subtitle: l10n.settingsNotifRequestsDesc,
            value: notifRequests,
            teal: teal,
            onChanged: (v) => setState(() => notifRequests = v),
          ),
          _ToggleRow(
            title: l10n.settingsNotifMessages,
            subtitle: l10n.settingsNotifMessagesDesc,
            value: notifMessages,
            teal: teal,
            onChanged: (v) => setState(() => notifMessages = v),
          ),
          _ToggleRow(
            title: l10n.settingsNotifRatings,
            subtitle: l10n.settingsNotifRatingsDesc,
            value: notifRatings,
            teal: teal,
            isLast: true,
            onChanged: (v) => setState(() => notifRatings = v),
          ),
        ],
      ),
    );
  }

  // ── Availability section ──────────────────────────────────
  Widget buildAvailability(bool isDark, AppLocalizations l10n) {
    return buildSection(
      isDark: isDark,
      textTheme: Theme.of(context).textTheme,
      title: l10n.settingsAvailability,
      child: _ToggleRow(
        title: l10n.settingsAvailableToggle,
        subtitle: l10n.settingsAvailableToggleDesc,
        value: available,
        teal: teal,
        isLast: true,
        onChanged: (v) => setState(() => available = v),
      ),
    );
  }

  // ── Save bar ──────────────────────────────────────────────
  Widget buildSaveBar(bool isDark, AppLocalizations l10n) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, bottom + 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _PressableBtn(
        label: l10n.settingsSaveBtn,
        teal: teal,
        onTap: save,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _HandymanSettingsMobileBody extends StatefulWidget {
  const _HandymanSettingsMobileBody();
  @override
  State<_HandymanSettingsMobileBody> createState() =>
      _HandymanSettingsMobileBodyState();
}

class _HandymanSettingsMobileBodyState
    extends _SettingsBase<_HandymanSettingsMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBgPrimary
          : const Color(0xFFF0F7F8),
      body: AppMainBackground(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: buildHeader(
                    context,
                    isDark,
                    l10n,
                    Theme.of(context).textTheme,
                  ),
                ),
                SliverToBoxAdapter(
                  child: animated(0, buildPersonalInfo(isDark, l10n)),
                ),
                SliverToBoxAdapter(
                  child: animated(1, buildProfessionalInfo(isDark, l10n)),
                ),
                SliverToBoxAdapter(
                  child: animated(2, buildWorkArea(isDark, l10n)),
                ),
                SliverToBoxAdapter(
                  child: animated(3, buildWorkHours(isDark, l10n)),
                ),
                SliverToBoxAdapter(
                  child: animated(4, buildNotifications(isDark, l10n)),
                ),
                SliverToBoxAdapter(
                  child: animated(5, buildAvailability(isDark, l10n)),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 120.h)),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: animated(6, buildSaveBar(isDark, l10n)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body — two-column layout
// ══════════════════════════════════════════════════════════════
class _HandymanSettingsTabletBody extends StatefulWidget {
  const _HandymanSettingsTabletBody();
  @override
  State<_HandymanSettingsTabletBody> createState() =>
      _HandymanSettingsTabletBodyState();
}

class _HandymanSettingsTabletBodyState
    extends _SettingsBase<_HandymanSettingsTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left panel (42%) ───────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl.w),
                            child: _buildTabletHeaderCard(isDark, l10n),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animated(0, buildPersonalInfo(isDark, l10n)),
                        ),
                        SliverToBoxAdapter(
                          child: animated(
                            1,
                            buildProfessionalInfo(isDark, l10n),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 140.h)),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, color: teal.withOpacity(0.10)),

                  // ── Right panel (58%) ──────────────────────
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(height: AppSpacing.xl.h),
                        ),
                        SliverToBoxAdapter(
                          child: animated(2, buildWorkArea(isDark, l10n)),
                        ),
                        SliverToBoxAdapter(
                          child: animated(3, buildWorkHours(isDark, l10n)),
                        ),
                        SliverToBoxAdapter(
                          child: animated(4, buildNotifications(isDark, l10n)),
                        ),
                        SliverToBoxAdapter(
                          child: animated(5, buildAvailability(isDark, l10n)),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 140.h)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fixed save button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: animated(7, buildSaveBar(isDark, l10n)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeaderCard(bool isDark, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [teal, AppColors.accent[70] ?? const Color(0xFF44A3A0)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: teal.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(isDark: false, tapColor: Colors.white),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.settingsPersonalInfo,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 28.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.teal,
    required this.isDark,
    this.enabled = true,
    this.isLast = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final TextEditingController ctrl;
  final String label;
  final Color teal;
  final bool isDark;
  final bool enabled;
  final bool isLast;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 7.h),
          TextField(
            controller: ctrl,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled
                  ? (isDark ? AppColors.darkBgPrimary : Colors.white)
                  : (isDark ? AppColors.darkBgSecondary : Colors.grey.shade100),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: teal.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: teal.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: teal, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.teal,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final String value;
  final Map<String, String> items;
  final Color teal;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 7.h),
          DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.darkBgPrimary : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: teal.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: teal.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: teal, width: 2),
              ),
            ),
            items: items.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(
                      e.value,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatefulWidget {
  const _TimeField({
    required this.ctrl,
    required this.label,
    required this.teal,
    required this.isDark,
    this.isLast = false,
  });

  final TextEditingController ctrl;
  final String label;
  final Color teal;
  final bool isDark;
  final bool isLast;

  @override
  State<_TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<_TimeField> {
  Future<void> _pick() async {
    final parts = widget.ctrl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showAppTimePicker(
      context,
      initialTime: initial,
      activeColor: widget.teal,
    );
    if (picked != null) {
      widget.ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 7.h),
          _PressableTimeField(
            ctrl: widget.ctrl,
            teal: widget.teal,
            isDark: widget.isDark,
            onTap: _pick,
          ),
        ],
      ),
    );
  }
}

class _PressableTimeField extends StatefulWidget {
  final TextEditingController ctrl;
  final Color teal;
  final bool isDark;
  final VoidCallback onTap;

  const _PressableTimeField({
    required this.ctrl,
    required this.teal,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PressableTimeField> createState() => _PressableTimeFieldState();
}

class _PressableTimeFieldState extends State<_PressableTimeField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkBgPrimary : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.teal.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded, size: 18.sp, color: widget.teal),
              SizedBox(width: 10.w),
              ValueListenableBuilder(
                valueListenable: widget.ctrl,
                builder: (_, __, ___) => Text(
                  widget.ctrl.text,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.teal,
    required this.onChanged,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final Color teal;
  final bool isLast;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: teal.withOpacity(0.08))),
            ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeThumbColor: teal,
            activeTrackColor: teal.withOpacity(0.35),
          ),
        ],
      ),
    );
  }
}

class _PressableBtn extends StatefulWidget {
  const _PressableBtn({
    required this.label,
    required this.teal,
    required this.onTap,
  });

  final String label;
  final Color teal;
  final VoidCallback onTap;

  @override
  State<_PressableBtn> createState() => _PressableBtnState();
}

class _PressableBtnState extends State<_PressableBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 15.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.teal,
                AppColors.accent[70] ?? const Color(0xFF44A3A0),
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
