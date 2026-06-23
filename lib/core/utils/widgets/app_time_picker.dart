import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/translation/app_localizations.dart';
import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// Public API
// ══════════════════════════════════════════════════════════════

/// Shows a beautiful bottom-sheet time picker.
/// [activeColor] — teal for handyman, primary orange for customer.
/// Returns the picked [TimeOfDay] or null if cancelled.
Future<TimeOfDay?> showAppTimePicker(
    BuildContext context, {
      required TimeOfDay  initialTime,
      required Color      activeColor,
      String?             title,
    }) {
  return showModalBottomSheet<TimeOfDay>(
    context:        context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    barrierColor:       Colors.black54,
    builder: (_) => _TimePickerSheet(
      initialTime: initialTime,
      activeColor: activeColor,
      title:       title ?? AppLocalizations.of(context)!.timePickerTitle,
    ),
  );
}

// ══════════════════════════════════════════════════════════════
// Sheet
// ══════════════════════════════════════════════════════════════
class _TimePickerSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final Color     activeColor;
  final String    title;

  const _TimePickerSheet({
    required this.initialTime,
    required this.activeColor,
    required this.title,
  });

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet>
    with SingleTickerProviderStateMixin {
  late int  _hour;    // 1–12
  late int  _minute;  // 0–59
  late bool _isPm;

  late final AnimationController _entryCtrl;
  late final Animation<double>   _slideUp;
  late final Animation<double>   _fade;
  late final Animation<double>   _scale;

  // drum scroll controllers
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;

  // press state for confirm btn
  bool _confirmPressed = false;

  static const double _drumItemH = 54.0;
  static const int    _hours     = 12;
  static const int    _minutes   = 60;

  @override
  void initState() {
    super.initState();
    // convert 24h → 12h
    final h24 = widget.initialTime.hour;
    _isPm   = h24 >= 12;
    _hour   = h24 % 12 == 0 ? 12 : h24 % 12;
    _minute = widget.initialTime.minute;

    _hourCtrl = FixedExtentScrollController(initialItem: _hour - 1);
    _minCtrl  = FixedExtentScrollController(initialItem: _minute);

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
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  TimeOfDay get _result {
    int h = _isPm ? (_hour % 12) + 12 : _hour % 12;
    return TimeOfDay(hour: h, minute: _minute);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(_result);
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final l10n        = AppLocalizations.of(context)!;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bottom      = MediaQuery.of(context).padding.bottom;
    final accent      = widget.activeColor;

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
          borderRadius: BorderRadius.only(
            topLeft:     Radius.circular(28.r),
            topRight:    Radius.circular(28.r),
            bottomLeft:  Radius.circular(28.r),
            bottomRight: Radius.circular(28.r),
          ),
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
            // handle
            Container(
              width: 40.w, height: 4.h,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.25),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 18.h),

            // title
            Text(widget.title,
                style: textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            SizedBox(height: 20.h),

            // ── Drums ──────────────────────────────────────
            _buildDrums(isDark, accent, colorScheme),

            SizedBox(height: 22.h),

            // ── AM / PM toggle ─────────────────────────────
            _buildAmPmToggle(isDark, accent, l10n),

            SizedBox(height: 24.h),

            // ── Buttons ────────────────────────────────────
            _buildButtons(isDark, accent, l10n, bottom),
          ],
        ),
      ),
    );
  }

  // ── Drums ────────────────────────────────────────────────
  Widget _buildDrums(bool isDark, Color accent, ColorScheme colorScheme) {
    return SizedBox(
      height: _drumItemH * 5,
      child: Stack(
        children: [
          // selection highlight band
          Positioned(
            top: _drumItemH * 2,
            left: 0, right: 0,
            child: Container(
              height: _drumItemH,
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
              ),
            ),
          ),

          // top fade
          Positioned(
            top: 0, left: 0, right: 0,
            height: _drumItemH * 1.4,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.darkSurface : Colors.white),
                      (isDark ? AppColors.darkSurface : Colors.white)
                          .withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: _drumItemH * 1.4,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      (isDark ? AppColors.darkSurface : Colors.white),
                      (isDark ? AppColors.darkSurface : Colors.white)
                          .withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // drums row
          Row(
            children: [
              // ── Hour drum ──────────────────────────────
              Expanded(
                child: _Drum(
                  controller: _hourCtrl,
                  itemCount:  _hours,
                  itemBuilder: (i) {
                    final val  = i + 1;
                    final sel  = val == _hour;
                    return _DrumItem(
                      label:     val.toString(),
                      isSelected: sel,
                      accent:    accent,
                      isDark:    isDark,
                    );
                  },
                  onSelected: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _hour = i + 1);
                  },
                ),
              ),

              // colon
              _DrumColon(accent: accent, isDark: isDark),

              // ── Minute drum ────────────────────────────
              Expanded(
                child: _Drum(
                  controller: _minCtrl,
                  itemCount:  _minutes,
                  itemBuilder: (i) {
                    final sel = i == _minute;
                    return _DrumItem(
                      label:      i.toString().padLeft(2, '0'),
                      isSelected: sel,
                      accent:     accent,
                      isDark:     isDark,
                    );
                  },
                  onSelected: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _minute = i);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── AM / PM toggle ───────────────────────────────────────
  Widget _buildAmPmToggle(bool isDark, Color accent, AppLocalizations l10n) {
    final bg     = isDark ? AppColors.darkBgPrimary : const Color(0xFFF4F6F8);
    final txtOn  = Colors.white;
    final txtOff = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      height: 44.h,
      margin: EdgeInsets.symmetric(horizontal: 32.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isPm) {
                  HapticFeedback.selectionClick();
                  setState(() => _isPm = false);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: !_isPm
                      ? LinearGradient(
                      colors: [accent, accent.withOpacity(0.85)])
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(l10n.timePickerAm,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: !_isPm ? txtOn : txtOff,
                      )),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_isPm) {
                  HapticFeedback.selectionClick();
                  setState(() => _isPm = true);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: _isPm
                      ? LinearGradient(
                      colors: [accent, accent.withOpacity(0.85)])
                      : null,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(l10n.timePickerPm,
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: _isPm ? txtOn : txtOff,
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ──────────────────────────────────────────────
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

// ══════════════════════════════════════════════════════════════
// _Drum  — single ListWheelScrollView column
// ══════════════════════════════════════════════════════════════
class _Drum extends StatelessWidget {
  final FixedExtentScrollController       controller;
  final int                               itemCount;
  final Widget Function(int index)        itemBuilder;
  final ValueChanged<int>                 onSelected;

  const _Drum({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller:     controller,
      itemExtent:     _TimePickerSheetState._drumItemH,
      perspective:    0.003,
      diameterRatio:  2.0,
      physics:        const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelected,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder:    (_, i) => itemBuilder(i),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _DrumItem
// ══════════════════════════════════════════════════════════════
class _DrumItem extends StatelessWidget {
  final String label;
  final bool   isSelected;
  final Color  accent;
  final bool   isDark;

  const _DrumItem({
    required this.label,
    required this.isSelected,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: GoogleFonts.cairo(
          fontSize:   isSelected ? 26.sp : 20.sp,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color:      isSelected
              ? accent
              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
              .withOpacity(0.45),
        ),
        child: Text(label),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _DrumColon
// ══════════════════════════════════════════════════════════════
class _DrumColon extends StatefulWidget {
  final Color accent;
  final bool  isDark;
  const _DrumColon({required this.accent, required this.isDark});

  @override
  State<_DrumColon> createState() => _DrumColonState();
}

class _DrumColonState extends State<_DrumColon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _blink.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _blink,
            builder: (_, __) => Opacity(
              opacity: 0.5 + _blink.value * 0.5,
              child: Column(
                children: [
                  Container(
                    width: 6.w, height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 6.w, height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}