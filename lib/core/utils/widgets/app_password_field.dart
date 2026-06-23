import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/constants/enums/app_enums.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import 'app_text_field.dart';


class AppPasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final AppUserType userType;

  const AppPasswordField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.onChanged,
    this.userType = AppUserType.customer,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  void _toggle() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ── Dynamic Color ───────────────────────────────
    final isHandyman = widget.userType == AppUserType.handyman;

    final mainColor = isHandyman
        ? AppColors.accent[60]!
        : AppColors.primary[60]!;

    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _obscure,
      userType: widget.userType, // 👈 pass down

      suffixIcon: GestureDetector(
        onTap: _toggle,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,

            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.1, end: 0.0)
                    .animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.6, end: 1.0)
                        .animate(animation),
                    child: child,
                  ),
                ),
              );
            },

            child: Icon(
              key: ValueKey(_obscure),
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 22,

              // ── Dynamic Color ───────────────────
              color: _obscure
                  ? colorScheme.onSurfaceVariant
                  : mainColor,
            ),
          ),
        ),
      ),
    );
  }
}