import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../animations/app_motion.dart';

double _rsp(BuildContext context, double baseSize) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final scale = (screenWidth / 375).clamp(0.9, 1.2);
  return baseSize * scale;
}

class AppHandymanRequestCard extends StatefulWidget {
  final String requestId;
  final String title;
  final String date;
  final String time;
  final String area;
  // final String rate;
  final String customerName;
  final String customerSub;
  final String description;
  final List<Color> avatarColors;
  final bool isDark;
  final String newLabel;
  final String acceptLabel;
  final String detailsLabel;
  // final VoidCallback onAccept;
  final VoidCallback onDetails;

  const AppHandymanRequestCard({
    super.key,
    required this.requestId,
    required this.title,
    required this.date,
    required this.time,
    required this.area,
    // required this.rate,
    required this.customerName,
    required this.customerSub,
    required this.description,
    required this.avatarColors,
    required this.isDark,
    required this.newLabel,
    required this.acceptLabel,
    required this.detailsLabel,
    // required this.onAccept,
    required this.onDetails,
  });

  @override
  State<AppHandymanRequestCard> createState() => _AppHandymanRequestCardState();
}

class _AppHandymanRequestCardState extends State<AppHandymanRequestCard> with TickerProviderStateMixin {
  Color get teal => AppColors.accent[60]!;
  Color get tealDark => AppColors.accent[70]!;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _pulseGlow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 360;
        final isMedium = width >= 360 && width < 640;
        final isWide = width >= 640;

        return FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.18)
                        : teal.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderLight
                      : teal.withValues(alpha: 0.10),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [teal, teal.withValues(alpha: 0.12)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                      child: isWide
                          ? _buildWideCardLayout(isDark)
                          : isCompact
                          ? _buildCompactCardLayout(isDark, true)
                          : _buildCompactCardLayout(isDark, false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactCardLayout(bool isDark, bool ultraCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRowWrapped(ultraCompact),
        SizedBox(height: 10.h),
        _buildTitle(isDark),
        SizedBox(height: 12.h),
        _buildCustomerSection(isDark),
        SizedBox(height: 14.h),
        _buildDetailGridAdaptive(isDark, oneColumn: ultraCompact),
        SizedBox(height: 14.h),
        _buildDescription(isDark),
        SizedBox(height: 16.h),
        _buildActionButtonsAdaptive(isDark, stacked: ultraCompact),
      ],
    );
  }

  Widget _buildWideCardLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRowWrapped(false),
        SizedBox(height: 10.h),
        _buildTitle(isDark),
        SizedBox(height: 14.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildCustomerSection(isDark),
                  SizedBox(height: 14.h),
                  _buildDescription(isDark),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildDetailGridAdaptive(isDark, oneColumn: false),
                  SizedBox(height: 16.h),
                  _buildActionButtonsAdaptive(isDark, stacked: false),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderRowWrapped(bool wrap) {
    final idWidget = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: teal,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            '#${widget.requestId}',
            style: GoogleFonts.cairo(
              fontSize: _rsp(context, 11),
              fontWeight: FontWeight.w700,
              color: teal,
            ),
          ),
        ],
      ),
    );

    final badgeWidget = AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [teal, tealDark]),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: _pulseGlow.value * 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              widget.newLabel,
              style: GoogleFonts.cairo(
                fontSize: _rsp(context, 10),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );

    if (wrap) {
      return Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: [idWidget, badgeWidget],
      );
    }

    return Row(
      children: [
        idWidget,
        const Spacer(),
        badgeWidget,
      ],
    );
  }

  Widget _buildDetailGridAdaptive(bool isDark, {required bool oneColumn}) {
    if (oneColumn) {
      return Column(
        children: [
          _DetailGridCell(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: widget.date,
            isDark: isDark,
            accentColor: teal,
          ),
          SizedBox(height: 8.h),
          _DetailGridCell(
            icon: Icons.access_time_rounded,
            label: 'الوقت',
            value: widget.time,
            isDark: isDark,
            accentColor: teal,
          ),
          SizedBox(height: 8.h),
          _DetailGridCell(
            icon: Icons.location_on_outlined,
            label: 'المنطقة',
            value: widget.area,
            isDark: isDark,
            accentColor: teal,
          ),
          SizedBox(height: 8.h),
          //ToDo: Check: rate Later
          // _DetailGridCell(
          //   icon: Icons.attach_money_rounded,
          //   label: 'الأجر',
          //   value: widget.rate,
          //   isDark: isDark,
          //   accentColor: const Color(0xFFF7931E),
          // ),
        ],
      );
    }

    return _buildDetailGrid(isDark, stacked: false);
  }

  Widget _buildActionButtonsAdaptive(bool isDark, {required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          // SizedBox(
          //   width: double.infinity,
          //   child: _buildAcceptButton(isDark),
          // ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: _buildDetailsButton(isDark),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Expanded(child: _buildAcceptButton(isDark)),
        SizedBox(width: 10.w),
        Expanded(child: _buildDetailsButton(isDark)),
      ],
    );
  }

  // Widget _buildAcceptButton(bool isDark) {
  //   return AppTapScale(
  //     onTap: widget.onAccept,
  //     borderRadius: BorderRadius.circular(14.r),
  //     child: Container(
  //       height: 50.h,
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(colors: [teal, tealDark]),
  //         borderRadius: BorderRadius.circular(14.r),
  //         boxShadow: AppShadows.accent(color: teal),
  //       ),
  //       child: Center(
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.check_circle_outline_rounded,
  //                 size: _rsp(context, 18), color: Colors.white),
  //             SizedBox(width: 8.w),
  //             Flexible(
  //               child: Text(
  //                 widget.acceptLabel,
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: GoogleFonts.cairo(
  //                   fontSize: _rsp(context, 14),
  //                   fontWeight: FontWeight.w800,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDetailsButton(bool isDark) {
    return AppTapScale(
      onTap: widget.onDetails,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: teal.withValues(alpha: 0.25)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.detailsLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: _rsp(context, 14),
                    fontWeight: FontWeight.w700,
                    color: teal,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_back_rounded,
                  size: _rsp(context, 16), color: teal),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeaderRow(bool compactWrap) {
    final idBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: teal,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '#${widget.requestId}',
            style: GoogleFonts.cairo(
              fontSize: _rsp(context, 11),
              fontWeight: FontWeight.w700,
              color: teal,
            ),
          ),
        ],
      ),
    );

    final newBadge = AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [teal, tealDark]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: teal.withValues(alpha: _pulseGlow.value * 0.35),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.6 + _pulseGlow.value * 0.4,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.newLabel,
                  style: GoogleFonts.cairo(
                    fontSize: _rsp(context, 10),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (compactWrap) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [idBadge, newBadge],
      );
    }

    return Row(
      children: [
        idBadge,
        const Spacer(),
        newBadge,
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.title,
      style: GoogleFonts.cairo(
        fontSize: _rsp(context, 18),
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextPrimary : teal,
        height: 1.35,
      ),
    );
  }

  Widget _buildCustomerSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.5)
            : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: widget.avatarColors),
              boxShadow: [
                BoxShadow(
                  color: widget.avatarColors.first.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.customerName.isNotEmpty ? widget.customerName[0] : '?',
                style: GoogleFonts.cairo(
                  fontSize: _rsp(context, 22),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: GoogleFonts.cairo(
                    fontSize: _rsp(context, 15),
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: _rsp(context, 12),
                      color: const Color(0xFFF7931E),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        widget.customerSub,
                        style: GoogleFonts.cairo(
                          fontSize: _rsp(context, 11),
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppTapScale(
            onTap: () => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.phone_rounded,
                size: _rsp(context, 20),
                color: teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(bool isDark, {required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          _DetailGridCell(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: widget.date,
            isDark: isDark,
            accentColor: teal,
          ),
          const SizedBox(height: 8),
          _DetailGridCell(
            icon: Icons.access_time_rounded,
            label: 'الوقت',
            value: widget.time,
            isDark: isDark,
            accentColor: teal,
          ),
          const SizedBox(height: 8),
          _DetailGridCell(
            icon: Icons.location_on_outlined,
            label: 'المنطقة',
            value: widget.area,
            isDark: isDark,
            accentColor: teal,
          ),
          const SizedBox(height: 8),
          //ToDo: Check: rate Later
          // _DetailGridCell(
          //   icon: Icons.attach_money_rounded,
          //   label: 'الأجر',
          //   value: widget.rate,
          //   isDark: isDark,
          //   accentColor: const Color(0xFFF7931E),
          // ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DetailGridCell(
                icon: Icons.calendar_today_rounded,
                label: 'التاريخ',
                value: widget.date,
                isDark: isDark,
                accentColor: teal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DetailGridCell(
                icon: Icons.access_time_rounded,
                label: 'الوقت',
                value: widget.time,
                isDark: isDark,
                accentColor: teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DetailGridCell(
                icon: Icons.location_on_outlined,
                label: 'المنطقة',
                value: widget.area,
                isDark: isDark,
                accentColor: teal,
              ),
            ),
            const SizedBox(width: 8),
            //ToDo: Check: rate Later
            // Expanded(
            //   child: _DetailGridCell(
            //     icon: Icons.attach_money_rounded,
            //     label: 'الأجر',
            //     value: widget.rate,
            //     isDark: isDark,
            //     accentColor: const Color(0xFFF7931E),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.35)
            : const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: teal.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Text(
        widget.description,
        style: GoogleFonts.cairo(
          fontSize: _rsp(context, 13),
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          height: 1.7,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, {required bool vertical}) {
    final acceptButton = Expanded(
      child: AppTapScale(
        // onTap: widget.onAccept,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [teal, tealDark]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppShadows.accent(color: teal),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: _rsp(context, 18),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.acceptLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: _rsp(context, 14),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final detailsButton = Expanded(
      child: AppTapScale(
        onTap: widget.onDetails,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: teal.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.detailsLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: _rsp(context, 14),
                      fontWeight: FontWeight.w700,
                      color: teal,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_back_rounded,
                  size: _rsp(context, 16),
                  color: teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (vertical) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(children: [acceptButton]),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Row(children: [detailsButton]),
          ),
        ],
      );
    }

    return Row(
      children: [
        acceptButton,
        const SizedBox(width: 10),
        detailsButton,
      ],
    );
  }
}

class _DetailGridCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color accentColor;

  const _DetailGridCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface.withValues(alpha: 0.4)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderLight.withValues(alpha: 0.5)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: _rsp(context, 16), color: accentColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: _rsp(context, 9),
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: _rsp(context, 12),
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}