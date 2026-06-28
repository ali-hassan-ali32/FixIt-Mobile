import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/functions/category_icon_mapper.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_search_bar.dart';
import '../../../lookups/domain/entities/lookup_item_entity.dart';
import '../../../lookups/presentation/cubit/lookup_cubit.dart';
import '../../../lookups/presentation/cubit/lookup_state.dart';

// ── Model ─────────────────────────────────────────────────────
// class CategoryModel {
//   final String name;
//   final IconData icon;
//   final int technicianCount;
//
//   const CategoryModel({
//     required this.name,
//     required this.icon,
//     required this.technicianCount,
//   });
// }

// final _kAllCategories = [
//   CategoryModel(name: 'كهرباء', icon: Icons.bolt_rounded, technicianCount: 45),
//   CategoryModel(
//     name: 'سباكة',
//     icon: Icons.water_drop_outlined,
//     technicianCount: 38,
//   ),
//   CategoryModel(
//     name: 'نجارة',
//     icon: Icons.handyman_outlined,
//     technicianCount: 26,
//   ),
//   CategoryModel(
//     name: 'دهانات',
//     icon: Icons.format_paint_outlined,
//     technicianCount: 35,
//   ),
//   CategoryModel(
//     name: 'تكييفات',
//     icon: Icons.ac_unit_rounded,
//     technicianCount: 30,
//   ),
//   CategoryModel(
//     name: 'تبريد وتجميد',
//     icon: Icons.kitchen_outlined,
//     technicianCount: 18,
//   ),
//   CategoryModel(
//     name: 'سيراميك',
//     icon: Icons.grid_view_rounded,
//     technicianCount: 22,
//   ),
//   CategoryModel(name: 'حدائق', icon: Icons.park_outlined, technicianCount: 18),
//   CategoryModel(
//     name: 'أجهزة منزلية',
//     icon: Icons.tv_outlined,
//     technicianCount: 42,
//   ),
//   CategoryModel(
//     name: 'تنظيف',
//     icon: Icons.cleaning_services_outlined,
//     technicianCount: 50,
//   ),
//   CategoryModel(
//     name: 'نقل وتخزين',
//     icon: Icons.local_shipping_outlined,
//     technicianCount: 15,
//   ),
//   CategoryModel(
//     name: 'كاميرات مراقبة',
//     icon: Icons.camera_outdoor_outlined,
//     technicianCount: 20,
//   ),
//   CategoryModel(
//     name: 'صيانة عامة',
//     icon: Icons.build_outlined,
//     technicianCount: 65,
//   ),
//   CategoryModel(
//     name: 'عزل مائي',
//     icon: Icons.water_outlined,
//     technicianCount: 14,
//   ),
//   CategoryModel(
//     name: 'جبس وديكور',
//     icon: Icons.architecture_outlined,
//     technicianCount: 28,
//   ),
//   CategoryModel(
//     name: 'حدادة وألمنيوم',
//     icon: Icons.construction_outlined,
//     technicianCount: 16,
//   ),
// ];

const _kPopularCount = 8;

// ══════════════════════════════════════════════════════════════
// CustomerBrowseCategoriesView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerBrowseCategoriesView extends StatelessWidget {
  const CustomerBrowseCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? const CustomerBrowseCategoriesTabletBody()
          : const CustomerBrowseCategoriesMobileBody(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base — state + logic
// ══════════════════════════════════════════════════════════════
abstract class _BrowseBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  Color get accent => AppColors.primary[60]!;

  final searchCtrl = TextEditingController();
  String searchQuery = '';
  bool showingAll = false;

  // Header entry
  late final AnimationController headerCtrl;
  late final Animation<double> headerFade;
  late final Animation<Offset> headerSlide;

  @override
  void initState() {
    super.initState();
    headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    headerFade = CurvedAnimation(parent: headerCtrl, curve: Curves.easeOut);
    headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: headerCtrl, curve: Curves.easeOutCubic));
    headerCtrl.forward();
  }

  @override
  void dispose() {
    headerCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  List<LookupItemEntity> visible(
      List<LookupItemEntity> categories,
      ) {
    if (searchQuery.isNotEmpty) {
      return categories
          .where(
            (e) => e.name.toLowerCase().contains(
          searchQuery.toLowerCase(),
        ),
      )
          .toList();
    }

    return showingAll
        ? categories
        : categories.take(_kPopularCount).toList();
  }

  void onSearchChanged(String q) => setState(() => searchQuery = q.trim());

  void clearSearch() {
    searchCtrl.clear();
    setState(() => searchQuery = '');
  }

  void toggleShowAll() => setState(() {
    showingAll = !showingAll;
    searchCtrl.clear();
    searchQuery = '';
  });

  void navigate(
      BuildContext context,
      LookupItemEntity cat,
      ) {
    Navigator.of(context).pushNamed(
      AppRoutes.customerCategorySearchResults,
      arguments: {
        'categoryId': cat.id,
        'categoryName': cat.name,
      },
    );
  }

  Widget buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: headerFade,
      child: SlideTransition(
        position: headerSlide,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            MediaQuery.of(context).padding.top + AppSpacing.sm.h,
            AppSpacing.xl.w,
            AppSpacing.lg.h,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSecondary : Colors.white,
            border: Border(bottom: BorderSide(color: accent.withOpacity(0.10))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.browseCategoriesTitle,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16.h),
              AppSearchBar(
                hintText: l10n.browseCategoriesSearchHint,
                controller: searchCtrl,
                onChanged: onSearchChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.xl.h,
        AppSpacing.xl.w,
        AppSpacing.md.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            searchQuery.isNotEmpty
                ? l10n.browseSearchResults
                : l10n.browsePopularServices,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (searchQuery.isEmpty)
            GestureDetector(
              onTap: toggleShowAll,
              child: Text(
                showingAll ? l10n.browseShowPopular : l10n.homeViewAll,
                style: textTheme.bodyMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerBrowseCategoriesMobileBody — 2-column grid
// ══════════════════════════════════════════════════════════════
class CustomerBrowseCategoriesMobileBody extends StatefulWidget {
  const CustomerBrowseCategoriesMobileBody({super.key});

  @override
  State<CustomerBrowseCategoriesMobileBody> createState() =>
      _CustomerBrowseCategoriesMobileBodyState();
}

class _CustomerBrowseCategoriesMobileBodyState
    extends _BrowseBase<CustomerBrowseCategoriesMobileBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LookupCubit, LookupState>(
      builder: (context, state) {
        final cubit = context.read<LookupCubit>();

        final cats = visible(
          cubit.categories,
        );

        if (state is LookupLoading &&
            cubit.categories.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is LookupError &&
            cubit.categories.isEmpty) {
          return Scaffold(
            body: Center(
              child: AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Something went wrong',
                subtitle: state.message,
                color: accent,
              ),
            ),
          );
        }

        if (cubit.categories.isEmpty) {
          return Scaffold(
            body: Center(
              child: AppEmptyState(
                icon: Icons.category_outlined,
                title: l10n.browseEmptyTitle,
                subtitle: l10n.browseEmptySubtitle,
                color: accent,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: buildHeader(
                    context,
                    isDark,
                    l10n,
                  ),
                ),

                if (cats.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: AppEmptyState(
                        icon: Icons.search_off_rounded,
                        title: l10n.browseEmptyTitle,
                        subtitle: l10n.browseEmptySubtitle,
                        color: accent,
                        actionLabel: l10n.browseClearSearch,
                        onAction: clearSearch,
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: buildSectionHeader(
                      context,
                      l10n,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl.w,
                      0,
                      AppSpacing.xl.w,
                      AppSpacing.xxl.h,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14.h,
                        crossAxisSpacing: 14.w,
                        childAspectRatio: 1.3,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (_, i) => _CategoryCard(
                          category: cats[i],
                          index: i,
                          isDark: isDark,
                          technicianLabel:
                          l10n.browseTechnicianCount,
                          accentColor: accent,
                          onTap: () => navigate(
                            context,
                            cats[i],
                          ),
                        ),
                        childCount: cats.length,
                      ),
                    ),
                  ),
                ],

                SliverToBoxAdapter(
                  child: SizedBox(
                    height:
                    MediaQuery.of(context).padding.bottom +
                        100.h,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );  }
}

// ══════════════════════════════════════════════════════════════
// CustomerBrowseCategoriesTabletBody — 3-column grid
// ══════════════════════════════════════════════════════════════
class CustomerBrowseCategoriesTabletBody extends StatefulWidget {
  const CustomerBrowseCategoriesTabletBody({super.key});

  @override
  State<CustomerBrowseCategoriesTabletBody> createState() =>
      _CustomerBrowseCategoriesTabletBodyState();
}

class _CustomerBrowseCategoriesTabletBodyState
    extends _BrowseBase<CustomerBrowseCategoriesTabletBody> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LookupCubit, LookupState>(
        builder: (context, state) {
          final cubit = context.read<LookupCubit>();

          final cats = visible(
            cubit.categories,
          );

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppMainBackground(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: buildHeader(context, isDark, l10n)),

                  if (cats.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: l10n.browseEmptyTitle,
                          subtitle: l10n.browseEmptySubtitle,
                          color: accent,
                          actionLabel: l10n.browseClearSearch,
                          onAction: clearSearch,
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(child: buildSectionHeader(context, l10n)),
                    // 3 columns on tablet
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        0,
                        AppSpacing.xl.w,
                        AppSpacing.xxl.h,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 1.35,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (_, i) => _CategoryCard(
                            category: cats[i],
                            index: i,
                            isDark: isDark,
                            technicianLabel: l10n.browseTechnicianCount,
                            accentColor: accent,
                            onTap: () => navigate(context, cats[i]),
                          ),
                          childCount: cats.length,
                        ),
                      ),
                    ),
                  ],

                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                ],
              ),
            ),
          );
        },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _CategoryCard — entry pop + glow pulse + press scale
// ══════════════════════════════════════════════════════════════
class _CategoryCard extends StatefulWidget {
  final LookupItemEntity category;
  final int index;
  final bool isDark;
  final String technicianLabel;
  final Color accentColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.isDark,
    required this.technicianLabel,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with TickerProviderStateMixin {
  // Entry
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryScale;
  late final Animation<double> _entryFade;

  // Glow pulse
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowOpacity;

  // Press
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entryScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowOpacity = Tween<double>(
      begin: 0.08,
      end: 0.20,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: (widget.index % 8) * 55), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _entryFade,
      child: ScaleTransition(
        scale: _entryScale,
        child: GestureDetector(
          onTapDown: (_) {
            _pressCtrl.forward();
            HapticFeedback.selectionClick();
          },
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          child: ScaleTransition(
            scale: _pressScale,
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, child) => Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: widget.isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.all(AppRadius.lg),
                  border: Border.all(
                    color: widget.accentColor.withOpacity(_glowOpacity.value),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(
                        _glowOpacity.value * 0.6,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.accentColor.withOpacity(0.12),
                          AppColors.secondary[60]!.withOpacity(0.12),
                        ],
                      ),
                      borderRadius: BorderRadius.all(AppRadius.md),
                    ),
                    child: Icon(
                      CategoryIconMapper.iconOf(
                        widget.category.icon,
                      ),
                      size: 20.sp,
                      color: widget.accentColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.category.name,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.technicianLabel,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
