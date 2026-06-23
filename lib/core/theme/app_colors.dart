import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Primary (Customer Orange) ──────────────────────────────
  static MaterialColor primary = const MaterialColor(0xFFFF6B35, <int, Color>{
    10: Color(0xFFFFF0EB),
    20: Color(0xFFFFD6C7),
    30: Color(0xFFFFB99D),
    40: Color(0xFFFF9C73),
    50: Color(0xFFFF7F49),
    60: Color(0xFFFF6B35),
    70: Color(0xFFE65520),
    80: Color(0xFFB4431A),
    90: Color(0xFF833212),
    100: Color(0xFF4F1F09),
  });

  static MaterialColor secondary = const MaterialColor(0xFFF7931E, <int, Color>{
    10: Color(0xFFFFF4E0),
    20: Color(0xFFFFE1B3),
    30: Color(0xFFFFCC80),
    40: Color(0xFFFFB94D),
    50: Color(0xFFFFA61A),
    60: Color(0xFFF7931E),
    70: Color(0xFFDA7A19),
    80: Color(0xFFB35F13),
    90: Color(0xFF894410),
    100: Color(0xFF602C08),
  });

  // ── Accent (Handyman Teal) ─────────────────────────────────
  static MaterialColor accent = const MaterialColor(0xFF4ECDC4, <int, Color>{
    10: Color(0xFFE6F7F6),
    20: Color(0xFFBFEAE8),
    30: Color(0xFF99DDD9),
    40: Color(0xFF73D0CB),
    50: Color(0xFF4EC3BC),
    60: Color(0xFF4ECDC4),
    70: Color(0xFF44A3A0),
    80: Color(0xFF357C7C),
    90: Color(0xFF285656),
    100: Color(0xFF1B3031),
  });


  // ── Neutral ───────────────────────────────────────────────
  static MaterialColor neutral = const MaterialColor(0xFF9E9E9E, <int, Color>{
    10: Color(0xFFF5F5F5),
    20: Color(0xFFEEEEEE),
    30: Color(0xFFE0E0E0),
    40: Color(0xFFBDBDBD),
    50: Color(0xFF9E9E9E),
    60: Color(0xFF757575),
    70: Color(0xFF616161),
    80: Color(0xFF424242),
    90: Color(0xFF303030),
    100: Color(0xFF212121),
  });

  // ════════════════════════════════════════
  // LIGHT THEME
  // ════════════════════════════════════════

  // ── Backgrounds ────────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFFF5F7FA);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary  = Color(0xFFE8ECF1);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textTertiary  = Color(0xFF95A5A6);
  static const Color textInverse   = Color(0xFFFFFFFF);

  // ── Borders ────────────────────────────────────────────────
  static const Color border      = Color(0xFFDDE1E6);
  static const Color borderLight = Color(0xFFE8ECF1);

  // ── Status Badges Light (Background / Text) ────────────────
  static const Color pendingBg     = Color(0xFFFFF3CD);
  static const Color pendingText   = Color(0xFF856404);
  static const Color acceptedBg    = Color(0xFFD1ECF1);
  static const Color acceptedText  = Color(0xFF0C5460);
  static const Color activeBg      = Color(0xFFD4EDDA);
  static const Color activeText    = Color(0xFF155724);
  static const Color completedBg   = Color(0xFFD4EDDA);
  static const Color completedText = Color(0xFF155724);
  static const Color cancelledBg   = Color(0xFFF8D7DA);
  static const Color cancelledText = Color(0xFF721C24);
  static const Color busyBg        = Color(0xFFFFF3E0);
  static const Color busyText      = Color(0xFFD97706);

  // ════════════════════════════════════════
  // DARK THEME
  // ════════════════════════════════════════

  // ── Dark Backgrounds ───────────────────────────────────────
  // Layer system: surface → card → elevated
  static const Color darkBgPrimary   = Color(0xFF0F1117); // أعمق خلفية
  static const Color darkBgSecondary = Color(0xFF1A1A2E); // surface الأساسي
  static const Color darkBgTertiary  = Color(0xFF16213E); // cards / elevated

  // ── Dark Elevated Surfaces ─────────────────────────────────
  static const Color darkSurface        = Color(0xFF1E2235); // modals / sheets
  static const Color darkSurfaceHighest = Color(0xFF252840); // top layer

  // ── Dark Text ──────────────────────────────────────────────
  static const Color darkTextPrimary   = Color(0xFFF0F4F8); // أبيض مايل للأزرق
  static const Color darkTextSecondary = Color(0xFFB0B8C4); // رمادي فاتح
  static const Color darkTextTertiary  = Color(0xFF6B7280); // رمادي داكن
  static const Color darkTextInverse   = Color(0xFF1A1A2E); // للـ buttons الفاتحة

  // ── Dark Borders ───────────────────────────────────────────
  static const Color darkBorder      = Color(0xFF2E3450); // border عادي
  static const Color darkBorderLight = Color(0xFF252840); // border خفيف

  // ── Dark Status Badges (أكثر شفافية عشان الخلفية داكنة) ───
  static const Color darkPendingBg     = Color(0xFF2C2510);
  static const Color darkPendingText   = Color(0xFFFFD166);
  static const Color darkAcceptedBg    = Color(0xFF0D2233);
  static const Color darkAcceptedText  = Color(0xFF7ECFEA);
  static const Color darkActiveBg      = Color(0xFF0D2A1A);
  static const Color darkActiveText    = Color(0xFF6FCF97);
  static const Color darkCompletedBg   = Color(0xFF0D2A1A);
  static const Color darkCompletedText = Color(0xFF6FCF97);
  static const Color darkCancelledBg   = Color(0xFF2A0D0F);
  static const Color darkCancelledText = Color(0xFFEB5757);
  static const Color darkBusyBg        = Color(0xFF2A1A08);
  static const Color darkBusyText      = Color(0xFFFFA940);

  // ════════════════════════════════════════
  // SHARED (light + dark)
  // ════════════════════════════════════════

  // ── Semantic ───────────────────────────────────────────────
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color danger  = Color(0xFFE74C3C);
  static const Color info    = Color(0xFF3498DB);

  // ── Dark Semantic (أوضح على الخلفية الداكنة) ───────────────
  static const Color darkSuccess = Color(0xFF6FCF97);
  static const Color darkWarning = Color(0xFFFFD166);
  static const Color darkDanger  = Color(0xFFEB5757);
  static const Color darkInfo    = Color(0xFF56CCF2);

  // ── Rating ─────────────────────────────────────────────────
  static const Color star = Color(0xFFFBBF24); // نفسه في light + dark

  // ── White ──────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}