import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/translation/app_localizations.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Public API
// ══════════════════════════════════════════════════════════════════════════════

/// Shows a beautiful bottom-sheet date picker (drum scroll style).
/// [activeColor] — teal for handyman, primary orange for customer.
/// Returns the picked [DateTime] or null if cancelled.
Future<DateTime?> showAppDatePicker(
    BuildContext context, {
      required DateTime initialDate,
      required Color    activeColor,
      DateTime?         firstDate,
      DateTime?         lastDate,
      String?           title,
    }) {
  final now        = DateTime.now();
  // Resolve BEFORE entering the builder — context may be deactivated inside
  final resolvedTitle = title ?? AppLocalizations.of(context)!.datePickerTitle;
  return showModalBottomSheet<DateTime>(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    barrierColor:       Colors.black54,
    builder: (_) => _DatePickerSheet(
      initialDate: initialDate,
      activeColor: activeColor,
      firstDate:   firstDate ?? DateTime(1940),
      lastDate:    lastDate  ?? now.add(const Duration(days: 365 * 5)),
      title:       resolvedTitle,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Sheet
// ══════════════════════════════════════════════════════════════════════════════
class _DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final Color    activeColor;
  final DateTime firstDate;
  final DateTime lastDate;
  final String   title;

  const _DatePickerSheet({
    required this.initialDate,
    required this.activeColor,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet>
    with TickerProviderStateMixin {
  late int _day;
  late int _month;
  late int _year;

  late final AnimationController _entryCtrl;
  late final Animation<double>   _slideUp;
  late final Animation<double>   _fade;
  late final Animation<double>   _scale;

  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _yearCtrl;

  bool _confirmPressed = false;

  static const double _drumItemH = 54.0;

  // Precomputed lists
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    _day   = widget.initialDate.day;
    _month = widget.initialDate.month;
    _year  = widget.initialDate.year;

    _years = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
          (i) => widget.firstDate.year + i,
    );

    _dayCtrl   = FixedExtentScrollController(initialItem: _day - 1);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _yearCtrl  = FixedExtentScrollController(
        initialItem: _year - widget.firstDate.year);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _slideUp = Tween<double>(begin: 60.0, end: 0.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _dayCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // ── Days in current month ─────────────────────────────────
  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;

  void _onMonthChanged(int i) {
    HapticFeedback.selectionClick();
    final newMonth = i + 1;
    final maxDay   = DateTime(_year, newMonth + 1, 0).day;
    setState(() {
      _month = newMonth;
      if (_day > maxDay) {
        _day = maxDay;
        _dayCtrl.jumpToItem(_day - 1);
      }
    });
  }

  void _onYearChanged(int i) {
    HapticFeedback.selectionClick();
    final newYear = _years[i];
    final maxDay  = DateTime(newYear, _month + 1, 0).day;
    setState(() {
      _year = newYear;
      if (_day > maxDay) {
        _day = maxDay;
        _dayCtrl.jumpToItem(_day - 1);
      }
    });
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(DateTime(_year, _month, _day));
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(null);
  }

  // ── Month names ───────────────────────────────────────────
  String _monthLabel(int month) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    const en = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const ar = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return isAr ? ar[month] : en[month];
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final l10n      = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final bottom    = MediaQuery.of(context).padding.bottom;
    final accent    = widget.activeColor;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slideUp.value),
          child: Transform.scale(
            scale: _scale.value,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.15),
              blurRadius: 40, spreadRadius: -4, offset: const Offset(0, -8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24, offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            // Handle
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 18.h),

            // Title
            Text(widget.title,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            SizedBox(height: 16.h),

            // Live selected date preview
            _buildDatePreview(isDark, accent, textTheme),
            SizedBox(height: 16.h),

            // Drums
            _buildDrums(isDark, accent),

            SizedBox(height: 24.h),

            // Buttons
            _buildButtons(isDark, accent, l10n, bottom),
          ],
        ),
      ),
    );
  }

  // ── Date preview ─────────────────────────────────────────────
  Widget _buildDatePreview(bool isDark, Color accent, TextTheme textTheme) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dt = DateTime(_year, _month, _day);

    // Day of week
    const enDays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const arDays = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    final dowIndex = dt.weekday - 1; // 0=Mon
    final dow = isAr ? arDays[dowIndex] : enDays[dowIndex];

    final monthName = _monthLabel(_month);
    final dayStr    = _day.toString().padLeft(2, '0');
    final yearStr   = _year.toString();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1.0).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Container(
        key: ValueKey('\$_day-\$_month-\$_year'),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: accent.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day of week badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(dow, style: GoogleFonts.cairo(
                  fontSize: 11.sp, fontWeight: FontWeight.w700,
                  color: Colors.white)),
            ),
            SizedBox(width: 12.w),
            // Full date
            Text(
              isAr
                  ? '\$dayStr \$monthName \$yearStr'
                  : '\$monthName \$dayStr, \$yearStr',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Drums ─────────────────────────────────────────────────
  Widget _buildDrums(bool isDark, Color accent) {
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return SizedBox(
      height: _drumItemH * 5,
      child: Stack(
        children: [
          // Selection highlight band
          Positioned(
            top: _drumItemH * 2, left: 0, right: 0,
            child: Container(
              height: _drumItemH,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
              ),
            ),
          ),

          // Top fade
          Positioned(
            top: 0, left: 0, right: 0,
            height: _drumItemH * 1.5,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [surfaceColor, surfaceColor.withOpacity(0.0)],
                  ),
                ),
              ),
            ),
          ),

          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: _drumItemH * 1.5,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [surfaceColor, surfaceColor.withOpacity(0.0)],
                  ),
                ),
              ),
            ),
          ),

          // The three drums
          Row(
            children: [
              // Day
              Expanded(
                flex: 2,
                child: _Drum(
                  controller: _dayCtrl,
                  itemCount: _daysInMonth,
                  itemBuilder: (i) => _DrumItem(
                    label: (i + 1).toString().padLeft(2, '0'),
                    isSelected: (i + 1) == _day,
                    accent: accent,
                    isDark: isDark,
                  ),
                  onSelected: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _day = i + 1);
                  },
                ),
              ),

              // Dot separator
              _DrumDot(accent: accent),

              // Month
              Expanded(
                flex: 3,
                child: _Drum(
                  controller: _monthCtrl,
                  itemCount: 12,
                  itemBuilder: (i) => _DrumItem(
                    label: _monthLabel(i + 1),
                    isSelected: (i + 1) == _month,
                    accent: accent,
                    isDark: isDark,
                    fontSize: 17.sp,
                  ),
                  onSelected: _onMonthChanged,
                ),
              ),

              // Dot separator
              _DrumDot(accent: accent),

              // Year
              Expanded(
                flex: 3,
                child: _Drum(
                  controller: _yearCtrl,
                  itemCount: _years.length,
                  itemBuilder: (i) => _DrumItem(
                    label: _years[i].toString(),
                    isSelected: _years[i] == _year,
                    accent: accent,
                    isDark: isDark,
                  ),
                  onSelected: _onYearChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────
  Widget _buildButtons(
      bool isDark, Color accent, AppLocalizations l10n, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, bottom + 20.h),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: GestureDetector(
              onTap: _cancel,
              child: Container(
                height: 52.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBgPrimary
                      : const Color(0xFFF4F6F8),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: accent.withOpacity(0.12)),
                ),
                child: Center(
                  child: Text(l10n.cancel,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      )),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          // Confirm
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTapDown:   (_) => setState(() => _confirmPressed = true),
              onTapCancel: () => setState(() => _confirmPressed = false),
              onTapUp:     (_) {
                setState(() => _confirmPressed = false);
                _confirm();
              },
              child: AnimatedScale(
                scale:    _confirmPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [accent, accent.withOpacity(0.82)]),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.30),
                        blurRadius: 14, offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(l10n.confirm,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _Drum
// ══════════════════════════════════════════════════════════════════════════════
class _Drum extends StatelessWidget {
  final FixedExtentScrollController    controller;
  final int                            itemCount;
  final Widget Function(int)           itemBuilder;
  final ValueChanged<int>              onSelected;

  const _Drum({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller:            controller,
      itemExtent:            _DatePickerSheetState._drumItemH,
      perspective:           0.003,
      diameterRatio:         2.0,
      physics:               const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder:    (_, i) => itemBuilder(i),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _DrumItem
// ══════════════════════════════════════════════════════════════════════════════
class _DrumItem extends StatelessWidget {
  final String  label;
  final bool    isSelected;
  final Color   accent;
  final bool    isDark;
  final double? fontSize;

  const _DrumItem({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.isDark,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: GoogleFonts.cairo(
          fontSize:   isSelected ? (fontSize ?? 26.sp) : (fontSize != null ? fontSize! * 0.82 : 20.sp),
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected
              ? accent
              : (isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary)
              .withOpacity(0.45),
        ),
        child: Text(label),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _DrumDot — small dot separator between drums
// ══════════════════════════════════════════════════════════════════════════════
class _DrumDot extends StatelessWidget {
  final Color accent;
  const _DrumDot({required this.accent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12.w,
      child: Center(
        child: Container(
          width: 5.w, height: 5.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}