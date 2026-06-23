import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_date_picker.dart';
import '../../../../core/utils/widgets/app_form_widgets.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_time_picker.dart';
import '../../../../core/utils/widgets/buttons/app_gradient_button.dart';
import '../../../../core/utils/widgets/cards/app_section_card.dart';
import '../../../lookups/presentation/cubit/lookup_cubit.dart';
import '../../../lookups/presentation/cubit/lookup_state.dart';
import '../../data/models/requests/create_service_request.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// CustomerBookServiceView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerBookServiceView extends StatelessWidget {
  final String? preselectedHandymanId;
  const CustomerBookServiceView({super.key, this.preselectedHandymanId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _BookTabletBody(preselectedHandymanId: preselectedHandymanId)
          : _BookMobileBody(preselectedHandymanId: preselectedHandymanId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — all form state + logic
// ══════════════════════════════════════════════════════════════
abstract class _BookBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String? get preselectedHandymanId;
  Color get accent => AppColors.primary[60]!;

  final formKey = GlobalKey<FormState>();
  String? serviceType;
  String? handymanId;
  final descCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  DateTime? selDate;
  TimeOfDay? selTime;
  String? city;
  String? area;
  final addressCtrl = TextEditingController();
  final List<XFile?> images = [null, null, null];
  bool isUrgent = false;
  bool isSubmitting = false;

  final picker = ImagePicker();

  // Shake on error
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  // Entry stagger
  late final AnimationController entryCtrl;
  late final List<Animation<double>> entryFade;
  late final List<Animation<Offset>> entrySlide;
  static const _n = 7;

  @override
  void initState() {
    super.initState();
    handymanId = preselectedHandymanId;
    Future.microtask(() async {
      final cubit = context.read<LookupCubit>();

      await cubit.loadCities();

      await cubit.loadCategories();
    });
    // Shake controller for error feedback
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    entryFade = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.42).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    entrySlide = List.generate(_n, (i) {
      final s = (i * 0.11).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
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
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    _shakeCtrl.dispose();
    descCtrl.dispose();
    titleCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Widget ea(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: entryFade[idx],
      child: SlideTransition(position: entrySlide[idx], child: child),
    );
  }

  // ── Completion progress (0.0 – 1.0) ──────────────────────
  double get progress {
    int done = 0;
    if (serviceType != null) done++;
    if (descCtrl.text.trim().isNotEmpty) done++;
    if (selDate != null) done++;
    if (selTime != null) done++;
    if (city != null) done++;
    if (area != null) done++;
    return done / 6;
  }

  // ── Pickers ───────────────────────────────────────────────
  Future<void> pickDate() async {
    final now = DateTime.now();
    final date = await showAppDatePicker(
      context,
      initialDate: selDate ?? now.add(const Duration(days: 1)),
      activeColor: accent,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date != null) setState(() => selDate = date);
  }

  Future<void> pickTime() async {
    final time = await showAppTimePicker(
      context,
      initialTime: selTime ?? const TimeOfDay(hour: 10, minute: 0),
      activeColor: accent,
    );
    if (time != null) setState(() => selTime = time);
  }

  Future<void> pickImage(int i) async {
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) setState(() => images[i] = file);
  }

  void removeImage(int i) => setState(() => images[i] = null);

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (progress < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.bookingFillRequired,
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      selDate!.year,
      selDate!.month,
      selDate!.day,
      selTime!.hour,
      selTime!.minute,
    );

    context.read<CustomerCubit>().createRequest(
      CreateServiceRequest(
        handymanId: handymanId,
        categoryId: serviceType!,
        cityId: city!,
        regionId: area!,
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        addressLine: addressCtrl.text.trim(),
        scheduledAtUtc: scheduledDateTime.toUtc(),
        estimatedDurationInMinutes:
        isUrgent ? 30 : 60,
        images: images
            .where((e) => e != null)
            .map((e) => e!.path)
            .toList(),
      ),
    );
  }
  void _showSuccess() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessDialog(
        requestNumber: '#REQ-00124',
        l10n: l10n,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.customerTrackRequestPending,
            (r) => r.settings.name == AppRoutes.customerHome,
            arguments: 'REQ-00121',
          );
        },
      ),
    );
  }

  // ── Shared card builders ──────────────────────────────────

  Widget buildProgressBar(BuildContext context) {
    final pct = progress;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl.w,
        vertical: 10.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBgSecondary
            : Colors.white,
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6.h,
                backgroundColor: accent.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '${(pct * 100).toInt()}%',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServiceCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {

    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.miscellaneous_services_rounded,
            label: l10n.bookingServiceDetailsTitle,
          ),
          SizedBox(height: 16.h),
          AppFieldLabel(label: l10n.bookingServiceType, required: true),

          BlocBuilder<LookupCubit, LookupState>(
            builder: (context, state) {

              if (state is! LookupLoaded) {
                return const CircularProgressIndicator();
              }

              return AppFormDropdown(
                value: serviceType,
                hint: l10n.bookingServiceTypeHint,
                isDark: isDark,
                items: state.categories
                    .map(
                      (category) => DropdownMenuItem(
                    value: category.id,
                    child: _dt(category.name),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  setState(
                        () => serviceType = v,
                  );
                },
                validator: (v) =>
                v == null
                    ? l10n.bookingRequired
                    : null,
              );
            },
          ),

          SizedBox(height: 16.h),
          if (preselectedHandymanId != null) ...[
            SizedBox(height: 16.h),

            AppFieldLabel(
              label: l10n.bookingHandymanLabel,
              required: false,
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary[60]!.withOpacity(.15),
                ),
              ),
              child: Text(
                'bookingSelectedHandyman',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          AppFieldLabel(label: l10n.bookingDescLabel, required: true),
          AppFormTextArea(
            controller: descCtrl,
            hint: l10n.bookingDescHint,
            isDark: isDark,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.bookingRequired : null,
          ),
        ],
      ),
    );
  }

  Widget buildDateTimeCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.calendar_today_rounded,
            label: l10n.bookingDateTimeTitle,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFieldLabel(label: l10n.bookingDateLabel, required: true),
                    AppPickerField(
                      value: selDate == null
                          ? null
                          : '${selDate!.day}/${selDate!.month}/${selDate!.year}',
                      hint: l10n.bookingDateHint,
                      icon: Icons.calendar_today_rounded,
                      isDark: isDark,
                      onTap: pickDate,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFieldLabel(label: l10n.bookingTimeLabel, required: true),
                    AppPickerField(
                      value: selTime?.format(context),
                      hint: l10n.bookingTimeHint,
                      icon: Icons.access_time_rounded,
                      isDark: isDark,
                      onTap: pickTime,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLocationCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.location_on_rounded,
            label: l10n.bookingLocationTitle,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFieldLabel(label: l10n.bookingCityLabel, required: true),
                    BlocBuilder<LookupCubit, LookupState>(
                      builder: (context, state) {

                        if (state is! LookupLoaded) {
                          return const CircularProgressIndicator();
                        }

                        return AppFormDropdown(
                          value: city,
                          hint: l10n.bookingCityHint,
                          isDark: isDark,
                          items: state.cities
                              .map(
                                (cityItem) => DropdownMenuItem(
                              value: cityItem.id,
                              child: _dt(cityItem.name),
                            ),
                          )
                              .toList(),
                          onChanged: (v) async {

                            setState(() {
                              city = v;
                              area = null;
                            });

                            if (v != null) {
                              await context
                                  .read<LookupCubit>()
                                  .loadRegions(v);
                            }
                          },
                          validator: (v) =>
                          v == null
                              ? l10n.bookingRequired
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppFieldLabel(label: l10n.bookingAreaLabel, required: true),
                    BlocBuilder<LookupCubit, LookupState>(
                      builder: (context, state) {

                        if (state is! LookupLoaded) {
                          return const CircularProgressIndicator();
                        }

                        return AppFormDropdown(
                          value: area,
                          hint: l10n.bookingAreaHint,
                          isDark: isDark,
                          items: state.regions
                              .map(
                                (region) => DropdownMenuItem(
                              value: region.id,
                              child: _dt(region.name),
                            ),
                          )
                              .toList(),
                          onChanged: (v) {
                            setState(
                                  () => area = v,
                            );
                          },
                          validator: (v) =>
                          v == null
                              ? l10n.bookingRequired
                              : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          AppFieldLabel(label: l10n.bookingAddressLabel, required: false),
          AppFormTextField(
            controller: addressCtrl,
            hint: l10n.bookingAddressHint,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget buildImagesCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.add_photo_alternate_outlined,
            label: l10n.bookingImagesTitle,
          ),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i < 2 ? 6.w : 0,
                    right: i > 0 ? 6.w : 0,
                  ),
                  child: _ImageSlot(
                    file: images[i],
                    isDark: isDark,
                    onAdd: () => pickImage(i),
                    onRemove: () => removeImage(i),
                    addLabel: l10n.bookingAddImage,
                    uploadedLabel: l10n.bookingImageUploaded,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUrgentCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppSectionCard(
      isDark: isDark,
      padding: EdgeInsets.zero,
      child: _UrgentToggle(
        isUrgent: isUrgent,
        isDark: isDark,
        textTheme: textTheme,
        colorScheme: colorScheme,
        urgentLabel: l10n.bookingUrgentLabel,
        urgentDesc: l10n.bookingUrgentDesc,
        accent: accent,
        onChanged: (v) {
          setState(() => isUrgent = v);
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Widget buildPaymentNote(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.accent[60]!.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.accent[60]!.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent[60]!.withOpacity(0.20),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.payments_outlined,
              size: 20.sp,
              color: AppColors.accent[60],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.bookingPaymentTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context)!.bookingPaymentDesc,
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

  Widget buildSubmitBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.md.h,
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.bottom + AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(_shakeAnim.value * (isSubmitting ? 0 : 0), 0),
          child: child,
        ),
        child: AppGradientButton(
          label: l10n.bookingSubmitBtn,
          isLoading: isSubmitting,
          onTap: submit,
          gradient: LinearGradient(colors: [accent, AppColors.secondary[60]!]),
          shadowColor: accent.withOpacity(0.32),
          height: 54,
          leadingIcon: Icon(
            Icons.send_rounded,
            size: 20.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _dt(String t) => Text(
    t,
    style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w500),
  );
}

// ══════════════════════════════════════════════════════════════
// Mobile — progress strip + staggered cards + floating bar
// ══════════════════════════════════════════════════════════════
class _BookMobileBody extends StatefulWidget {
  final String? preselectedHandymanId;
  const _BookMobileBody({this.preselectedHandymanId});

  @override
  State<_BookMobileBody> createState() => _BookMobileBodyState();
}

class _BookMobileBodyState extends _BookBase<_BookMobileBody> {
  @override
  String? get preselectedHandymanId => widget.preselectedHandymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {

        if (state is CustomerLoading) {
          setState(() => isSubmitting = true);
        }

        if (state is CustomerMessage) {
          setState(() => isSubmitting = false);
          _showSuccess();
        }

        if (state is CustomerError) {
          setState(() => isSubmitting = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: Column(
            children: [
              // Page header
              AppPageHeader(
                isDark: isDark,
                accentColor: accent,
                title: l10n.bookingTitle,
              ),

              // Live completion progress bar
              buildProgressBar(context),

              // Form
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      AppSpacing.lg.h,
                      AppSpacing.xl.w,
                      160.h,
                    ),
                    children: [
                      ea(0, buildServiceCard(context, isDark, l10n)),
                      SizedBox(height: 16.h),
                      ea(1, buildDateTimeCard(context, isDark, l10n)),
                      SizedBox(height: 16.h),
                      ea(2, buildLocationCard(context, isDark, l10n)),
                      SizedBox(height: 16.h),
                      ea(3, buildImagesCard(context, isDark, l10n)),
                      SizedBox(height: 16.h),
                      ea(4, buildUrgentCard(context, isDark, l10n)),
                      SizedBox(height: 16.h),
                      ea(5, buildPaymentNote(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: buildSubmitBar(context, isDark, l10n),
      )
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet — left summary panel (35%) | right form (65%)
// ══════════════════════════════════════════════════════════════
class _BookTabletBody extends StatefulWidget {
  final String? preselectedHandymanId;
  const _BookTabletBody({this.preselectedHandymanId});

  @override
  State<_BookTabletBody> createState() => _BookTabletBodyState();
}

class _BookTabletBodyState extends _BookBase<_BookTabletBody> {
  @override
  String? get preselectedHandymanId => widget.preselectedHandymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<CustomerCubit, CustomerState>(
      listener: (context, state) {

        if (state is CustomerLoading) {
          setState(() => isSubmitting = true);
        }

        if (state is CustomerMessage) {
          setState(() => isSubmitting = false);
          _showSuccess();
        }

        if (state is CustomerError) {
          setState(() => isSubmitting = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: Column(
            children: [
              AppPageHeader(
                isDark: isDark,
                accentColor: accent,
                title: l10n.bookingTitle,
              ),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Left: live summary (35%) ──────────────
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: _SummaryPanel(
                        isDark: isDark,
                        l10n: l10n,
                        accent: accent,
                        progress: progress,
                        serviceType: serviceType,
                        handymanId: handymanId,
                        selDate: selDate,
                        selTime: selTime,
                        city: city,
                        area: area,
                        isUrgent: isUrgent,
                        imageCount: images.where((i) => i != null).length,
                      ),
                    ),

                    VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                    // ── Right: form (65%) ─────────────────────
                    Expanded(
                      child: Column(
                        children: [
                          buildProgressBar(context),
                          Expanded(
                            child: Form(
                              key: formKey,
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(
                                  AppSpacing.xl.w,
                                  AppSpacing.lg.h,
                                  AppSpacing.xl.w,
                                  160.h,
                                ),
                                children: [
                                  ea(0, buildServiceCard(context, isDark, l10n)),
                                  SizedBox(height: 16.h),
                                  ea(1, buildDateTimeCard(context, isDark, l10n)),
                                  SizedBox(height: 16.h),
                                  ea(2, buildLocationCard(context, isDark, l10n)),
                                  SizedBox(height: 16.h),
                                  ea(3, buildImagesCard(context, isDark, l10n)),
                                  SizedBox(height: 16.h),
                                  ea(4, buildUrgentCard(context, isDark, l10n)),
                                  SizedBox(height: 16.h),
                                  ea(5, buildPaymentNote(context)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              buildSubmitBar(context, isDark, l10n),
            ],
          ),
        ),
      )
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SummaryPanel — tablet left: live booking summary
// ══════════════════════════════════════════════════════════════
class _SummaryPanel extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final Color accent;
  final double progress;
  final String? serviceType;
  final String? handymanId;
  final DateTime? selDate;
  final TimeOfDay? selTime;
  final String? city;
  final String? area;
  final bool isUrgent;
  final int imageCount;

  const _SummaryPanel({
    required this.isDark,
    required this.l10n,
    required this.accent,
    required this.progress,
    required this.serviceType,
    required this.handymanId,
    required this.selDate,
    required this.selTime,
    required this.city,
    required this.area,
    required this.isUrgent,
    required this.imageCount,
  });

  @override
  State<_SummaryPanel> createState() => _SummaryPanelState();
}

class _SummaryPanelState extends State<_SummaryPanel>
    with SingleTickerProviderStateMixin {
  // Rail entry
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.12, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _serviceLabel() {
    switch (widget.serviceType) {
      case 'plumbing':
        return widget.l10n.catPlumbing;
      case 'electricity':
        return widget.l10n.catElectricity;
      case 'carpentry':
        return widget.l10n.catCarpentry;
      case 'painting':
        return widget.l10n.catPainting;
      case 'ac':
        return widget.l10n.catAC;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;
    final pct = (widget.progress * 100).toInt();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          height: double.infinity,
          color: widget.isDark
              ? AppColors.darkBgSecondary.withOpacity(0.70)
              : Colors.white.withOpacity(0.75),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  l10n.bookingTitle,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.bookingServiceDetailsTitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),

                // Circular progress badge
                Center(
                  child: _CircularProgressBadge(
                    progress: widget.progress,
                    accent: widget.accent,
                    pct: pct,
                  ),
                ),
                SizedBox(height: 24.h),

                // Summary rows (show as filled or pending)
                _SummaryRow(
                  icon: Icons.miscellaneous_services_rounded,
                  label: l10n.bookingServiceType,
                  value: _serviceLabel(),
                  accent: widget.accent,
                  colorScheme: colorScheme,
                ),
                _SummaryRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.bookingDateLabel,
                  value: widget.selDate == null
                      ? null
                      : '${widget.selDate!.day}/${widget.selDate!.month}/${widget.selDate!.year}',
                  accent: widget.accent,
                  colorScheme: colorScheme,
                ),
                _SummaryRow(
                  icon: Icons.access_time_rounded,
                  label: l10n.bookingTimeLabel,
                  value: widget.selTime?.format(context),
                  accent: widget.accent,
                  colorScheme: colorScheme,
                ),
                _SummaryRow(
                  icon: Icons.location_on_rounded,
                  label: l10n.bookingLocationTitle,
                  value: (widget.city != null && widget.area != null)
                      ? '${widget.city} / ${widget.area}'
                      : null,
                  accent: widget.accent,
                  colorScheme: colorScheme,
                ),

                if (widget.isUrgent) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: widget.accent.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: widget.accent,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          l10n.bookingUrgentLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: widget.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (widget.imageCount > 0) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent[60]!.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 14.sp,
                          color: AppColors.accent[60],
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${widget.imageCount} ${l10n.bookingImagesTitle}',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent[60],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Circular progress badge ───────────────────────────────────
class _CircularProgressBadge extends StatelessWidget {
  final double progress;
  final Color accent;
  final int pct;
  const _CircularProgressBadge({
    required this.progress,
    required this.accent,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96.w,
      height: 96.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 96.w,
            height: 96.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 7,
              backgroundColor: accent.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              Text(
                'مكتمل',
                style: GoogleFonts.cairo(
                  fontSize: 10.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Summary row ───────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color accent;
  final ColorScheme colorScheme;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final filled = value != null;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: filled
                  ? accent.withOpacity(0.12)
                  : colorScheme.onSurfaceVariant.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              size: 16.sp,
              color: filled
                  ? accent
                  : colorScheme.onSurfaceVariant.withOpacity(0.40),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  filled ? value! : '—',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
                    color: filled
                        ? null
                        : colorScheme.onSurfaceVariant.withOpacity(0.40),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (filled)
            Icon(Icons.check_circle_rounded, size: 16.sp, color: accent),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SuccessDialog — elastic pop
// ══════════════════════════════════════════════════════════════
class _SuccessDialog extends StatefulWidget {
  final String requestNumber;
  final AppLocalizations l10n;
  final VoidCallback onDone;
  const _SuccessDialog({
    required this.requestNumber,
    required this.l10n,
    required this.onDone,
  });

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = widget.l10n;

    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(28.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary[60]!,
                        AppColors.secondary[60]!,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary[60]!.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 40.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                l10n.bookingSuccessTitle,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.bookingSuccessSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary[60]!.withOpacity(0.10),
                      AppColors.secondary[60]!.withOpacity(0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primary[60]!.withOpacity(0.20),
                  ),
                ),
                child: Text(
                  widget.requestNumber,
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary[60],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              AppGradientButton(
                label: l10n.bookingSuccessBtn,
                onTap: widget.onDone,
                gradient: LinearGradient(
                  colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                ),
                shadowColor: AppColors.primary[60]!.withOpacity(0.30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _ImageSlot, _UrgentToggle — polished versions
// ══════════════════════════════════════════════════════════════
class _ImageSlot extends StatelessWidget {
  final XFile? file;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final String addLabel;
  final String uploadedLabel;

  const _ImageSlot({
    required this.file,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    required this.addLabel,
    required this.uploadedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final has = file != null;
    return GestureDetector(
      onTap: has ? onRemove : onAdd,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: has
                ? AppColors.accent[60]!.withOpacity(0.05)
                : AppColors.primary[60]!.withOpacity(0.03),
            border: Border.all(
              color: has
                  ? AppColors.accent[60]!
                  : AppColors.primary[60]!.withOpacity(0.30),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: has
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.file(File(file!.path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 28.sp,
                      color: AppColors.primary[60],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      addLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary[60],
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

class _UrgentToggle extends StatelessWidget {
  final bool isUrgent;
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String urgentLabel;
  final String urgentDesc;
  final Color accent;
  final ValueChanged<bool> onChanged;

  const _UrgentToggle({
    required this.isUrgent,
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
    required this.urgentLabel,
    required this.urgentDesc,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isUrgent),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(AppSpacing.lg.w),
        decoration: BoxDecoration(
          color: isUrgent ? accent.withOpacity(0.07) : accent.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUrgent
                ? accent.withOpacity(0.30)
                : accent.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isUrgent ? accent : Colors.transparent,
                border: Border.all(
                  color: isUrgent
                      ? accent
                      : colorScheme.onSurfaceVariant.withOpacity(0.40),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: isUrgent
                  ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urgentLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    urgentDesc,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.access_time_rounded, size: 20.sp, color: accent),
          ],
        ),
      ),
    );
  }
}
