// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'app_colors.dart';
// import 'app_shadows.dart';
// import 'app_sizes.dart';
//
// // ── AppBar ────────────────────────────
// abstract class AppTheme {
//   // ─────────────────────────────────────────
//   // Shared TextTheme
//   // ─────────────────────────────────────────
//   static TextTheme _buildTextTheme({
//     required Color textPrimary,
//     required Color textSecondary,
//     required Color textTertiary,
//   }) {
//     return TextTheme(
//       displayLarge:  TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700, color: textPrimary),
//       displayMedium: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: textPrimary),
//       displaySmall:  TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textPrimary),
//       bodyLarge:     TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: textSecondary),
//       bodyMedium:    TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textPrimary),
//       bodySmall:     TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: textTertiary),
//       labelLarge:    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.white),
//     );
//   }
//
//   // ─────────────────────────────────────────
//   // Shared ThemeData builder
//   // ─────────────────────────────────────────
//   static ThemeData _buildTheme({
//     required ColorScheme colorScheme,
//     required TextTheme textTheme,
//   }) {
//     return ThemeData(
//       colorScheme: colorScheme,
//       textTheme: textTheme,
//       useMaterial3: true,
//       fontFamily: GoogleFonts.cairo().fontFamily,
//
//       // ── Scaffold ──────────────────────────
//       scaffoldBackgroundColor: colorScheme.surface,
//
//       // ── AppBar ────────────────────────────
//       appBarTheme: AppBarTheme(
//         backgroundColor: colorScheme.surface,
//         foregroundColor: colorScheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: textTheme.displaySmall,
//       ),
//
//       // ── FilledButton ──────────────────────
//       filledButtonTheme: FilledButtonThemeData(
//         style: FilledButton.styleFrom(
//           backgroundColor: AppColors.primary[60],
//           foregroundColor: AppColors.white,
//           textStyle: textTheme.labelLarge,
//           minimumSize: Size(double.infinity, 52.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(AppRadius.lg),
//           ),
//           shadowColor: AppShadows.primary.first.color,
//           elevation: 4,
//         ),
//       ),
//
//       // ── OutlinedButton ────────────────────
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary[60],
//           textStyle: textTheme.labelLarge?.copyWith(color: AppColors.primary[60]),
//           minimumSize: Size(double.infinity, 52.h),
//           side: BorderSide(color: AppColors.primary[60]!, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(AppRadius.lg),
//           ),
//         ),
//       ),
//
//       // ── TextButton ────────────────────────
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary[60],
//           textStyle: textTheme.bodyMedium,
//         ),
//       ),
//
//       // ── InputDecoration ───────────────────
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: colorScheme.surface,
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: AppSpacing.md.w,
//           vertical: AppSpacing.sm.h,
//         ),
//         hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textTertiary),
//         labelStyle: textTheme.bodyMedium,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.all(AppRadius.md),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.all(AppRadius.md),
//           borderSide: BorderSide(color: AppColors.border),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.all(AppRadius.md),
//           borderSide: BorderSide(color: AppColors.primary[60]!, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.all(AppRadius.md),
//           borderSide: BorderSide(color: AppColors.danger),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.all(AppRadius.md),
//           borderSide: const BorderSide(color: AppColors.danger, width: 2),
//         ),
//       ),
//
//       // ── Divider ───────────────────────────
//       dividerTheme: const DividerThemeData(
//         color: AppColors.borderLight,
//         thickness: 1,
//         space: 1,
//       ),
//
//       // ── BottomNavigationBar ───────────────
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: colorScheme.surface,
//         selectedItemColor: AppColors.primary[60],
//         unselectedItemColor: AppColors.textTertiary,
//         selectedLabelStyle: textTheme.bodySmall,
//         unselectedLabelStyle: textTheme.bodySmall,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//
//       // ── Chip ──────────────────────────────
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.bgTertiary,
//         labelStyle: textTheme.bodySmall,
//         side: const BorderSide(color: AppColors.border),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(AppRadius.pill),
//         ),
//       ),
//     );
//   }
//
//   // ─────────────────────────────────────────
//   // Light Theme  ← بيتبنى لما ScreenUtil يكون جاهز
//   // ─────────────────────────────────────────
//   static ThemeData lightTheme() => _buildTheme(
//     colorScheme: ColorScheme(
//       brightness: Brightness.light,
//       primary: AppColors.primary,         // fallback — بيتغير من primary[60] جوه
//       onPrimary: AppColors.white,
//       secondary: AppColors.secondary,
//       onSecondary: AppColors.white,
//       error: AppColors.danger,
//       onError: AppColors.white,
//       surface: AppColors.bgSecondary,
//       onSurface: AppColors.textPrimary,
//       outline: AppColors.border,
//     ).copyWith(
//       primary: AppColors.primary[60],
//       secondary: AppColors.secondary[60],
//       tertiary: AppColors.accent[60],
//       surfaceContainerHighest: AppColors.bgPrimary,
//     ),
//     textTheme: _buildTextTheme(
//       textPrimary: AppColors.textPrimary,
//       textSecondary: AppColors.textSecondary,
//       textTertiary: AppColors.textTertiary,
//     ),
//   );
//
//   // ─────────────────────────────────────────
//   // Dark Theme
//   // ─────────────────────────────────────────
//   static ThemeData darkTheme() => _buildTheme(
//     colorScheme: const ColorScheme(
//       brightness: Brightness.dark,
//       primary: AppColors.white,
//       onPrimary: AppColors.white,
//       secondary: AppColors.white,
//       onSecondary: AppColors.white,
//       error: AppColors.danger,
//       onError: AppColors.white,
//       surface: Color(0xFF1A1A2E),
//       onSurface: AppColors.white,
//       outline: Color(0xFF3A3A5C),
//     ).copyWith(
//       primary: AppColors.primary[50],
//       secondary: AppColors.secondary[50],
//       tertiary: AppColors.accent[50],
//       surfaceContainerHighest: const Color(0xFF16213E),
//     ),
//     textTheme: _buildTextTheme(
//       textPrimary: AppColors.white,
//       textSecondary: AppColors.textTertiary,
//       textTertiary: const Color(0xFF6B7280),
//     ),
//   );
// }
// // ── App Colors ────────────────────────────
// abstract class AppColors {
//   // ── Primary (Customer Orange) ──────────────────────────────
//   static MaterialColor primary = const MaterialColor(0xFFFF6B35, <int, Color>{
//     10: Color(0xFFFFF0EB),
//     20: Color(0xFFFFD6C7),
//     30: Color(0xFFFFB99D),
//     40: Color(0xFFFF9C73),
//     50: Color(0xFFFF7F49),
//     60: Color(0xFFFF6B35),
//     70: Color(0xFFE65520),
//     80: Color(0xFFB4431A),
//     90: Color(0xFF833212),
//     100: Color(0xFF4F1F09),
//   });
//
//   static MaterialColor secondary = const MaterialColor(0xFFF7931E, <int, Color>{
//     10: Color(0xFFFFF4E0),
//     20: Color(0xFFFFE1B3),
//     30: Color(0xFFFFCC80),
//     40: Color(0xFFFFB94D),
//     50: Color(0xFFFFA61A),
//     60: Color(0xFFF7931E),
//     70: Color(0xFFDA7A19),
//     80: Color(0xFFB35F13),
//     90: Color(0xFF894410),
//     100: Color(0xFF602C08),
//   });
//
//   // ── Accent (Handyman Teal) ─────────────────────────────────
//   static MaterialColor accent = const MaterialColor(0xFF4ECDC4, <int, Color>{
//     10: Color(0xFFE6F7F6),
//     20: Color(0xFFBFEAE8),
//     30: Color(0xFF99DDD9),
//     40: Color(0xFF73D0CB),
//     50: Color(0xFF4EC3BC),
//     60: Color(0xFF4ECDC4),
//     70: Color(0xFF44A3A0),
//     80: Color(0xFF357C7C),
//     90: Color(0xFF285656),
//     100: Color(0xFF1B3031),
//   });
//
//   // ── Backgrounds ────────────────────────────────────────────
//   static const Color bgPrimary   = Color(0xFFF5F7FA);
//   static const Color bgSecondary = Color(0xFFFFFFFF);
//   static const Color bgTertiary  = Color(0xFFE8ECF1);
//
//   // ── Text ───────────────────────────────────────────────────
//   static const Color textPrimary   = Color(0xFF2C3E50);
//   static const Color textSecondary = Color(0xFF7F8C8D);
//   static const Color textTertiary  = Color(0xFF95A5A6);
//   static const Color textInverse   = Color(0xFFFFFFFF);
//
//   // ── Borders ────────────────────────────────────────────────
//   static const Color border      = Color(0xFFDDE1E6);
//   static const Color borderLight = Color(0xFFE8ECF1);
//
//   // ── Semantic ───────────────────────────────────────────────
//   static const Color success = Color(0xFF27AE60);
//   static const Color warning = Color(0xFFF39C12);
//   static const Color danger  = Color(0xFFE74C3C);
//   static const Color info    = Color(0xFF3498DB);
//
//   // ── Rating ─────────────────────────────────────────────────
//   static const Color star = Color(0xFFFBBF24);
//
//   // ── Status Badges (Background / Text) ──────────────────────
//   static const Color pendingBg     = Color(0xFFFFF3CD);
//   static const Color pendingText   = Color(0xFF856404);
//   static const Color acceptedBg    = Color(0xFFD1ECF1);
//   static const Color acceptedText  = Color(0xFF0C5460);
//   static const Color activeBg      = Color(0xFFD4EDDA);
//   static const Color activeText    = Color(0xFF155724);
//   static const Color completedBg   = Color(0xFFD4EDDA);
//   static const Color completedText = Color(0xFF155724);
//   static const Color cancelledBg   = Color(0xFFF8D7DA);
//   static const Color cancelledText = Color(0xFF721C24);
//   static const Color busyBg        = Color(0xFFFFF3E0);
//   static const Color busyText      = Color(0xFFD97706);
//
//   // ── White (for buttons / labels) ───────────────────────────
//   static const Color white = Color(0xFFFFFFFF);
// }
// // ── App Gradients ────────────────────────────
// abstract class AppGradients {
//   // ── Primary CTA button gradient
//   static final primary = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       AppColors.primary[600]!,
//       AppColors.secondary[600]!,
//     ],
//   );
//
//   // ── Handyman teal gradient (profile headers, dashboard)
//   static final secondary = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       AppColors.accent[600]!,
//       AppColors.accent[700]!,
//     ],
//   );
//
//   // ── Page background gradient
//   static const background = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       AppColors.bgPrimary,
//       AppColors.bgTertiary,
//     ],
//   );
//
//   // ── Customer home hero header gradient
//   static final heroOrange = LinearGradient(
//     begin: Alignment.topRight,
//     end: Alignment.bottomLeft,
//     colors: [
//       AppColors.primary[600]!,
//       AppColors.primary[700]!,
//     ],
//   );
// }
// // ── App Shadows ────────────────────────────
// abstract class AppShadows {
//   /// Small shadow
//   static const List<BoxShadow> sm = [
//     BoxShadow(
//       color: Color(0x0F000000),
//       blurRadius: 4,
//       offset: Offset(0, 2),
//     ),
//   ];
//
//   /// Medium shadow
//   static const List<BoxShadow> md = [
//     BoxShadow(
//       color: Color(0x14000000),
//       blurRadius: 12,
//       offset: Offset(0, 4),
//     ),
//   ];
//
//   /// Large shadow
//   static const List<BoxShadow> lg = [
//     BoxShadow(
//       color: Color(0x1F000000),
//       blurRadius: 24,
//       offset: Offset(0, 8),
//     ),
//   ];
//
//   /// Primary glow (used on main CTA buttons)
//   static const List<BoxShadow> primary = [
//     BoxShadow(
//       color: Color(0x4DFF6B35),
//       blurRadius: 12,
//       offset: Offset(0, 4),
//     ),
//   ];
// }
