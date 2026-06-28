import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/animations/animated_confirm_dialog.dart';
import '../../../../core/utils/widgets/cards/app_portfolio_feed_card.dart';
import '../../../../core/utils/widgets/buttons/app_back_button.dart';
import '../../data/models/requests/add_portfolio_request.dart';
import '../../domain/entities/handyman_portfolio_entity.dart';
import '../cubit/handyman_cubit.dart';
import '../cubit/handyman_state.dart';

// ══════════════════════════════════════════════════════════════
// Helper — convert entity → UI model
// ══════════════════════════════════════════════════════════════
PortfolioItem _toUiItem(HandymanPortfolioEntity e) => PortfolioItem(
      id: e.id,
      category: e.title ?? '',
      date: '',
      title: e.title ?? '',
      description: e.description ?? '',
      networkImageUrl: e.imageUrl.isNotEmpty ? e.imageUrl : null,
    );

// ══════════════════════════════════════════════════════════════
// HandymanManagePortfolioView — layout router
// ══════════════════════════════════════════════════════════════
class HandymanManagePortfolioView extends StatelessWidget {
  const HandymanManagePortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => constraints.maxWidth >= 600
          ? const _PortfolioTabletBody()
          : const _PortfolioMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base class
// ══════════════════════════════════════════════════════════════
abstract class _PortfolioBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get accent => AppColors.accent[60]!;

  final listKey = GlobalKey<AnimatedListState>();
  final items = <PortfolioItem>[];

  static const int maxItems = 10;

  // Entry animations
  late final AnimationController entryCtrl;
  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> uploadFade;
  late final Animation<Offset> uploadSlide;
  late final Animation<double> countFade;

  // Add button pulse
  late final AnimationController pulseCtrl;
  late final Animation<double> pulseAnim;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    headerFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entryCtrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
          ),
        );

    uploadFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
    );
    uploadSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entryCtrl,
            curve: const Interval(0.15, 0.50, curve: Curves.easeOutCubic),
          ),
        );

    countFade = CurvedAnimation(
      parent: entryCtrl,
      curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
    );

    // Pulse on add button
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut));

    // Load portfolio from API
    Future.microtask(() {
      if (mounted) context.read<HandymanCubit>().getPortfolio();
    });
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    pulseCtrl.dispose();
    super.dispose();
  }

  // ── Load portfolio items from state ──────────────────────
  void loadPortfolioItems(List<HandymanPortfolioEntity> entities) {
    setState(() {
      items
        ..clear()
        ..addAll(entities.map(_toUiItem));
      _isLoading = false;
    });
  }

  // ── Add item ─────────────────────────────────────────────
  void showAddSheet() {
    if (items.length >= maxItems) {
      HapticFeedback.mediumImpact();
      showMaxReachedSnack();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<HandymanCubit>(),
        child: _AddPortfolioSheet(
          accentColor: accent,
          onAdd: _onAddFromApi,
        ),
      ),
    );
  }

  /// Called by the sheet after API succeeds — refresh from server
  void _onAddFromApi() {
    context.read<HandymanCubit>().getPortfolio();
  }

  /// Optimistic local insert (used while waiting for refresh)
  void addItemLocally(PortfolioItem item) {
    HapticFeedback.mediumImpact();
    setState(() => items.insert(0, item));
    listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 400),
    );
  }

  // ── Delete item ───────────────────────────────────────────
  void confirmDelete(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showAnimatedConfirmDialog(
      context: context,
      isDark: isDark,
      icon: Icons.delete_outline_rounded,
      title: l10n.portfolioDeleteTitle,
      message: l10n.portfolioDeleteConfirm,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.portfolioDeleteBtn,
      isDanger: true,
      onConfirm: () => deleteItem(index),
    );
  }

  void deleteItem(int index) {
    HapticFeedback.mediumImpact();
    final removed = items[index];

    // Call API
    context.read<HandymanCubit>().deletePortfolio(removed.id);

    // Optimistic remove from list
    setState(() => items.removeAt(index));
    listKey.currentState?.removeItem(
      index,
      (ctx, anim) => SizeTransition(
        sizeFactor: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
        child: FadeTransition(
          opacity: anim,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: AppPortfolioFeedCard(item: removed, accentColor: accent),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 320),
    );
    Navigator.pop(context);
  }

  void showMaxReachedSnack() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.portfolioMaxReached,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  // ── Build header ───────────────────────────────────────────
  Widget buildHeader(bool isDark, AppLocalizations l10n, TextTheme textTheme) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg.w,
        top + AppSpacing.md.h,
        AppSpacing.lg.w,
        AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white.withOpacity(0.95),
        border: Border(bottom: BorderSide(color: accent.withOpacity(0.10))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AppBackButton(isDark: isDark, tapColor: accent),
          SizedBox(width: 14.w),
          Text(
            l10n.portfolioTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ── Build upload card ──────────────────────────────────────
  Widget buildUploadCard(
    bool isDark,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    return _UploadCard(
      accent: accent,
      isDark: isDark,
      count: items.length,
      max: maxItems,
      pulseAnim: pulseAnim,
      onTap: showAddSheet,
      l10n: l10n,
      textTheme: textTheme,
    );
  }

  // ── Build count row ────────────────────────────────────────
  Widget buildCountRow(AppLocalizations l10n, TextTheme textTheme) {
    return _CountRow(
      label: l10n.portfolioLatestProjects,
      count: items.length,
      accent: accent,
      textTheme: textTheme,
    );
  }

  // ── Build portfolio card with delete ───────────────────────
  Widget buildPortfolioCard(int index, int animIndex) {
    return AppPortfolioFeedCard(
      item: items[index],
      accentColor: accent,
      onDelete: () => confirmDelete(index),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile Body
// ══════════════════════════════════════════════════════════════
class _PortfolioMobileBody extends StatefulWidget {
  const _PortfolioMobileBody();
  @override
  State<_PortfolioMobileBody> createState() => _PortfolioMobileBodyState();
}

class _PortfolioMobileBodyState extends _PortfolioBase<_PortfolioMobileBody> {
  static const int _maxStagger = 10;
  static const double _gap = 0.07;

  late final List<Animation<double>> cardFade;
  late final List<Animation<Offset>> cardSlide;

  @override
  void initState() {
    super.initState();

    cardFade = List.generate(_maxStagger, (i) {
      final s = (0.25 + i * _gap).clamp(0.0, 0.9);
      return CurvedAnimation(
        parent: entryCtrl,
        curve: Interval(s, (s + 0.3).clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    cardSlide = List.generate(_maxStagger, (i) {
      final s = (0.25 + i * _gap).clamp(0.0, 0.9);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<HandymanCubit, HandymanState>(
      listener: (context, state) {
        state.whenOrNull(
          portfolioLoaded: (portfolio) {
            loadPortfolioItems(portfolio);
          },
          message: (msg) {
            // After add or delete succeeds, refresh
            context.read<HandymanCubit>().getPortfolio();
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(msg, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.danger,
            ));
          },
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: headerFade,
                child: SlideTransition(
                  position: headerSlide,
                  child: buildHeader(isDark, l10n, textTheme),
                ),
              ),

              // List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: accent))
                    : AnimatedList(
                        key: listKey,
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl.w,
                          AppSpacing.lg.h,
                          AppSpacing.xl.w,
                          40.h,
                        ),
                        initialItemCount:
                            items.length + 2, // +2: upload card + count row
                        itemBuilder: (ctx, index, anim) {
                          // Upload card
                          if (index == 0) {
                            return FadeTransition(
                              opacity: uploadFade,
                              child: SlideTransition(
                                position: uploadSlide,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  child: buildUploadCard(isDark, l10n, textTheme),
                                ),
                              ),
                            );
                          }
                          // Count row
                          if (index == 1) {
                            return FadeTransition(
                              opacity: countFade,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: buildCountRow(l10n, textTheme),
                              ),
                            );
                          }

                          final i = index - 2;
                          if (i >= items.length) return const SizedBox.shrink();

                          final ai = i.clamp(0, _maxStagger - 1);
                          return SizeTransition(
                            sizeFactor: CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            ),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: anim,
                                curve: Curves.easeOut,
                              ),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: anim,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 20.h),
                                  child: FadeTransition(
                                    opacity: cardFade[ai],
                                    child: SlideTransition(
                                      position: cardSlide[ai],
                                      child: buildPortfolioCard(i, ai),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet Body — two-column masonry grid
// ══════════════════════════════════════════════════════════════
class _PortfolioTabletBody extends StatefulWidget {
  const _PortfolioTabletBody();
  @override
  State<_PortfolioTabletBody> createState() => _PortfolioTabletBodyState();
}

class _PortfolioTabletBodyState extends _PortfolioBase<_PortfolioTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // Split into two columns
    final left = items
        .asMap()
        .entries
        .where((e) => e.key.isEven)
        .map((e) => e.value)
        .toList();
    final right = items
        .asMap()
        .entries
        .where((e) => e.key.isOdd)
        .map((e) => e.value)
        .toList();

    return BlocListener<HandymanCubit, HandymanState>(
      listener: (context, state) {
        state.whenOrNull(
          portfolioLoaded: (portfolio) {
            loadPortfolioItems(portfolio);
          },
          message: (msg) {
            context.read<HandymanCubit>().getPortfolio();
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(msg, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.danger,
            ));
          },
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppMainBackground(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: headerFade,
                child: SlideTransition(
                  position: headerSlide,
                  child: buildHeader(isDark, l10n, textTheme),
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: accent))
                    : FadeTransition(
                        opacity: uploadFade,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(AppSpacing.xl.w),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column
                                  Expanded(
                                    flex: 58,
                                    child: Column(
                                      children: [
                                        // Upload card
                                        buildUploadCard(isDark, l10n, textTheme),
                                        SizedBox(height: 20.h),

                                        // Count row
                                        buildCountRow(l10n, textTheme),
                                        SizedBox(height: 16.h),

                                        // Portfolio items - left column
                                        ...left.asMap().entries.map(
                                          (e) => Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 20.h),
                                            child: _TabletPortfolioCard(
                                              item: e.value,
                                              index: e.key * 2,
                                              accent: accent,
                                              onDelete: () =>
                                                  confirmDelete(e.key * 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24.w),

                                  // Right column - stats + items
                                  Expanded(
                                    flex: 42,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Stats card
                                        _TabletStatsCard(
                                          accent: accent,
                                          isDark: isDark,
                                          l10n: l10n,
                                          textTheme: textTheme,
                                          count: items.length,
                                          maxItems: _PortfolioBase.maxItems,
                                        ),
                                        SizedBox(height: 20.h),

                                        // Portfolio items - right column
                                        ...right.asMap().entries.map(
                                          (e) => Padding(
                                            padding: EdgeInsets.only(
                                                bottom: 20.h),
                                            child: _TabletPortfolioCard(
                                              item: e.value,
                                              index: e.key * 2 + 1,
                                              accent: accent,
                                              onDelete: () => confirmDelete(
                                                  e.key * 2 + 1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _CountRow
// ══════════════════════════════════════════════════════════════
class _CountRow extends StatelessWidget {
  final String label;
  final int count;
  final Color accent;
  final TextTheme textTheme;

  const _CountRow({
    required this.label,
    required this.count,
    required this.accent,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(width: 8.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Container(
            key: ValueKey(count),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _UploadCard
// ══════════════════════════════════════════════════════════════
class _UploadCard extends StatefulWidget {
  final Color accent;
  final bool isDark;
  final int count;
  final int max;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final TextTheme textTheme;

  const _UploadCard({
    required this.accent,
    required this.isDark,
    required this.count,
    required this.max,
    required this.pulseAnim,
    required this.onTap,
    required this.l10n,
    required this.textTheme,
  });

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _pressScale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reachedMax = widget.count >= widget.max;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: reachedMax
                  ? AppColors.warning.withOpacity(0.4)
                  : widget.accent.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Button
              AnimatedBuilder(
                animation: widget.pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: reachedMax ? 1.0 : widget.pulseAnim.value,
                  child: child,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    gradient: reachedMax
                        ? LinearGradient(
                            colors: [
                              AppColors.warning.withOpacity(0.6),
                              AppColors.warning.withOpacity(0.4),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              widget.accent,
                              widget.accent.withOpacity(0.82),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: reachedMax
                        ? []
                        : [
                            BoxShadow(
                              color: widget.accent.withOpacity(0.30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        reachedMax
                            ? Icons.block_rounded
                            : Icons.add_photo_alternate_rounded,
                        size: 22.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        reachedMax
                            ? widget.l10n.portfolioMaxReached
                            : widget.l10n.portfolioAddBtn,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              // Note + progress
              Row(
                children: [
                  Text(
                    widget.l10n.portfolioUploadNote,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.count}/${widget.max}',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: reachedMax ? AppColors.warning : widget.accent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: widget.count / widget.max,
                  backgroundColor: widget.accent.withOpacity(0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    reachedMax ? AppColors.warning : widget.accent,
                  ),
                  minHeight: 5.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TabletPortfolioCard — card with stagger entry animation
// ══════════════════════════════════════════════════════════════
class _TabletPortfolioCard extends StatefulWidget {
  final PortfolioItem item;
  final int index;
  final Color accent;
  final VoidCallback onDelete;

  const _TabletPortfolioCard({
    required this.item,
    required this.index,
    required this.accent,
    required this.onDelete,
  });

  @override
  State<_TabletPortfolioCard> createState() => _TabletPortfolioCardState();
}

class _TabletPortfolioCardState extends State<_TabletPortfolioCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 70),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AppPortfolioFeedCard(
          item: widget.item,
          accentColor: widget.accent,
          onDelete: widget.onDelete,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TabletStatsCard — stats panel for tablet
// ══════════════════════════════════════════════════════════════
class _TabletStatsCard extends StatelessWidget {
  final Color accent;
  final bool isDark;
  final AppLocalizations l10n;
  final TextTheme textTheme;
  final int count;
  final int maxItems;

  const _TabletStatsCard({
    required this.accent,
    required this.isDark,
    required this.l10n,
    required this.textTheme,
    required this.count,
    required this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = count / maxItems;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withOpacity(0.15),
                      accent.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.work_history_rounded,
                  color: accent,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.portfolioStatsTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.portfolioStatsSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Progress circle
          Center(
            child: SizedBox(
              width: 100.w,
              height: 100.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: accent.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$count',
                        style: GoogleFonts.cairo(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      Text(
                        l10n.portfolioProjects,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: l10n.portfolioRemaining,
                  value: '${maxItems - count}',
                  icon: Icons.hourglass_empty_rounded,
                  accent: accent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatItem(
                  label: l10n.portfolioMax,
                  value: '$maxItems',
                  icon: Icons.inventory_2_outlined,
                  accent: accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Tip
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: accent.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18.sp,
                  color: accent,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    l10n.portfolioTip,
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _StatItem
// ══════════════════════════════════════════════════════════════
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: accent),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AddPortfolioSheet — bottom sheet form (calls API via cubit)
// ══════════════════════════════════════════════════════════════
class _AddPortfolioSheet extends StatefulWidget {
  final Color accentColor;
  final VoidCallback onAdd; // called after API success → triggers refresh

  const _AddPortfolioSheet({required this.accentColor, required this.onAdd});

  @override
  State<_AddPortfolioSheet> createState() => _AddPortfolioSheetState();
}

class _AddPortfolioSheetState extends State<_AddPortfolioSheet>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _category;
  String? _imagePath; // local path picked from gallery
  bool _submitting = false;

  final _picker = ImagePicker();

  late final AnimationController _entryCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _entryCtrl,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _slide = Tween<double>(
    begin: 40.0,
    end: 0.0,
  ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _imagePath = file.path);
  }

  bool get _canSubmit =>
      _imagePath != null &&
      _titleCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    HapticFeedback.mediumImpact();

    // Call the API
    await context.read<HandymanCubit>().addPortfolio(
          AddPortfolioRequest(
            imageUrl: _imagePath!,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          ),
        );

    if (mounted) {
      Navigator.of(context).pop();
      widget.onAdd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accent = widget.accentColor;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).padding.bottom;

    final categories = [
      l10n.catPlumbing,
      l10n.catElectric,
      l10n.catCarpentry,
      l10n.catPainting,
      l10n.catAC,
    ];

    final sheetBg = isDark ? AppColors.darkSurface : Colors.white;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 32,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // Title
              Text(
                l10n.portfolioAddSheetTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 20.h),

              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: _imagePath != null
                        ? Colors.transparent
                        : accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: _imagePath != null
                          ? accent
                          : accent.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: _imagePath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                size: 40.sp,
                                color: accent.withOpacity(0.4),
                              ),
                            ),
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 36.sp,
                              color: accent,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              l10n.portfolioPickImage,
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),

              // Category
              Text(
                l10n.settingsSpecialty,
                style:
                    textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 7.h),
              DropdownButtonFormField<String>(
                initialValue: _category,
                hint: Text(
                  l10n.bookingServiceTypeHint,
                  style: GoogleFonts.cairo(fontSize: 14.sp),
                ),
                dropdownColor: sheetBg,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.darkBgPrimary : Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: accent.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: accent.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                ),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
              ),
              SizedBox(height: 14.h),

              // Title field
              _SheetField(
                ctrl: _titleCtrl,
                label: l10n.portfolioItemTitle,
                hint: l10n.portfolioItemTitleHint,
                accent: accent,
                isDark: isDark,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 14.h),

              // Description field
              _SheetField(
                ctrl: _descCtrl,
                label: l10n.portfolioItemDesc,
                hint: l10n.portfolioItemDescHint,
                accent: accent,
                isDark: isDark,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 24.h),

              // Submit button
              _SubmitBtn(
                label: l10n.portfolioAddBtnConfirm,
                accent: accent,
                enabled: _canSubmit,
                isLoading: _submitting,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SheetField
// ══════════════════════════════════════════════════════════════
class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final Color accent;
  final bool isDark;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.accent,
    required this.isDark,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          onChanged: onChanged,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: isDark ? AppColors.darkBgPrimary : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: accent.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: accent.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _SubmitBtn
// ══════════════════════════════════════════════════════════════
class _SubmitBtn extends StatefulWidget {
  final String label;
  final Color accent;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _SubmitBtn({
    required this.label,
    required this.accent,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.97,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled && !widget.isLoading
          ? (_) => _ctrl.forward()
          : null,
      onTapUp: widget.enabled && !widget.isLoading
          ? (_) {
              _ctrl.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          height: 52.h,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? LinearGradient(
                    colors: [widget.accent, widget.accent.withOpacity(0.82)],
                  )
                : null,
            color: widget.enabled ? null : AppColors.border,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    widget.label,
                    style: GoogleFonts.cairo(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.enabled ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
