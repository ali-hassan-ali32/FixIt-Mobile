import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_page_header.dart';

// ── Model ─────────────────────────────────────────────────────
class PortfolioItem {
  final String category;
  final String date;
  final String title;
  final String description;
  final String? imageUrl;

  const PortfolioItem({
    required this.category,
    required this.date,
    required this.title,
    required this.description,
    this.imageUrl,
  });
}

final _kPortfolio = [
  const PortfolioItem(
    category: 'تركيب سخان غاز',
    date: '12 فبراير 2024',
    title: 'تم تركيب سخان 50 لتر بنجاح',
    description:
        'تم فك السخان القديم وتركيب سخان جديد مع تغيير المحابس والوصلات لضمان عدم وجود أي تسريب.',
  ),
  const PortfolioItem(
    category: 'صيانة سباكة الحمام',
    date: '10 فبراير 2024',
    title: 'تجديد سباكة الحمام بالكامل',
    description:
        'تغيير جميع مواسير الصرف والتغذية واختبار الضغط للتأكد من سلامة التوصيلات.',
  ),
  const PortfolioItem(
    category: 'كشف وإصلاح تسريب',
    date: '05 فبراير 2024',
    title: 'حل مشكلة تسريب المطبخ',
    description:
        'تم اكتشاف مكان التسريب بدقة باستخدام الأجهزة الحديثة وإصلاحه بدون تكسير الحائط.',
  ),
  const PortfolioItem(
    category: 'تركيب خلاط مياه',
    date: '20 يناير 2024',
    title: 'تركيب خلاط حوض حديث',
    description:
        'تم تركيب خلاط مياه إيطالي عالي الجودة مع تغيير الليات والمحابس.',
  ),
  const PortfolioItem(
    category: 'تركيب فلتر مياه',
    date: '15 يناير 2024',
    title: 'تركيب فلتر 7 مراحل',
    description: 'تركيب فلتر تنقية مياه كامل تحت الحوض مع توصيلات احترافية.',
  ),
];

// ══════════════════════════════════════════════════════════════
// CustomerViewHandymanPortfolioView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerViewHandymanPortfolioView extends StatelessWidget {
  final String handymanId;
  const CustomerViewHandymanPortfolioView({
    super.key,
    required this.handymanId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _PortfolioTabletBody(handymanId: handymanId)
          : _PortfolioMobileBody(handymanId: handymanId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _PortfolioBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String get handymanId;
  Color get accent => AppColors.primary[60]!;

  final List<PortfolioItem> items = _kPortfolio;

  late final AnimationController entryCtrl;
  late final Animation<double> entryFade;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    entryFade = CurvedAnimation(parent: entryCtrl, curve: Curves.easeOut);
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile — vertical feed
// ══════════════════════════════════════════════════════════════
class _PortfolioMobileBody extends StatefulWidget {
  final String handymanId;
  const _PortfolioMobileBody({required this.handymanId});

  @override
  State<_PortfolioMobileBody> createState() => _PortfolioMobileBodyState();
}

class _PortfolioMobileBodyState extends _PortfolioBase<_PortfolioMobileBody> {
  @override
  String get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.portfolioTitle,
            ),
            Expanded(
              child: FadeTransition(
                opacity: entryFade,
                child: items.isEmpty
                    ? Center(
                        child: AppEmptyState(
                          icon: Icons.photo_library_outlined,
                          title: l10n.portfolioEmptyTitle,
                          subtitle: l10n.portfolioEmptySubtitle,
                          color: accent,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl.w,
                          AppSpacing.xl.h,
                          AppSpacing.xl.w,
                          MediaQuery.of(context).padding.bottom + 32.h,
                        ),
                        itemCount: items.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Text(
                                '${l10n.portfolioLatestProjects} (${items.length})',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          }
                          return _PortfolioCard(
                            item: items[i - 1],
                            index: i - 1,
                            isDark: isDark,
                            textTheme: textTheme,
                          );
                        },
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
// Tablet — 2-column masonry-style grid
// ══════════════════════════════════════════════════════════════
class _PortfolioTabletBody extends StatefulWidget {
  final String handymanId;
  const _PortfolioTabletBody({required this.handymanId});

  @override
  State<_PortfolioTabletBody> createState() => _PortfolioTabletBodyState();
}

class _PortfolioTabletBodyState extends _PortfolioBase<_PortfolioTabletBody> {
  @override
  String get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.portfolioTitle,
            ),
            Expanded(
              child: FadeTransition(
                opacity: entryFade,
                child: items.isEmpty
                    ? Center(
                        child: AppEmptyState(
                          icon: Icons.photo_library_outlined,
                          title: l10n.portfolioEmptyTitle,
                          subtitle: l10n.portfolioEmptySubtitle,
                          color: accent,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(AppSpacing.xl.w),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  '${l10n.portfolioLatestProjects} (${items.length})',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: left
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => _PortfolioCard(
                                            item: e.value,
                                            index: e.key * 2,
                                            isDark: isDark,
                                            textTheme: textTheme,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    children: right
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => _PortfolioCard(
                                            item: e.value,
                                            index: e.key * 2 + 1,
                                            isDark: isDark,
                                            textTheme: textTheme,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
// _PortfolioCard — social-feed style with stagger entry
// ══════════════════════════════════════════════════════════════
class _PortfolioCard extends StatefulWidget {
  final PortfolioItem item;
  final int index;
  final bool isDark;
  final TextTheme textTheme;
  const _PortfolioCard({
    required this.item,
    required this.index,
    required this.isDark,
    required this.textTheme,
  });

  @override
  State<_PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<_PortfolioCard>
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
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Container(
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.withOpacity(0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isDark ? 0.20 : 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 14.h,
                  ),
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.withOpacity(0.04),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary[60]!.withOpacity(0.15),
                              AppColors.secondary[60]!.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.build_rounded,
                          size: 18.sp,
                          color: AppColors.primary[60],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.category,
                              style: widget.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              widget.item.date,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Image placeholder / network
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: widget.item.imageUrl != null
                      ? Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder(),
                          loadingBuilder: (_, child, p) =>
                              p == null ? child : _imgLoading(),
                        )
                      : _imgPlaceholder(),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: widget.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        widget.item.description,
                        style: widget.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: widget.isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.grey.withOpacity(0.07),
    child: Center(
      child: Icon(
        Icons.image_outlined,
        size: 48.sp,
        color: Colors.grey.withOpacity(0.40),
      ),
    ),
  );

  Widget _imgLoading() => Container(
    color: widget.isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.grey.withOpacity(0.07),
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary[60],
      ),
    ),
  );
}
