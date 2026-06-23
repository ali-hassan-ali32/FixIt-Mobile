import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppFieldLabel
// Required/optional label for form fields.
//
// Usage:
//   AppFieldLabel(label: 'نوع الخدمة', required: true)
//   AppFieldLabel(label: 'العنوان', required: false)
// ══════════════════════════════════════════════════════════════
class AppFieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const AppFieldLabel({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.cairo(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          children: required
              ? [
                  TextSpan(
                    text: ' *',
                    style: GoogleFonts.cairo(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppFormDropdown
// Styled DropdownButtonFormField matching FixIt design system.
//
// Usage (customer):
//   AppFormDropdown<String>(value: _city, hint: '...', isDark: isDark, ...)
//
// Usage (handyman):
//   AppFormDropdown<String>(..., accentColor: AppColors.accent[60])
// ══════════════════════════════════════════════════════════════
class AppFormDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final bool isDark;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  /// Accent color for borders and icons.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color? accentColor;

  const AppFormDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.isDark,
    required this.items,
    required this.onChanged,
    this.validator,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary[60]!;
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      decoration: appInputDecoration(isDark, context, accentColor: accent),
      hint: Text(
        hint,
        style: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      items: items,
      style: GoogleFonts.cairo(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: accent),
      isExpanded: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppFormTextField
// Single-line text input matching FixIt design system.
//
// Usage (customer):
//   AppFormTextField(controller: _ctrl, hint: '...', isDark: isDark)
//
// Usage (handyman):
//   AppFormTextField(..., accentColor: AppColors.accent[60])
// ══════════════════════════════════════════════════════════════
class AppFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final FormFieldValidator<String>? validator;

  /// Accent color for focused border.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color? accentColor;

  const AppFormTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.isDark,
    this.keyboardType,
    this.textDirection,
    this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textDirection: textDirection,
      focusNode: focusNode,
      textInputAction: nextFocusNode != null
          ? TextInputAction.next
          : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      style: GoogleFonts.cairo(fontSize: 13.sp),
      decoration: appInputDecoration(
        isDark,
        context,
        hint: hint,
        accentColor: accentColor,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppFormTextArea
// Multi-line text input matching FixIt design system.
//
// Usage (customer):
//   AppFormTextArea(controller: _ctrl, hint: '...', isDark: isDark)
//
// Usage (handyman):
//   AppFormTextArea(..., accentColor: AppColors.accent[60])
// ══════════════════════════════════════════════════════════════
class AppFormTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  /// Accent color for focused border.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color? accentColor;

  const AppFormTextArea({
    super.key,
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 4,
    this.validator,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.cairo(fontSize: 13.sp),
      decoration: appInputDecoration(
        isDark,
        context,
        hint: hint,
        accentColor: accentColor,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AppPickerField
// Read-only tappable field for date/time/location pickers.
//
// Usage (customer):
//   AppPickerField(value: _date, hint: '...', icon: ..., isDark: isDark, onTap: _pick)
//
// Usage (handyman):
//   AppPickerField(..., accentColor: AppColors.accent[60])
// ══════════════════════════════════════════════════════════════
class AppPickerField extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  /// Accent color for border and icon when a value is selected.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color? accentColor;

  const AppPickerField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary[60]!;
    final hasValue = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
            color: hasValue ? accent : accent.withOpacity(0.2),
            width: hasValue ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: hasValue
                  ? accent
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                value ?? hint,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// appInputDecoration
// Shared InputDecoration factory used across all form widgets.
//
// Usage (customer):
//   decoration: appInputDecoration(isDark, context, hint: 'اكتب هنا')
//
// Usage (handyman):
//   decoration: appInputDecoration(isDark, context,
//       hint: '...', accentColor: AppColors.accent[60])
// ══════════════════════════════════════════════════════════════
InputDecoration appInputDecoration(
  bool isDark,
  BuildContext context, {
  String? hint,

  /// Accent color for focused border and fill tint.
  /// Defaults to AppColors.primary[60] (customer orange).
  Color? accentColor,
}) {
  final accent = accentColor ?? AppColors.primary[60]!;

  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.cairo(
      fontSize: 13.sp,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
    filled: true,
    fillColor: isDark ? AppColors.darkSurface : accent.withOpacity(0.02),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: accent.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: accent.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide(color: AppColors.danger, width: 1.5),
    ),
  );
}
