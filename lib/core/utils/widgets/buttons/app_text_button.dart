import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final AlignmentGeometry alignment;

  const AppTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.alignment = AlignmentDirectional.centerEnd,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: alignment,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: color ?? AppColors.primary[60],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}