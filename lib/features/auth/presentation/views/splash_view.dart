import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/di/di.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/functions/remeber_me.dart';
import '../../../../core/utils/widgets/animations/bouncing_dot.dart';
import '../../../../core/utils/widgets/animations/pulsing_text.dart';
import '../../../../core/utils/widgets/arabic_pattern_overlay.dart';

// ══════════════════════════════════════════════════════════════
// SplashView — layout router
// ══════════════════════════════════════════════════════════════
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const SplashTabletBody()
          : const SplashMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SplashState<T> — shared animation base, avoids all duplication
// ══════════════════════════════════════════════════════════════
abstract class _SplashState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _fadeCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _versionCtrl;
  late final AnimationController _dotsCtrl;

  // Animations
  late final Animation<double> fadePage;
  late final Animation<Offset> slidePage;
  late final Animation<double> logoScale;
  late final Animation<double> logoOpacity;
  late final Animation<double> glowIntensity;
  late final Animation<double> taglineOpacity;
  late final Animation<Offset> taglineSlide;
  late final Animation<double> versionOpacity;
  AnimationController get dotsCtrl => _dotsCtrl;
  Animation<double> get glow => glowIntensity;

  @override
  void initState() {
    super.initState();

    // Page
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fadePage = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    slidePage = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));

    // Logo — elastic pop
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    logoScale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Glow — infinite pulse
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    glowIntensity = Tween<double>(
      begin: 0.25,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // Tagline — slides up after logo
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    taglineOpacity = CurvedAnimation(
      parent: _taglineCtrl,
      curve: Curves.easeOut,
    );
    taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOutCubic),
        );

    // Version — last fade
    _versionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    versionOpacity = CurvedAnimation(
      parent: _versionCtrl,
      curve: Curves.easeOut,
    );

    // Dots — infinite bounce
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Sequence
    _fadeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _taglineCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 1050), () {
      if (mounted) _versionCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 2600), () async {
      final rememberMe = await getRememberMe();

      final token = await getIt<SecureStorageService>().getToken();

      final role = await getIt<SecureStorageService>().getRole();

      if (!mounted) return;

      if (rememberMe && token != null && token.isNotEmpty) {

        if (role == 'handyman') {
          Navigator.pushReplacementNamed(context, AppRoutes.handymanHome,);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.customerHome,);
        }

      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login,);
      }},
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _logoCtrl.dispose();
    _glowCtrl.dispose();
    _taglineCtrl.dispose();
    _versionCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  /// The background gradient — shared
  Widget buildBackground({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  AppColors.darkBgPrimary,
                  AppColors.darkBgSecondary,
                  AppColors.darkBgTertiary,
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
                colors: [
                  Color(0xFFFFF5F0),
                  Color(0xFFFFFFFF),
                  Color(0xFFF0F9FF),
                ],
              ),
      ),
      child: child,
    );
  }

  /// Logo + tagline + version — shared, accepts fontSize for mobile vs tablet
  Widget buildLogoSection(AppLocalizations l10n, double fontSize) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Elastic pop + glow pulse
        ScaleTransition(
          scale: logoScale,
          child: FadeTransition(
            opacity: logoOpacity,
            child: AnimatedBuilder(
              animation: glowIntensity,
              builder: (_, __) => _SizedGlowLogo(
                glowIntensity: glowIntensity.value,
                fontSize: fontSize,
              ),
            ),
          ),
        ),

        // Tagline slides up
        FadeTransition(
          opacity: taglineOpacity,
          child: SlideTransition(
            position: taglineSlide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 14.h),
                ShaderMask(
                  shaderCallback: (b) => LinearGradient(
                    colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                  ).createShader(b),
                  child: Text(
                    l10n.splashTagline,
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.splashSubtitle,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Version
        SizedBox(height: 6.h),
        FadeTransition(
          opacity: versionOpacity,
          child: Text(
            l10n.splashVersion,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  /// Bouncing dots + pulsing text — shared
  Widget buildLoadingSection(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BouncingDot(
              controller: _dotsCtrl,
              delayFraction: -0.32 / 1.4 + 1,
              gradient: LinearGradient(
                colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
              ),
            ),
            SizedBox(width: 12.w),
            BouncingDot(
              controller: _dotsCtrl,
              delayFraction: -0.16 / 1.4 + 1,
              gradient: LinearGradient(
                colors: [AppColors.secondary[60]!, AppColors.secondary[40]!],
              ),
            ),
            SizedBox(width: 12.w),
            BouncingDot(
              controller: _dotsCtrl,
              delayFraction: 0.0,
              gradient: LinearGradient(
                colors: [AppColors.accent[60]!, AppColors.accent[70]!],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        PulsingText(text: l10n.appLoading, style: textTheme.bodyLarge!),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SplashMobileBody
// ══════════════════════════════════════════════════════════════
class SplashMobileBody extends StatefulWidget {
  const SplashMobileBody({super.key});

  @override
  State<SplashMobileBody> createState() => _SplashMobileBodyState();
}

class _SplashMobileBodyState extends _SplashState<SplashMobileBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: buildBackground(
        child: FadeTransition(
          opacity: fadePage,
          child: SlideTransition(
            position: slidePage,
            child: Stack(
              children: [
                const ArabicPatternOverlay(),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        buildLogoSection(l10n, 100),
                        SizedBox(height: 60.h),
                        buildLoadingSection(l10n),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SplashTabletBody
// ══════════════════════════════════════════════════════════════
class SplashTabletBody extends StatefulWidget {
  const SplashTabletBody({super.key});

  @override
  State<SplashTabletBody> createState() => _SplashTabletBodyState();
}

class _SplashTabletBodyState extends _SplashState<SplashTabletBody> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: buildBackground(
        child: FadeTransition(
          opacity: fadePage,
          child: SlideTransition(
            position: slidePage,
            child: Stack(
              children: [
                const ArabicPatternOverlay(),
                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildLogoSection(l10n, 130), // larger on tablet
                          SizedBox(height: 80.h),
                          buildLoadingSection(l10n),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SizedGlowLogo — inline logo with configurable fontSize
// keeps GlowingLogoText widget untouched (no fontSize param on it)
// ══════════════════════════════════════════════════════════════
class _SizedGlowLogo extends StatelessWidget {
  final double glowIntensity;
  final double fontSize;

  const _SizedGlowLogo({required this.glowIntensity, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final blurRadius = 16 + (glowIntensity * 20);
    const gp = 40.0; // glow padding

    return Padding(
      padding: const EdgeInsets.all(gp),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow halo
          Positioned(
            top: -gp,
            bottom: -gp,
            left: -gp,
            right: -gp,
            child: Center(
              child: Text(
                'FixIt',
                style: GoogleFonts.cairo(
                  fontSize: fontSize.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  height: 1.0,
                  foreground: Paint()
                    ..color = Color.fromRGBO(255, 107, 53, glowIntensity)
                    ..maskFilter = MaskFilter.blur(
                      BlurStyle.normal,
                      blurRadius,
                    ),
                ),
              ),
            ),
          ),
          // Gradient text
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                AppColors.primary[60]!,
                AppColors.secondary[60]!,
                AppColors.accent[60]!,
              ],
            ).createShader(b),
            blendMode: BlendMode.srcIn,
            child: Text(
              'FixIt',
              style: GoogleFonts.cairo(
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -2,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
