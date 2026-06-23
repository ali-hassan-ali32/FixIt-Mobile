import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import 'app_date_picker.dart';

// ══════════════════════════════════════════════════════════════
// AppDateField
// Usage:
//   AppDateField(
//     label: 'تاريخ الميلاد',
//     hintText: 'اختر تاريخ ميلادك',
//     selectedDate: _dob,
//     onDateSelected: (date) => setState(() => _dob = date),
//   )
// ══════════════════════════════════════════════════════════════
class AppDateField extends StatelessWidget {
  final String label;
  final String hintText;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  final Color?    activeColor;

  const AppDateField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onDateSelected,
    this.selectedDate,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.activeColor,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd / MM / yyyy').format(date);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: selectedDate ?? DateTime(now.year - 18),
      activeColor: activeColor ?? AppColors.primary[60]!,
      firstDate:   firstDate ?? DateTime(1940),
      lastDate:    lastDate  ?? DateTime(now.year - 10),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasValue    = selectedDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyMedium),
        SizedBox(height: 8.h),
        FormField<DateTime>(
          initialValue: selectedDate,
          validator: validator != null ? (_) => validator!(selectedDate) : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await _pickDate(context);
                    state.didChange(selectedDate);
                  },
                  child: Container(
                    height: 52.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.all(AppRadius.md),
                      border: Border.all(
                        color: state.hasError
                            ? colorScheme.error
                            : colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasValue
                                ? _formatDate(selectedDate!)
                                : hintText,
                            style: textTheme.bodyLarge?.copyWith(
                              color: hasValue
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20.sp,
                          color: hasValue
                              ? AppColors.primary[60]
                              : colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Error Text ───────────────────────
                if (state.hasError) ...[
                  SizedBox(height: 6.h),
                  Text(
                    state.errorText!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}