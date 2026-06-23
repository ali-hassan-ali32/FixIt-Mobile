import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Model
// ══════════════════════════════════════════════════════════════════════════════

class PortfolioItem {
  final String  id;
  final String  category;
  final String  date;
  final String  title;
  final String  description;
  final String? networkImageUrl; // for existing items from server
  final String? localImagePath;  // for newly picked items

  const PortfolioItem({
    required this.id,
    required this.category,
    required this.date,
    required this.title,
    required this.description,
    this.networkImageUrl,
    this.localImagePath,
  });

  bool get hasImage => networkImageUrl != null || localImagePath != null;
}

// ══════════════════════════════════════════════════════════════════════════════
// AppPortfolioFeedCard
//
// Usage (customer — read-only):
//   AppPortfolioFeedCard(item: item, accentColor: AppColors.primary[60]!)
//
// Usage (handyman — with delete):
//   AppPortfolioFeedCard(
//     item: item,
//     accentColor: AppColors.accent[60]!,
//     onDelete: () { ... },
//   )
// ══════════════════════════════════════════════════════════════════════════════
class AppPortfolioFeedCard extends StatefulWidget {
  final PortfolioItem item;
  final Color         accentColor;
  final VoidCallback? onDelete;

  const AppPortfolioFeedCard({
    super.key,
    required this.item,
    required this.accentColor,
    this.onDelete,
  });

  @override
  State<AppPortfolioFeedCard> createState() => _AppPortfolioFeedCardState();
}

class _AppPortfolioFeedCardState extends State<AppPortfolioFeedCard>
    with SingleTickerProviderStateMixin {
  // Scale press on card
  late final AnimationController _pressCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _pressScale = Tween<double>(begin: 1.0, end: 0.985)
      .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _openFullScreen(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => _FullScreenViewer(
          item: widget.item,
          heroTag: 'portfolio_img_${widget.item.id}',
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accent      = widget.accentColor;

    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final headerBg = isDark ? AppColors.darkBgSecondary : const Color(0xFFF8F9FA);

    return GestureDetector(
      onTapDown:   (_) => _pressCtrl.forward(),
      onTapUp:     (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.07),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: accent.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────
              Container(
                color: headerBg,
                padding: EdgeInsets.symmetric(
                    horizontal: 18.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Accent dot
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.category,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            widget.item.date,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete button (handyman only)
                    if (widget.onDelete != null)
                      _DeleteBtn(onTap: widget.onDelete!),
                  ],
                ),
              ),

              // ── Image ─────────────────────────────────────
              GestureDetector(
                onTap: widget.item.hasImage
                    ? () => _openFullScreen(context)
                    : null,
                child: Hero(
                  tag: 'portfolio_img_${widget.item.id}',
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: _PortfolioImage(
                        item: widget.item, accent: accent),
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 18.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.item.description,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _PortfolioImage
// ══════════════════════════════════════════════════════════════════════════════
class _PortfolioImage extends StatelessWidget {
  final PortfolioItem item;
  final Color         accent;

  const _PortfolioImage({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    // Local picked image
    if (item.localImagePath != null) {
      return Image.file(
        File(item.localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(accent),
      );
    }
    // Network image
    if (item.networkImageUrl != null) {
      return Image.network(
        item.networkImageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _shimmer(accent);
        },
        errorBuilder: (_, __, ___) => _placeholder(accent),
      );
    }
    return _placeholder(accent);
  }

  Widget _shimmer(Color accent) {
    return _ShimmerBox(baseColor: accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.18));
  }

  Widget _placeholder(Color accent) {
    return Container(
      color: accent.withOpacity(0.06),
      child: Center(
        child: Icon(Icons.image_outlined,
            size: 40.sp, color: accent.withOpacity(0.35)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _ShimmerBox — simple shimmer without external package
// ══════════════════════════════════════════════════════════════════════════════
class _ShimmerBox extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerBox(
      {required this.baseColor, required this.highlightColor});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0 + _ctrl.value * 3, 0),
            end: Alignment(1.0 + _ctrl.value * 3, 0),
            colors: [
              widget.baseColor,
              widget.highlightColor,
              widget.baseColor,
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _DeleteBtn
// ══════════════════════════════════════════════════════════════════════════════
class _DeleteBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _DeleteBtn({required this.onTap});

  @override
  State<_DeleteBtn> createState() => _DeleteBtnState();
}

class _DeleteBtnState extends State<_DeleteBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 100));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.88)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.forward(),
      onTapUp:     (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.delete_outline_rounded,
              size: 18.sp, color: AppColors.danger),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// _FullScreenViewer — hero-based fullscreen image viewer
// ══════════════════════════════════════════════════════════════════════════════
class _FullScreenViewer extends StatelessWidget {
  final PortfolioItem item;
  final String        heroTag;

  const _FullScreenViewer({required this.item, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              child: _buildImage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.localImagePath != null) {
      return Image.file(File(item.localImagePath!));
    }
    if (item.networkImageUrl != null) {
      return Image.network(item.networkImageUrl!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded,
              color: Colors.white54, size: 64));
    }
    return const Icon(Icons.image_outlined, color: Colors.white54, size: 64);
  }
}