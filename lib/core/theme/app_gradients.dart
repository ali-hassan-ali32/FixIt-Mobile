import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppGradients {
  // ── Primary CTA button gradient
  static final primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary[600]!,
      AppColors.secondary[600]!,
    ],
  );

  // ── Handyman teal gradient (profile headers, dashboard)
  static final secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.accent[600]!,
      AppColors.accent[700]!,
    ],
  );

  // ── Page background gradient
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.bgPrimary,
      AppColors.bgTertiary,
    ],
  );

  // ── Customer home hero header gradient
  static final heroOrange = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      AppColors.primary[600]!,
      AppColors.primary[700]!,
    ],
  );
}

