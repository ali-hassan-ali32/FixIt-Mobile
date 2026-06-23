import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';

// ══════════════════════════════════════════════════════════════
// HandymanViewNewRequestView — layout router
// Route arg: String requestId
// ══════════════════════════════════════════════════════════════
class HandymanViewNewRequestView extends StatelessWidget {
  final String requestId;
  const HandymanViewNewRequestView({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth >= 600
        ? _HandymanNewRequestTabletBody(requestId: requestId)
        : _HandymanNewRequestMobileBody(requestId: requestId),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _NewRequestBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;

  late final AnimationController masterCtrl;
  late final List<Animation<double>> fadeAnims;
  late final List<Animation<Offset>> slideAnims;

  static const int sectionCount = 6;

  @override
  void initState() {
    super.initState();
    masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnims = List.generate(sectionCount, (i) {
      final start = i * 0.12;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.42).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    slideAnims = List.generate(sectionCount, (i) {
      final start = i * 0.12;
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: masterCtrl,
          curve: Interval(
            start.clamp(0.0, 1.0),
            (start + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    masterCtrl.forward();
  }

  @override
  void dispose() {
    masterCtrl.dispose();
    super.dispose();
  }

  Widget animated(int i, Widget child) => FadeTransition(
    opacity: fadeAnims[i.clamp(0, sectionCount - 1)],
    child: SlideTransition(
      position: slideAnims[i.clamp(0, sectionCount - 1)],
      child: child,
    ),
  );

  // ── Header ────────────────────────────────────────────────
  Widget buildHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
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
        color: isDark ? AppColors.darkSurface : Colors.white,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.newReqTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                // TODO: fix
                '#requestId',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Customer card ─────────────────────────────────────────
  Widget buildCustomerCard(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return _SectionCard(
      isDark: isDark,
      teal: teal,
      margin: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.xl.h,
        AppSpacing.xl.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newReqCustomerInfo,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16.h),

          // Avatar + info
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أحمد محمود',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      l10n.newReqNewCustomer,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 15.sp,
                          color: const Color(0xFFF7931E),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '٥.٠',
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Contact buttons — disabled until accepted
          Row(
            children: [
              Expanded(
                child: _ContactBtn(
                  label: l10n.newReqCall,
                  icon: Icons.phone_outlined,
                  isPrimary: true,
                  teal: teal,
                  disabled: true,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ContactBtn(
                  label: l10n.newReqMessage,
                  icon: Icons.chat_bubble_outline_rounded,
                  isPrimary: false,
                  teal: teal,
                  disabled: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Service details ───────────────────────────────────────
  Widget buildServiceDetails(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return _SectionCard(
      isDark: isDark,
      teal: teal,
      margin: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.md.h,
        AppSpacing.xl.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newReqServiceDetails,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8.h),
          _DetailRow(
            label: l10n.newReqServiceType,
            value: 'سباكة - صيانة عامة',
            isDark: isDark,
            teal: teal,
          ),
          _DetailRow(
            label: l10n.newReqDateTime,
            value: '٢٠٢٦/٠٢/١٢  •  ١٠:٠٠ ص',
            isDark: isDark,
            teal: teal,
          ),
          _DetailRow(
            label: l10n.newReqLocation,
            value: 'القاهرة - مدينة نصر',
            isDark: isDark,
            teal: teal,
          ),
          // Locked address
          _DetailRow(
            label: l10n.newReqAddress,
            isDark: isDark,
            teal: teal,
            isLast: false,
            valueWidget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    l10n.newReqAddressLocked,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          _DetailRow(
            label: l10n.newReqPrice,
            value: '١٥٠ ج/ساعة',
            valueColor: const Color(0xFFFF6B35),
            isDark: isDark,
            teal: teal,
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ── Description ───────────────────────────────────────────
  Widget buildDescription(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.md.h,
        AppSpacing.xl.w,
        0,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: teal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: teal.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.newReqProblemDesc,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تسريب في حنفية المطبخ ويحتاج إلى إصلاح عاجل. الماء يتسرب بشكل مستمر ويسبب إهدار كبير. أرجو الحضور في أقرب وقت ممكن.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Images ────────────────────────────────────────────────
  Widget buildImages(bool isDark, AppLocalizations l10n, TextTheme textTheme) {
    final gradients = [
      [teal, AppColors.accent[70] ?? const Color(0xFF44A3A0)],
      [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      [const Color(0xFF4ECDC4), const Color(0xFF44A3A0)],
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.md.h,
        AppSpacing.xl.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newReqProblemImages,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i < 2 ? 10.w : 0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradients[i],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        size: 28.sp,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Action bar ────────────────────────────────────────────
  Widget buildActionBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottom + 16.h),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept
          _AnimatedActionButton(
            label: l10n.requestAcceptBtn,
            isPrimary: true,
            teal: teal,
            icon: Icons.check_circle_outline_rounded,
            onTap: () => showAnimatedConfirmDialog(
              context: context,
              isDark: isDark,
              icon: Icons.check_circle_outline_rounded,
              title: l10n.requestAcceptTitle,
              message: l10n.requestAcceptMessage,
              cancelLabel: l10n.trackCancelKeep,
              confirmLabel: l10n.requestAcceptConfirmBtn,
              isDanger: false,
              confirmColor: teal,
              onConfirm: () => Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.handymanActiveJobs),
            ),
          ),
          SizedBox(height: 10.h),
          // Reject
          _AnimatedActionButton(
            label: l10n.newReqRejectBtn,
            isPrimary: false,
            teal: teal,
            icon: Icons.cancel_outlined,
            onTap: () => showAnimatedConfirmDialog(
              context: context,
              isDark: isDark,
              icon: Icons.cancel_outlined,
              title: l10n.newReqRejectTitle,
              message: l10n.newReqRejectMessage,
              cancelLabel: l10n.trackCancelKeep,
              confirmLabel: l10n.newReqRejectConfirmBtn,
              isDanger: true,
              onConfirm: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _HandymanNewRequestMobileBody extends StatefulWidget {
  final String requestId;
  const _HandymanNewRequestMobileBody({required this.requestId});

  @override
  State<_HandymanNewRequestMobileBody> createState() =>
      _HandymanNewRequestMobileBodyState();
}

class _HandymanNewRequestMobileBodyState
    extends _NewRequestBase<_HandymanNewRequestMobileBody> {
  late final String requestId;

  @override
  void initState() {
    requestId = widget.requestId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBgPrimary
          : const Color(0xFFF4F9FA),
      body: AppMainBackground(
        child: Stack(
          children: [
            // ── Scrollable content ────────────────────────
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: animated(
                    0,
                    buildHeader(context, isDark, l10n, textTheme, colorScheme),
                  ),
                ),
                SliverToBoxAdapter(
                  child: animated(
                    1,
                    buildCustomerCard(isDark, l10n, textTheme, colorScheme),
                  ),
                ),
                SliverToBoxAdapter(
                  child: animated(
                    2,
                    buildServiceDetails(isDark, l10n, textTheme, colorScheme),
                  ),
                ),
                SliverToBoxAdapter(
                  child: animated(
                    3,
                    buildDescription(isDark, l10n, textTheme, colorScheme),
                  ),
                ),
                SliverToBoxAdapter(
                  child: animated(4, buildImages(isDark, l10n, textTheme)),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s160.h)),
              ],
            ),

            // ── Fixed bottom action bar ───────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: animated(5, buildActionBar(context, isDark, l10n)),
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
class _HandymanNewRequestTabletBody extends StatefulWidget {
  final String requestId;
  const _HandymanNewRequestTabletBody({required this.requestId});

  @override
  State<_HandymanNewRequestTabletBody> createState() =>
      _HandymanNewRequestTabletBodyState();
}

class _HandymanNewRequestTabletBodyState
    extends _NewRequestBase<_HandymanNewRequestTabletBody> {
  late final String requestId;

  @override
  void initState() {
    requestId = widget.requestId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left panel (38%) ───────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: animated(
                            0,
                            _buildTabletHeaderCard(
                              context,
                              isDark,
                              l10n,
                              textTheme,
                              colorScheme,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animated(
                            1,
                            buildCustomerCard(
                              isDark,
                              l10n,
                              textTheme,
                              colorScheme,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 160.h)),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, color: teal.withOpacity(0.10)),

                  // ── Right panel (62%) ──────────────────────
                  // TODO: center this.
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: animated(
                            2,
                            buildServiceDetails(
                              isDark,
                              l10n,
                              textTheme,
                              colorScheme,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animated(
                            3,
                            buildDescription(
                              isDark,
                              l10n,
                              textTheme,
                              colorScheme,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: animated(
                            4,
                            buildImages(isDark, l10n, textTheme),
                          ),
                        ),
                        SliverToBoxAdapter(child: SizedBox(height: 160.h)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fixed action bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: animated(5, buildActionBar(context, isDark, l10n)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeaderCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.xl.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBackButton(isDark: false, tapColor: Colors.white),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.newReqTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '#$requestId',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  l10n.requestNewLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Quick info
          Row(
            children: [
              _QuickInfoItem(
                icon: Icons.calendar_today_rounded,
                label: l10n.newReqDateTime,
                value: '٢٠٢٦/٠٢/١٢',
              ),
              SizedBox(width: 20.w),
              _QuickInfoItem(
                icon: Icons.access_time_rounded,
                label: l10n.newReqServiceType,
                value: 'سباكة',
              ),
              SizedBox(width: 20.w),
              _QuickInfoItem(
                icon: Icons.payments_outlined,
                label: l10n.newReqPrice,
                value: '١٥٠ ج/س',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Reusable Widgets
// ══════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final bool isDark;
  final Color teal;
  final Widget child;
  final EdgeInsets? margin;

  const _SectionCard({
    required this.isDark,
    required this.teal,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: EdgeInsets.all(20.w),
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? valueWidget;
  final bool isDark;
  final Color teal;
  final bool isLast;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueColor,
    this.valueWidget,
    required this.isDark,
    required this.teal,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: teal.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child:
                valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.end,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color teal;
  final bool disabled;

  const _ContactBtn({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.teal,
    this.disabled = false,
  });

  @override
  State<_ContactBtn> createState() => _ContactBtnState();
}

class _ContactBtnState extends State<_ContactBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.95,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.disabled ? 0.45 : 1.0,
      child: GestureDetector(
        onTapDown: widget.disabled
            ? null
            : (_) {
                _ctrl.forward();
                HapticFeedback.selectionClick();
              },
        onTapUp: widget.disabled
            ? null
            : (_) {
                _ctrl.reverse();
              },
        onTapCancel: widget.disabled ? null : () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 11.h),
            decoration: BoxDecoration(
              gradient: widget.isPrimary && !widget.disabled
                  ? LinearGradient(
                      colors: [widget.teal, widget.teal.withOpacity(0.8)],
                    )
                  : null,
              color: widget.isPrimary
                  ? (widget.disabled ? Colors.grey.shade300 : null)
                  : widget.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 16.sp,
                  color: widget.isPrimary ? Colors.white : widget.teal,
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.label,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: widget.isPrimary ? Colors.white : widget.teal,
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

class _AnimatedActionButton extends StatefulWidget {
  final String label;
  final bool isPrimary;
  final Color teal;
  final IconData icon;
  final VoidCallback onTap;

  const _AnimatedActionButton({
    required this.label,
    required this.isPrimary,
    required this.teal,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
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
    final isDanger = !widget.isPrimary;
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
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      widget.teal,
                      AppColors.accent[70] ?? const Color(0xFF44A3A0),
                    ],
                  )
                : null,
            color: isDanger ? AppColors.danger.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: 18.sp,
                color: widget.isPrimary
                    ? Colors.white
                    : (isDanger ? AppColors.danger : widget.teal),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.isPrimary
                      ? Colors.white
                      : (isDanger ? AppColors.danger : widget.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.sp, color: Colors.white),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 9.sp,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
