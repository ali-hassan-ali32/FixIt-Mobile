import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';

// ══════════════════════════════════════════════════════════════
// Model
// ══════════════════════════════════════════════════════════════
class _Item {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final int yearsExp;
  final int hourlyRate;
  final bool isAvailable;
  final List<Color> avatarColors;

  const _Item({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.yearsExp,
    required this.hourlyRate,
    required this.isAvailable,
    required this.avatarColors,
  });
}

final _kItems = [
  _Item(
    id: '1',
    name: 'محمد علي',
    specialty: 'فني سباكة محترف',
    rating: 4.9,
    reviewCount: 128,
    yearsExp: 8,
    hourlyRate: 150,
    isAvailable: true,
    avatarColors: [AppColors.primary[60]!, AppColors.secondary[60]!],
  ),
  _Item(
    id: '2',
    name: 'أحمد حسن',
    specialty: 'فني سباكة خبير',
    rating: 5.0,
    reviewCount: 210,
    yearsExp: 10,
    hourlyRate: 180,
    isAvailable: true,
    avatarColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
  ),
  _Item(
    id: '3',
    name: 'خالد إبراهيم',
    specialty: 'متخصص سباكة',
    rating: 4.8,
    reviewCount: 95,
    yearsExp: 6,
    hourlyRate: 120,
    isAvailable: true,
    avatarColors: [const Color(0xFF11998e), const Color(0xFF38ef7d)],
  ),
  _Item(
    id: '4',
    name: 'عمر سعيد',
    specialty: 'فني سباكة',
    rating: 4.7,
    reviewCount: 80,
    yearsExp: 5,
    hourlyRate: 110,
    isAvailable: false,
    avatarColors: [const Color(0xFFe74c3c), const Color(0xFFc0392b)],
  ),
  _Item(
    id: '5',
    name: 'يوسف محمود',
    specialty: 'فني سباكة',
    rating: 4.6,
    reviewCount: 62,
    yearsExp: 4,
    hourlyRate: 100,
    isAvailable: true,
    avatarColors: [const Color(0xFF9b59b6), const Color(0xFF8e44ad)],
  ),
];

// ══════════════════════════════════════════════════════════════
// Layout router
// ══════════════════════════════════════════════════════════════
class CustomerCategorySearchResultsView extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CustomerCategorySearchResultsView({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => c.maxWidth >= 600
        ? _TabletBody(categoryId: categoryId, categoryName: categoryName)
        : _MobileBody(categoryId: categoryId, categoryName: categoryName),
  );
}

// ══════════════════════════════════════════════════════════════
// Shared state
// ══════════════════════════════════════════════════════════════
abstract class _Base<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get categoryId;
  String get categoryName;
  Color get accent => AppColors.primary[60]!;

  int sortIndex = 0;
  bool onlyAvailable = false;

  late final AnimationController entryCtrl;
  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;
  late final Animation<double> filterFade;
  late final Animation<Offset> filterSlide;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entryCtrl,
            curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
          ),
        );

    filterFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.18, 0.70, curve: Curves.easeOut),
      ),
    );
    filterSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: entryCtrl,
            curve: const Interval(0.18, 0.72, curve: Curves.easeOutCubic),
          ),
        );

    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }

  List<_Item> get items {
    var list = List<_Item>.from(_kItems);
    if (onlyAvailable) list = list.where((h) => h.isAvailable).toList();
    switch (sortIndex) {
      case 0:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 2:
        list.sort((a, b) => b.yearsExp.compareTo(a.yearsExp));
        break;
    }
    return list;
  }

  // ── Filter bar (mobile) ───────────────────────────────────
  Widget buildFilterBar(bool isDark, AppLocalizations l10n) {
    final sortLabels = [
      l10n.categoryFilterTopRated,
      l10n.categoryFilterNearest,
      l10n.categoryFilterMostExp,
    ];
    final areaLabels = [
      l10n.categoryFilterAllAreas,
      l10n.areaNasr,
      l10n.areaMaadi,
      l10n.areaZamalek,
      l10n.areaNewCairo,
      l10n.areaHeliopolis,
    ];

    return FadeTransition(
      opacity: filterFade,
      child: SlideTransition(
        position: filterSlide,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: AppSpacing.md.h,
          ),
          color: isDark ? AppColors.darkBgSecondary : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: _Dropdown(
                  isDark: isDark,
                  value: areaLabels[0],
                  items: areaLabels,
                  onChanged: (_) {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _Dropdown(
                  isDark: isDark,
                  value: sortLabels[sortIndex],
                  items: sortLabels,
                  onChanged: (v) =>
                      setState(() => sortIndex = sortLabels.indexOf(v!)),
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
// Mobile
// ══════════════════════════════════════════════════════════════
class _MobileBody extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const _MobileBody({required this.categoryId, required this.categoryName});
  @override
  State<_MobileBody> createState() => _MobileBodyState();
}

class _MobileBodyState extends _Base<_MobileBody> {
  @override
  String get categoryId => widget.categoryId;
  @override
  String get categoryName => widget.categoryName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final list = items;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            FadeTransition(
              opacity: headerFade,
              child: SlideTransition(
                position: headerSlide,
                child: AppPageHeader(
                  isDark: isDark,
                  accentColor: accent,
                  title: '${l10n.categoryResultsTitlePrefix} $categoryName',
                ),
              ),
            ),

            buildFilterBar(isDark, l10n),

            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.categoryEmptyTitle,
                        subtitle: l10n.categoryEmptySubtitle,
                        color: accent,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        AppSpacing.lg.h,
                        AppSpacing.xl.w,
                        MediaQuery.of(context).padding.bottom + 100.h,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _Card(
                        item: list[i],
                        index: i,
                        isDark: isDark,
                        l10n: l10n,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.customerViewHandyman,
                          arguments: list[i].id,
                        ),
                        onBook: () => Navigator.of(context).pushNamed(
                          AppRoutes.customerBookService,
                          arguments: list[i].id,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Tablet — sidebar (28%) | list (72%)
// ══════════════════════════════════════════════════════════════
class _TabletBody extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const _TabletBody({required this.categoryId, required this.categoryName});
  @override
  State<_TabletBody> createState() => _TabletBodyState();
}

class _TabletBodyState extends _Base<_TabletBody> {
  @override
  String get categoryId => widget.categoryId;
  @override
  String get categoryName => widget.categoryName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final list = items;

    final sortLabels = [
      l10n.categoryFilterTopRated,
      l10n.categoryFilterNearest,
      l10n.categoryFilterMostExp,
    ];
    final sortIcons = [
      Icons.star_rounded,
      Icons.location_on_rounded,
      Icons.workspace_premium_rounded,
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            FadeTransition(
              opacity: headerFade,
              child: SlideTransition(
                position: headerSlide,
                child: AppPageHeader(
                  isDark: isDark,
                  accentColor: accent,
                  title: '${l10n.categoryResultsTitlePrefix} $categoryName',
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // ── Sidebar ───────────────────────────────
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.28,
                    child: FadeTransition(
                      opacity: filterFade,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(-0.15, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: entryCtrl,
                                curve: const Interval(
                                  0.18,
                                  0.72,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: Container(
                          height: double.infinity,
                          color: isDark
                              ? AppColors.darkBgSecondary.withOpacity(0.60)
                              : Colors.white.withOpacity(0.70),
                          padding: EdgeInsets.all(18.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.categoryFilterTopRated,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 14.h),

                              // Sort tiles
                              ...List.generate(sortLabels.length, (i) {
                                final active = sortIndex == i;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => sortIndex = i);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 11.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? accent.withOpacity(0.10)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: active
                                            ? accent.withOpacity(0.28)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          sortIcons[i],
                                          size: 18.sp,
                                          color: active
                                              ? accent
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                        SizedBox(width: 10.w),
                                        Flexible(
                                          child: Text(
                                            sortLabels[i],
                                            style: GoogleFonts.cairo(
                                              fontSize: 13.sp,
                                              fontWeight: active
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: active
                                                  ? accent
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              SizedBox(height: 20.h),
                              Divider(color: accent.withOpacity(0.10)),
                              SizedBox(height: 16.h),

                              // Available only switch
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.searchAvailable,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Switch(
                                    value: onlyAvailable,
                                    activeThumbColor: accent,
                                    onChanged: (v) {
                                      HapticFeedback.selectionClick();
                                      setState(() => onlyAvailable = v);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                  // ── List ──────────────────────────────────
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: AppEmptyState(
                              icon: Icons.search_off_rounded,
                              title: l10n.categoryEmptyTitle,
                              subtitle: l10n.categoryEmptySubtitle,
                              color: accent,
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.xl.w,
                              AppSpacing.lg.h,
                              AppSpacing.xl.w,
                              32.h,
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, i) => _Card(
                              item: list[i],
                              index: i,
                              isDark: isDark,
                              l10n: l10n,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.customerViewHandyman,
                                arguments: list[i].id,
                              ),
                              onBook: () => Navigator.of(context).pushNamed(
                                AppRoutes.customerBookService,
                                arguments: list[i].id,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _Card — handyman result card
// Rules:
//   • Never use double.infinity width inside a Row
//   • Book button has explicit fixed width
//   • One AnimationController per card (entry slide + fade)
// ══════════════════════════════════════════════════════════════
class _Card extends StatefulWidget {
  final _Item item;
  final int index;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onBook;
  const _Card({
    required this.item,
    required this.index,
    required this.isDark,
    required this.l10n,
    required this.onTap,
    required this.onBook,
  });

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 65), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.item;
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = AppColors.primary[60]!;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: h.isAvailable
              ? (_) {
                  setState(() => _pressed = true);
                  HapticFeedback.selectionClick();
                }
              : null,
          onTapUp: h.isAvailable
              ? (_) {
                  setState(() => _pressed = false);
                  widget.onTap();
                }
              : null,
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 110),
            child: Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: accent.withOpacity(h.isAvailable ? 0.10 : 0.04),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      widget.isDark ? 0.18 : 0.05,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ─────────────────────────
                  Opacity(
                    opacity: h.isAvailable ? 1.0 : 0.55,
                    child: Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: h.avatarColors,
                        ),
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 26.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // ── Info ───────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Name + Badge (FIXED PROPERLY)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                h.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: h.isAvailable
                                      ? null
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                            _Badge(
                              isAvailable: h.isAvailable,
                              label: h.isAvailable
                                  ? widget.l10n.searchAvailable
                                  : widget.l10n.searchBusy,
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          h.specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Stars
                        AppRatingStars(
                          rating: h.rating,
                          starSize: 13,
                          showValue: true,
                        ),

                        SizedBox(height: 2.h),

                        Text(
                          '(${h.reviewCount} ${widget.l10n.handymanReviewsLabel})',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // ✅ Chips (FIXED overflow issue)
                        Wrap(
                          spacing: 12.w,
                          runSpacing: 6.h,
                          children: [
                            _Chip(
                              icon: Icons.work_outline_rounded,
                              label:
                                  '${h.yearsExp} ${widget.l10n.searchExpLabel}',
                            ),
                            _Chip(
                              icon: Icons.payments_outlined,
                              label:
                                  '${h.hourlyRate} ${widget.l10n.searchCurrency}/${widget.l10n.searchRateLabel}',
                            ),
                          ],
                        ),

                        // Book button
                        if (h.isAvailable) ...[
                          SizedBox(height: 10.h),
                          _BookBtn(
                            label: widget.l10n.searchBookBtn,
                            accent: accent,
                            onTap: widget.onBook,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Small private widgets
// ══════════════════════════════════════════════════════════════

// Book button — full width inside column (safe, no Row parent)
class _BookBtn extends StatefulWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  const _BookBtn({
    required this.label,
    required this.accent,
    required this.onTap,
  });
  @override
  State<_BookBtn> createState() => _BookBtnState();
}

class _BookBtnState extends State<_BookBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          // full width of the column — parent is Expanded → no infinite width
          width: double.infinity,
          height: 36.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.accent, AppColors.secondary[60]!],
            ),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.28),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final bool isAvailable;
  final String label;
  const _Badge({required this.isAvailable, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.accent[60]! : AppColors.danger;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 3.w),
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  final bool isDark;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
    required this.isDark,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.primary[60]!.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primary[60]!.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18.sp,
            color: AppColors.primary[60],
          ),
          dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
