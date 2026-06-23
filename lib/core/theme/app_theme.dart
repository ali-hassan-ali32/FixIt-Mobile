import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

abstract class AppTheme {
  static TextTheme _buildTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
  }) {
    final base = GoogleFonts.cairoTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 30.sp,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.15,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.2,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        height: 1.35,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.2,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: textTertiary,
        letterSpacing: 0.15,
      ),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required MaterialColor activePrimary,
  }) {
    final primary = activePrimary[60]!;

    OutlineInputBorder border([Color? color, double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.all(AppRadius.md),
        borderSide: BorderSide(
          color: color ?? colorScheme.outline,
          width: width,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: colorScheme,
      textTheme: textTheme,
      fontFamily: GoogleFonts.cairo().fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      splashFactory: InkSparkle.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: colorScheme.outlineVariant,
      disabledColor: colorScheme.onSurfaceVariant.withOpacity(0.5),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: primary.withOpacity(0.45),
          disabledForegroundColor: AppColors.white.withOpacity(0.75),
          textStyle: textTheme.labelLarge,
          minimumSize: Size(double.infinity, 52.h),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.lg),
          ),
          shadowColor: primary.withOpacity(0.3),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge?.copyWith(color: primary),
          minimumSize: Size(double.infinity, 52.h),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
          side: BorderSide(color: primary, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.lg),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        border: border(),
        enabledBorder: border(),
        focusedBorder: border(primary, 1.8),
        errorBorder: border(colorScheme.error),
        focusedErrorBorder: border(colorScheme.error, 1.8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shadowColor: Colors.black.withOpacity(0.05),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.lg),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.08)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        side: BorderSide(color: colorScheme.outline, width: 1.4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return colorScheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withOpacity(0.35);
          }
          return colorScheme.outline.withOpacity(0.3);
        }),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: primary.withOpacity(0.12),
        secondarySelectedColor: primary.withOpacity(0.12),
        labelStyle: textTheme.bodySmall ?? const TextStyle(),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.pill),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm.w),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        modalBackgroundColor: colorScheme.surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        ),
      ),
    );
  }

  static ThemeData lightTheme({bool isHandyman = false}) {
    final activePrimary = isHandyman ? AppColors.accent : AppColors.primary;
    final otherAccent = isHandyman ? AppColors.primary : AppColors.accent;

    return _buildTheme(
      activePrimary: activePrimary,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: activePrimary[60]!,
        onPrimary: AppColors.white,
        secondary: AppColors.secondary[60]!,
        onSecondary: AppColors.white,
        error: AppColors.danger,
        onError: AppColors.white,
        surface: AppColors.bgSecondary,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        onSurfaceVariant: AppColors.textTertiary,
        surfaceContainerHighest: AppColors.bgTertiary,
      ).copyWith(tertiary: otherAccent[60]),
      textTheme: _buildTextTheme(
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textTertiary: AppColors.textTertiary,
      ),
    );
  }

  static ThemeData darkTheme({bool isHandyman = false}) {
    final activePrimary = isHandyman ? AppColors.accent : AppColors.primary;
    final otherAccent = isHandyman ? AppColors.primary : AppColors.accent;

    return _buildTheme(
      activePrimary: activePrimary,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: activePrimary[50]!,
        onPrimary: AppColors.darkTextInverse,
        secondary: AppColors.secondary[50]!,
        onSecondary: AppColors.darkTextInverse,
        error: AppColors.darkDanger,
        onError: AppColors.white,
        surface: AppColors.darkBgSecondary,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderLight,
        onSurfaceVariant: AppColors.darkTextTertiary,
        surfaceContainerHighest: AppColors.darkBgTertiary,
      ).copyWith(tertiary: otherAccent[50]),
      textTheme: _buildTextTheme(
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        textTertiary: AppColors.darkTextTertiary,
      ),
    );
  }
}
