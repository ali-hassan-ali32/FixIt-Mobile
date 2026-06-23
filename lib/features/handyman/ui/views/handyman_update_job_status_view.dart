import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/app_info.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/cards/app_section_card.dart';

// ══════════════════════════════════════════════════════════════
// Job status options
// ══════════════════════════════════════════════════════════════
enum _JobStatus { inProgress, completed }

// ══════════════════════════════════════════════════════════════
// HandymanUpdateJobStatusView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanUpdateJobStatusView extends StatelessWidget {
  final String requestId;
  final String serviceType;
  final String customerName;
  final String date;
  final String location;
  final String price;

  const HandymanUpdateJobStatusView({
    super.key,
    this.requestId = 'REQ-00123',
    this.serviceType = 'سباكة - صيانة عامة',
    this.customerName = 'أحمد محمود',
    this.date = '2026/02/16',
    this.location = 'مدينة نصر',
    this.price = '150 ج/ساعة',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? _UpdateJobTabletBody(
              requestId: requestId,
              serviceType: serviceType,
              customerName: customerName,
              date: date,
              location: location,
              price: price,
            )
          : _UpdateJobMobileBody(
              requestId: requestId,
              serviceType: serviceType,
              customerName: customerName,
              date: date,
              location: location,
              price: price,
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _UpdateJobBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get requestId;
  String get serviceType;
  String get customerName;
  String get date;
  String get location;
  String get price;

  Color get accent => AppColors.accent[60]!;

  _JobStatus status = _JobStatus.inProgress;
  final notesCtrl = TextEditingController();
  final List<XFile> photos = [];
  bool submitting = false;

  final picker = ImagePicker();

  // Entry animations
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;

  // Payment reminder animation
  late final AnimationController reminderCtrl;
  late final Animation<double> reminderFade;
  late final Animation<Offset> reminderSlide;

  static const int _sectionCount = 6;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    entryFade = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.40).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    entrySlide = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      return Tween<Offset>(
        begin: const Offset(0, 0.14),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.45).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    entryCtrl.forward();

    reminderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    reminderFade = CurvedAnimation(parent: reminderCtrl, curve: Curves.easeOut);
    reminderSlide =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: reminderCtrl, curve: Curves.easeOutCubic),
        );
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    reminderCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Widget animatedSection(int i, Widget child) {
    final idx = i.clamp(0, _sectionCount - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Status selection ─────────────────────────────────────
  void selectStatus(_JobStatus newStatus) {
    if (status == newStatus) return;
    HapticFeedback.selectionClick();
    setState(() => status = newStatus);
    if (newStatus == _JobStatus.completed) {
      reminderCtrl.forward();
    } else {
      reminderCtrl.reverse();
    }
  }

  // ── Photo picking ─────────────────────────────────────────
  Future<void> pickPhoto() async {
    if (photos.length >= 5) return;
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      HapticFeedback.lightImpact();
      setState(() => photos.add(file));
    }
  }

  void removePhoto(int index) {
    HapticFeedback.selectionClick();
    setState(() => photos.removeAt(index));
  }

  // ── Submit ────────────────────────────────────────────────
  void submit(bool isDark, AppLocalizations l10n) {
    showAnimatedConfirmDialog(
      context: context,
      isDark: isDark,
      icon: status == _JobStatus.completed
          ? Icons.check_circle_outline_rounded
          : Icons.update_rounded,
      title: l10n.updateJobConfirmTitle,
      message: l10n.updateJobConfirmMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.updateJobConfirmBtn,
      isDanger: false,
      confirmColor: accent,
      onConfirm: doSubmit,
    );
  }

  Future<void> doSubmit() async {
    setState(() => submitting = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => submitting = false);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  // ── Build job summary ─────────────────────────────────────
  Widget buildJobSummary(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request ID
          Text(
            '#$requestId',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          // Service title
          Text(
            serviceType,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 14.h),
          // Detail chips grid
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: [
              _DetailChip(
                icon: Icons.calendar_today_rounded,
                label: date,
                accent: accent,
              ),
              _DetailChip(
                icon: Icons.person_outline_rounded,
                label: customerName,
                accent: accent,
              ),
              _DetailChip(
                icon: Icons.location_on_outlined,
                label: location,
                accent: accent,
              ),
              _DetailChip(
                icon: Icons.payments_outlined,
                label: price,
                accent: accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Build status section ──────────────────────────────────
  Widget buildStatusSection(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.updateJobSelectStatus,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatusOption(
                icon: Icons.access_time_rounded,
                label: l10n.updateJobStatusInProgress,
                isSelected: status == _JobStatus.inProgress,
                accent: accent,
                isDark: isDark,
                onTap: () => selectStatus(_JobStatus.inProgress),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatusOption(
                icon: Icons.check_circle_outline_rounded,
                label: l10n.updateJobStatusCompleted,
                isSelected: status == _JobStatus.completed,
                accent: accent,
                isDark: isDark,
                onTap: () => selectStatus(_JobStatus.completed),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Build payment reminder ────────────────────────────────
  Widget buildPaymentReminder(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    return FadeTransition(
      opacity: reminderFade,
      child: SlideTransition(
        position: reminderSlide,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: status == _JobStatus.completed
              ? Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: AppInfoBox(
                    message:
                        '${l10n.updateJobPaymentNote}\n${l10n.updateJobPaymentAmount}: $price',
                    type: AppInfoBoxType.success,
                    icon: Icons.payments_outlined,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ── Build notes section ───────────────────────────────────
  Widget buildNotesSection(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.updateJobNotesLabel,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: notesCtrl,
            maxLines: 4,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: l10n.updateJobNotesHint,
              hintStyle: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkBgPrimary
                  : const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: accent.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: accent.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: accent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build photos section ──────────────────────────────────
  Widget buildPhotosSection(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final canAdd = photos.length < 5;

    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 18.sp,
                color: accent,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.updateJobPhotosTitle,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            l10n.updateJobPhotosNote,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 14.h),

          // Upload button
          if (canAdd)
            _UploadBtn(
              label: l10n.updateJobPhotosBtn,
              accent: accent,
              onTap: pickPhoto,
            ),

          // Photos grid
          if (photos.isNotEmpty) ...[
            SizedBox(height: 12.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: photos.length,
              itemBuilder: (ctx, i) =>
                  _PhotoThumb(file: photos[i], onRemove: () => removePhoto(i)),
            ),
          ],
        ],
      ),
    );
  }

  // ── Build submit button ───────────────────────────────────
  Widget buildSubmitButton(bool isDark, AppLocalizations l10n) {
    return _SubmitBtn(
      label: l10n.updateJobSubmitBtn,
      accent: accent,
      isLoading: submitting,
      onTap: () => submit(isDark, l10n),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _UpdateJobMobileBody extends StatefulWidget {
  final String requestId;
  final String serviceType;
  final String customerName;
  final String date;
  final String location;
  final String price;

  const _UpdateJobMobileBody({
    required this.requestId,
    required this.serviceType,
    required this.customerName,
    required this.date,
    required this.location,
    required this.price,
  });

  @override
  State<_UpdateJobMobileBody> createState() => _UpdateJobMobileBodyState();
}

class _UpdateJobMobileBodyState extends _UpdateJobBase<_UpdateJobMobileBody> {
  @override
  String get requestId => widget.requestId;
  @override
  String get serviceType => widget.serviceType;
  @override
  String get customerName => widget.customerName;
  @override
  String get date => widget.date;
  @override
  String get location => widget.location;
  @override
  String get price => widget.price;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header
            animatedSection(
              0,
              AppPageHeader(
                isDark: isDark,
                title: l10n.updateJobTitle,
                accentColor: Colors.greenAccent,
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl.w,
                  AppSpacing.lg.h,
                  AppSpacing.xl.w,
                  130.h,
                ),
                children: [
                  animatedSection(1, buildJobSummary(isDark, l10n, textTheme)),
                  SizedBox(height: 16.h),

                  animatedSection(
                    2,
                    buildStatusSection(isDark, l10n, textTheme),
                  ),
                  SizedBox(height: 4.h),

                  buildPaymentReminder(isDark, l10n, textTheme),
                  SizedBox(height: 16.h),

                  animatedSection(
                    3,
                    buildNotesSection(isDark, l10n, textTheme),
                  ),
                  SizedBox(height: 16.h),

                  animatedSection(
                    4,
                    buildPhotosSection(isDark, l10n, textTheme),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom submit bar
      bottomSheet: _AnimatedBottomBar(
        child: animatedSection(5, buildSubmitButton(isDark, l10n)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body
// ══════════════════════════════════════════════════════════════
class _UpdateJobTabletBody extends StatefulWidget {
  final String requestId;
  final String serviceType;
  final String customerName;
  final String date;
  final String location;
  final String price;

  const _UpdateJobTabletBody({
    required this.requestId,
    required this.serviceType,
    required this.customerName,
    required this.date,
    required this.location,
    required this.price,
  });

  @override
  State<_UpdateJobTabletBody> createState() => _UpdateJobTabletBodyState();
}

class _UpdateJobTabletBodyState extends _UpdateJobBase<_UpdateJobTabletBody> {
  @override
  String get requestId => widget.requestId;
  @override
  String get serviceType => widget.serviceType;
  @override
  String get customerName => widget.customerName;
  @override
  String get date => widget.date;
  @override
  String get location => widget.location;
  @override
  String get price => widget.price;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            // Header
            animatedSection(
              0,
              AppPageHeader(
                isDark: isDark,
                title: l10n.updateJobTitle,
                accentColor: Colors.greenAccent,
              ),
            ),

            // Two-column layout
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl.w,
                  vertical: AppSpacing.lg.h,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column - Form
                        Expanded(
                          flex: 58,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              animatedSection(
                                1,
                                buildJobSummary(isDark, l10n, textTheme),
                              ),
                              SizedBox(height: 16.h),

                              animatedSection(
                                2,
                                buildStatusSection(isDark, l10n, textTheme),
                              ),
                              SizedBox(height: 4.h),

                              buildPaymentReminder(isDark, l10n, textTheme),
                              SizedBox(height: 16.h),

                              animatedSection(
                                3,
                                buildNotesSection(isDark, l10n, textTheme),
                              ),
                              SizedBox(height: 16.h),

                              animatedSection(
                                4,
                                buildPhotosSection(isDark, l10n, textTheme),
                              ),
                              SizedBox(height: 24.h),

                              // Submit button inline for tablet
                              animatedSection(
                                5,
                                buildSubmitButton(isDark, l10n),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 24.w),

                        // Right column - Info panel
                        Expanded(
                          flex: 42,
                          child: animatedSection(
                            2,
                            _TabletInfoPanel(
                              isDark: isDark,
                              l10n: l10n,
                              accent: accent,
                              price: price,
                            ),
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
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _DetailChip — small icon + label chip in job summary
// ══════════════════════════════════════════════════════════════
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _DetailChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: accent),
        SizedBox(width: 5.w),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _StatusOption — selectable status card
// ══════════════════════════════════════════════════════════════
class _StatusOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_StatusOption> createState() => _StatusOptionState();
}

class _StatusOptionState extends State<_StatusOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.accent.withOpacity(0.10)
                : (widget.isDark
                      ? AppColors.darkBgPrimary
                      : const Color(0xFFF8F9FA)),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accent
                  : widget.accent.withOpacity(0.18),
              width: widget.isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? widget.accent.withOpacity(0.15)
                      : widget.accent.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 22.sp,
                  color: widget.isSelected
                      ? widget.accent
                      : widget.accent.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.label,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: widget.isSelected
                      ? widget.accent
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _UploadBtn — dashed border upload button
// ══════════════════════════════════════════════════════════════
class _UploadBtn extends StatefulWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _UploadBtn({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_UploadBtn> createState() => _UploadBtnState();
}

class _UploadBtnState extends State<_UploadBtn>
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: widget.accent.withOpacity(0.30),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 20.sp,
                color: widget.accent,
              ),
              SizedBox(width: 8.w),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _PhotoThumb — picked image with delete button
// ══════════════════════════════════════════════════════════════
class _PhotoThumb extends StatefulWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _PhotoThumb({required this.file, required this.onRemove});

  @override
  State<_PhotoThumb> createState() => _PhotoThumbState();
}

class _PhotoThumbState extends State<_PhotoThumb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: 0.0,
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.7,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(widget.file.path), fit: BoxFit.cover),
                Positioned(
                  top: 5.h,
                  left: 5.w,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14.sp,
                        color: Colors.white,
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
// _SubmitBtn
// ══════════════════════════════════════════════════════════════
class _SubmitBtn extends StatefulWidget {
  final String label;
  final Color accent;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitBtn({
    required this.label,
    required this.accent,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn>
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
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.30),
                blurRadius: 12,
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
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
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

// ══════════════════════════════════════════════════════════════
// _TabletInfoPanel — right panel for tablet
// ══════════════════════════════════════════════════════════════
class _TabletInfoPanel extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accent;
  final String price;

  const _TabletInfoPanel({
    required this.isDark,
    required this.l10n,
    required this.accent,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: accent,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.updateJobInfoTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.updateJobInfoSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Tips list
          _TipItem(
            icon: Icons.check_circle_outline_rounded,
            text: l10n.updateJobTip1,
            accent: accent,
          ),
          SizedBox(height: 12.h),
          _TipItem(
            icon: Icons.photo_camera_outlined,
            text: l10n.updateJobTip2,
            accent: accent,
          ),
          SizedBox(height: 12.h),
          _TipItem(
            icon: Icons.note_alt_outlined,
            text: l10n.updateJobTip3,
            accent: accent,
          ),
          SizedBox(height: 24.h),

          // Payment summary
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accent.withOpacity(0.08), accent.withOpacity(0.03)],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: accent.withOpacity(0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 18.sp, color: accent),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.updateJobPaymentAmount,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  price,
                  style: GoogleFonts.cairo(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.updateJobPaymentNote,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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

  const _TipItem({
    required this.icon,
    required this.text,
    required this.accent,
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
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AnimatedBottomBar — animated bottom sheet container
// ══════════════════════════════════════════════════════════════
class _AnimatedBottomBar extends StatefulWidget {
  final Widget child;
  const _AnimatedBottomBar({required this.child});

  @override
  State<_AnimatedBottomBar> createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<_AnimatedBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, bottom + 14.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
