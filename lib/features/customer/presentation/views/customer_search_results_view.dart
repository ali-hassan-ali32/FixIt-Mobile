import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_filter_chip.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';
import '../../../../core/utils/widgets/buttons/app_gradient_button.dart';
import '../../domain/entities/handyman_list_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// enum _Sort { recommended, rating, price, experience }

// ══════════════════════════════════════════════════════════════
// CustomerSearchResultsView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerSearchResultsView extends StatelessWidget {
  final String? query;
  final String? categoryId;

  const CustomerSearchResultsView({super.key, this.query, this.categoryId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? CustomerSearchResultsTabletBody(query: query, categoryId: categoryId)
          : CustomerSearchResultsMobileBody(query: query, categoryId: categoryId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _SearchBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String? get query;
  String? get categoryId;

  Color get accent => AppColors.primary[60]!;

  // _Sort sort = _Sort.recommended;
  // bool availableOnly = false;
  // double minRating = 0;

  List<HandymanListEntity> _allHandymen = [];

  // Entry
  late final AnimationController entryCtrl;
  late final Animation<double> entryFade;
  late final Animation<Offset> entrySlide;

  @override
  void initState() {
    super.initState();
    entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    entryFade = CurvedAnimation(parent: entryCtrl, curve: Curves.easeOut);
    entrySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: entryCtrl, curve: Curves.easeOutCubic));
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }

  // List<HandymanListEntity> get filtered {
  //   var list = _allHandymen.where((h) {
  //     if (availableOnly && !h.isAvailable) return false;
  //     if (h.rating < minRating) return false;
  //     return true;
  //   }).toList();
  //   switch (sort) {
  //     case _Sort.rating:
  //       list.sort((a, b) => b.rating.compareTo(a.rating));
  //       break;
  //     case _Sort.price:
  //       list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
  //       break;
  //     case _Sort.experience:
  //       list.sort((a, b) => b.yearsOfExperience.compareTo(a.yearsOfExperience));
  //       break;
  //     default:
  //       break;
  //   }
  //   return list;
  // }

  // void _applyFilters(BuildContext ctx) {
  //   ctx.read<CustomerCubit>().getHandymen(
  //     search: query,
  //     categoryId: categoryId,
  //     availableOnly: availableOnly,
  //   );
  // }

  // void showFilterSheet(BuildContext ctx, bool isDark, AppLocalizations l10n) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _FilterSheet(
  //       isDark: isDark,
  //       sort: sort,
  //       availableOnly: availableOnly,
  //       minRating: minRating,
  //       l10n: l10n,
  //       onApply: (s, a, r) {
  //         setState(() {
  //           sort = s;
  //           availableOnly = a;
  //           minRating = r;
  //         });
  //         _applyFilters(ctx);
  //       },
  //     ),
  //   );
  // }
  //
  // String sortLabel(_Sort opt, AppLocalizations l10n) {
  //   switch (opt) {
  //     case _Sort.recommended: return l10n.searchSortRecommended;
  //     case _Sort.rating:      return l10n.searchSortRating;
  //     case _Sort.price:       return l10n.searchSortPrice;
  //     case _Sort.experience:  return l10n.searchSortExp;
  //   }
  // }
  //
  // Widget buildFilterBtn(BuildContext ctx, bool isDark, AppLocalizations l10n) {
  //   return GestureDetector(
  //     onTap: () { HapticFeedback.selectionClick(); showFilterSheet(ctx, isDark, l10n); },
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //       decoration: BoxDecoration(
  //         color: isDark ? AppColors.darkSurface : Colors.white,
  //         borderRadius: BorderRadius.circular(10.r),
  //         border: Border.all(color: accent.withOpacity(0.25)),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.tune_rounded, size: 18.sp, color: accent),
  //           SizedBox(width: 6.w),
  //           Text(l10n.searchFilterBtn, style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700, color: accent)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget buildSortChips(BuildContext ctx, bool isDark, AppLocalizations l10n) {
  //   return SizedBox(
  //     height: 44.h,
  //     child: ListView(
  //       scrollDirection: Axis.horizontal,
  //       padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w, vertical: 4.h),
  //       children: _Sort.values.map((opt) => Padding(
  //         padding: EdgeInsets.only(left: 8.w),
  //         child: AppFilterChip(
  //           label: sortLabel(opt, l10n),
  //           isActive: sort == opt,
  //           isDark: isDark,
  //           onTap: () => setState(() => sort = opt),
  //         ),
  //       )).toList(),
  //     ),
  //   );
  // }

  Widget buildCard(BuildContext ctx, HandymanListEntity h, bool isDark, AppLocalizations l10n, int index) {
    return _ResultCard(
      handyman: h,
      index: index,
      isDark: isDark,
      l10n: l10n,
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.customerViewHandyman, arguments: h.id),
      onBook: () => Navigator.of(context).pushNamed(AppRoutes.customerBookService, arguments: h.id),
    );
  }

  Widget buildCountRow(BuildContext context, int count, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, 12.h, AppSpacing.xl.w, 4.h),
      child: Text(
        '${l10n.searchResultsCount} $count ${l10n.searchResultsCountSuffix}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerSearchResultsMobileBody
// ══════════════════════════════════════════════════════════════
class CustomerSearchResultsMobileBody extends StatefulWidget {
  final String? query;
  final String? categoryId;

  const CustomerSearchResultsMobileBody({super.key, this.query, this.categoryId});

  @override
  State<CustomerSearchResultsMobileBody> createState() => _CustomerSearchResultsMobileBodyState();
}

class _CustomerSearchResultsMobileBodyState extends _SearchBase<CustomerSearchResultsMobileBody> {
  @override
  String? get query => widget.query;
  @override
  String? get categoryId => widget.categoryId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerHandymenLoaded || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerHandymenLoaded) {
          setState(() => _allHandymen = state.handymen);
          entryCtrl.forward(from: 0);
        }
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (_, s) => s is CustomerLoading || s is CustomerHandymenLoaded || s is CustomerError,
      builder: (ctx, state) {
        final results = _allHandymen;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Column(
              children: [
                AppPageHeader(
                  isDark: isDark,
                  title: l10n.searchResultsTitle,
                  accentColor: accent,
                  subtitle: query != null ? '"$query"' : categoryId,
                ),
                Expanded(
                  child: state is CustomerLoading && _allHandymen.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : FadeTransition(
                          opacity: entryFade,
                          child: SlideTransition(
                            position: entrySlide,
                            child: results.isEmpty
                                ? Center(
                                    child: AppEmptyState(
                                      icon: Icons.search_off_rounded,
                                      title: l10n.searchEmptyTitle,
                                      subtitle: l10n.searchEmptySubtitle,
                                      color: accent,
                                      actionLabel: l10n.searchEmptyAction,
                                      onAction: () => Navigator.of(context).pop(),
                                    ),
                                  )
                                : CustomScrollView(
                                    slivers: [
                                      SliverToBoxAdapter(child: buildCountRow(context, results.length, l10n)),
                                      // SliverToBoxAdapter(child: buildSortChips(ctx, isDark, l10n)),
                                      SliverPadding(
                                        padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, 8.h, AppSpacing.xl.w, MediaQuery.of(context).padding.bottom + 100.h),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (_, i) => buildCard(ctx, results[i], isDark, l10n, i),
                                            childCount: results.length,
                                          ),
                                        ),
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
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CustomerSearchResultsTabletBody — filter sidebar
// ══════════════════════════════════════════════════════════════
class CustomerSearchResultsTabletBody extends StatefulWidget {
  final String? query;
  final String? categoryId;

  const CustomerSearchResultsTabletBody({super.key, this.query, this.categoryId});

  @override
  State<CustomerSearchResultsTabletBody> createState() => _CustomerSearchResultsTabletBodyState();
}

class _CustomerSearchResultsTabletBodyState extends _SearchBase<CustomerSearchResultsTabletBody> {
  @override
  String? get query => widget.query;
  @override
  String? get categoryId => widget.categoryId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<CustomerCubit, CustomerState>(
      listenWhen: (_, s) => s is CustomerHandymenLoaded || s is CustomerError,
      listener: (_, state) {
        if (state is CustomerHandymenLoaded) {
          setState(() => _allHandymen = state.handymen);
          entryCtrl.forward(from: 0);
        }
        if (state is CustomerError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (_, s) => s is CustomerLoading || s is CustomerHandymenLoaded || s is CustomerError,
      builder: (ctx, state) {
        final results = _allHandymen;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Column(
              children: [
                AppPageHeader(
                  isDark: isDark,
                  title: l10n.searchResultsTitle,
                  accentColor: accent,
                  subtitle: query != null ? '"$query"' : categoryId,
                ),
                Expanded(
                  child: state is CustomerLoading && _allHandymen.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : FadeTransition(
                          opacity: entryFade,
                          child: SlideTransition(
                            position: entrySlide,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sidebar filters
                                // SizedBox(
                                //   width: MediaQuery.of(context).size.width * 0.28,
                                //   child: _TabletFilterSidebar(
                                //     isDark: isDark,
                                //     l10n: l10n,
                                //     sort: sort,
                                //     availableOnly: availableOnly,
                                //     minRating: minRating,
                                //     accentColor: accent,
                                //     onSortChanged: (s) => setState(() => sort = s),
                                //     onAvailableChanged: (v) {
                                //       setState(() => availableOnly = v);
                                //       _applyFilters(ctx);
                                //     },
                                //     onRatingChanged: (r) => setState(() => minRating = r),
                                //   ),
                                // ),
                                VerticalDivider(width: 1, color: accent.withOpacity(0.08)),
                                // Results
                                Expanded(
                                  child: results.isEmpty
                                      ? Center(
                                          child: AppEmptyState(
                                            icon: Icons.search_off_rounded,
                                            title: l10n.searchEmptyTitle,
                                            subtitle: l10n.searchEmptySubtitle,
                                            color: accent,
                                            actionLabel: l10n.searchEmptyAction,
                                            onAction: () => Navigator.of(context).pop(),
                                          ),
                                        )
                                      : CustomScrollView(
                                          slivers: [
                                            SliverToBoxAdapter(child: buildCountRow(context, results.length, l10n)),
                                            SliverPadding(
                                              padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, 8.h, AppSpacing.xl.w, 32.h),
                                              sliver: SliverList(
                                                delegate: SliverChildBuilderDelegate(
                                                  (_, i) => buildCard(ctx, results[i], isDark, l10n, i),
                                                  childCount: results.length,
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
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _TabletFilterSidebar
// ══════════════════════════════════════════════════════════════
// class _TabletFilterSidebar extends StatefulWidget {
//   final bool isDark;
//   final AppLocalizations l10n;
//   final _Sort sort;
//   final bool availableOnly;
//   final double minRating;
//   final Color accentColor;
//   final ValueChanged<_Sort> onSortChanged;
//   final ValueChanged<bool> onAvailableChanged;
//   final ValueChanged<double> onRatingChanged;
//
//   const _TabletFilterSidebar({
//     required this.isDark, required this.l10n, required this.sort,
//     required this.availableOnly, required this.minRating, required this.accentColor,
//     required this.onSortChanged, required this.onAvailableChanged, required this.onRatingChanged,
//   });
//
//   @override
//   State<_TabletFilterSidebar> createState() => _TabletFilterSidebarState();
// }

// class _TabletFilterSidebarState extends State<_TabletFilterSidebar> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final List<Animation<double>> _fades;
//   late final List<Animation<Offset>> _slides;
//   static const _n = 6;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
//     _fades = List.generate(_n, (i) {
//       final s = (i * 0.12).clamp(0.0, 1.0);
//       return Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(parent: _ctrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut)),
//       );
//     });
//     _slides = List.generate(_n, (i) {
//       final s = (i * 0.12).clamp(0.0, 1.0);
//       return Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero).animate(
//         CurvedAnimation(parent: _ctrl, curve: Interval(s, (s + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
//       );
//     });
//     _ctrl.forward();
//   }
//
//   @override
//   void dispose() { _ctrl.dispose(); super.dispose(); }
//
//   Widget _a(int i, Widget child) => FadeTransition(
//     opacity: _fades[i.clamp(0, _n - 1)],
//     child: SlideTransition(position: _slides[i.clamp(0, _n - 1)], child: child),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final l10n = widget.l10n;
//
//     return Container(
//       color: widget.isDark ? AppColors.darkBgSecondary.withOpacity(0.60) : Colors.white.withOpacity(0.70),
//       padding: EdgeInsets.all(20.w),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _a(0, Text(l10n.filterTitle, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800))),
//             SizedBox(height: 16.h),
//
//             _a(1, Row(
//               children: [
//                 Expanded(child: Text(l10n.filterAvailableOnly, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
//                 Switch(value: widget.availableOnly, onChanged: widget.onAvailableChanged, activeThumbColor: widget.accentColor),
//               ],
//             )),
//             SizedBox(height: 12.h),
//
//             _a(2, Text(l10n.filterMinRating, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
//             SizedBox(height: 8.h),
//             _a(3, Wrap(
//               spacing: 6.w, runSpacing: 6.h,
//               children: [4.0, 4.5, 4.8].map((r) {
//                 final active = widget.minRating == r;
//                 return AppFilterChip(label: '$r+', isActive: active, isDark: widget.isDark, onTap: () => widget.onRatingChanged(active ? 0 : r));
//               }).toList(),
//             )),
//             SizedBox(height: 16.h),
//
//             _a(4, Text(l10n.searchFilterBtn, style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))),
//             SizedBox(height: 8.h),
//             _a(5, Column(
//               children: _Sort.values.map((opt) {
//                 final isActive = widget.sort == opt;
//                 return GestureDetector(
//                   onTap: () => widget.onSortChanged(opt),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: EdgeInsets.only(bottom: 6.h),
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                     decoration: BoxDecoration(
//                       color: isActive ? widget.accentColor.withOpacity(0.10) : Colors.transparent,
//                       borderRadius: BorderRadius.circular(10.r),
//                       border: Border.all(color: isActive ? widget.accentColor.withOpacity(0.30) : Colors.transparent),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.sort_rounded, size: 16.sp, color: isActive ? widget.accentColor : Theme.of(context).colorScheme.onSurfaceVariant),
//                         SizedBox(width: 8.w),
//                         Text(_sortLabel(opt, l10n), style: textTheme.bodySmall?.copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? widget.accentColor : Theme.of(context).colorScheme.onSurfaceVariant)),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _sortLabel(_Sort opt, AppLocalizations l10n) {
//     switch (opt) {
//       case _Sort.recommended: return l10n.searchSortRecommended;
//       case _Sort.rating:      return l10n.searchSortRating;
//       case _Sort.price:       return l10n.searchSortPrice;
//       case _Sort.experience:  return l10n.searchSortExp;
//     }
//   }
// }

// ══════════════════════════════════════════════════════════════
// _ResultCard — API Version
// ══════════════════════════════════════════════════════════════
class _ResultCard extends StatefulWidget {
  final HandymanListEntity handyman;
  final int index;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const _ResultCard({
    required this.handyman,
    required this.index,
    required this.isDark,
    required this.l10n,
    required this.onTap,
    required this.onBook,
  });

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  static const _avatarPalette = [
    [Color(0xFF667eeA), Color(0xFF764BA2)],
    [Color(0xFF4FACFE), Color(0xFF44A3A0)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    [Color(0xFFF093FB), Color(0xFFF5576C)],
  ];

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _entryFade =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);

    _entrySlide = Tween<Offset>(
      begin: const Offset(0, .16),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );

    _pressScale = Tween<double>(
      begin: 1,
      end: .98,
    ).animate(
      CurvedAnimation(
        parent: _pressCtrl,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(
      Duration(milliseconds: widget.index * 70),
          () {
        if (mounted) _entryCtrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.handyman;
    final isDark = widget.isDark;
    final colors = _avatarPalette[widget.index % _avatarPalette.length];
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
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
            child: Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: AppColors.primary[60]!.withOpacity(.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      isDark ? .18 : .05,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [

                  // Avatar
                  Container(
                    width: 62.w,
                    height: 62.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (h.avatarUrl != null &&
                        h.avatarUrl!.isNotEmpty)
                        ? Image.network(
                      h.avatarUrl!,
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),

                  SizedBox(width: 14.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                h.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: h.isAvailable
                                    ? Colors.green.withOpacity(.12)
                                    : Colors.red.withOpacity(.12),
                                borderRadius:
                                BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                h.isAvailable
                                    ? widget.l10n.searchAvailable
                                    : widget.l10n.searchBusy,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: h.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          h.category,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                            colorScheme.onSurfaceVariant,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Row(
                          children: [

                            Icon(
                              Icons.work_outline,
                              size: 16.sp,
                              color:
                              colorScheme.onSurfaceVariant,
                            ),

                            SizedBox(width: 4.w),

                            Text(
                              '${h.yearsOfExperience} ${widget.l10n.searchExpLabel}',
                              style: textTheme.bodySmall,
                            ),

                            SizedBox(width: 18.w),

                            Icon(
                              Icons.payments_outlined,
                              size: 16.sp,
                              color:
                              colorScheme.onSurfaceVariant,
                            ),

                            SizedBox(width: 4.w),

                            Text(
                              '${h.basePrice.toInt()} ${widget.l10n.searchCurrency}',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        SizedBox(
                          width: double.infinity,
                          child: AppGradientButton(
                            label: widget.l10n.searchBookBtn,
                            onTap: widget.onBook,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary[60]!,
                                AppColors.secondary[60]!,
                              ],
                            ),
                            shadowColor:
                            AppColors.primary[60]!
                                .withOpacity(.28),
                            height: 40,
                            fontSize: 13,
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
    );
  }
}
// class _AvailBadge extends StatelessWidget {
//   final bool isAvailable;
//   final String label;
//   const _AvailBadge({required this.isAvailable, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isAvailable ? AppColors.accent[60]! : AppColors.danger;
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//       decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r)),
//       child: Text(label, style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color)),
//     );
//   }
// }

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: 3.w),
        Text(label, style: GoogleFonts.cairo(fontSize: 11.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// // ══════════════════════════════════════════════════════════════
// // _FilterSheet — bottom sheet (mobile)
// // ══════════════════════════════════════════════════════════════
// class _FilterSheet extends StatefulWidget {
//   final bool isDark;
//   final _Sort sort;
//   final bool availableOnly;
//   final double minRating;
//   final AppLocalizations l10n;
//   final void Function(_Sort, bool, double) onApply;
//
//   const _FilterSheet({
//     required this.isDark, required this.sort, required this.availableOnly,
//     required this.minRating, required this.l10n, required this.onApply,
//   });
//
//   @override
//   State<_FilterSheet> createState() => _FilterSheetState();
// }
//
// class _FilterSheetState extends State<_FilterSheet> {
//   late _Sort _sort;
//   late bool _avail;
//   late double _rating;
//
//   @override
//   void initState() {
//     super.initState();
//     _sort = widget.sort;
//     _avail = widget.availableOnly;
//     _rating = widget.minRating;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = widget.l10n;
//     final isDark = widget.isDark;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.lg.h, AppSpacing.xl.w, MediaQuery.of(context).padding.bottom + AppSpacing.xl.h),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkBgSecondary : Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40.w, height: 4.h,
//               decoration: BoxDecoration(color: colorScheme.onSurfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r)),
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Text(l10n.filterTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
//           SizedBox(height: 20.h),
//
//           Row(
//             children: [
//               Expanded(child: Text(l10n.filterAvailableOnly, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
//               Switch(value: _avail, onChanged: (v) => setState(() => _avail = v), activeThumbColor: AppColors.primary[60]),
//             ],
//           ),
//           SizedBox(height: 16.h),
//
//           Text(l10n.filterMinRating, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
//           SizedBox(height: 8.h),
//           Row(
//             children: [4.0, 4.5, 4.8].map((r) {
//               final active = _rating == r;
//               return Padding(
//                 padding: EdgeInsets.only(left: 8.w),
//                 child: AppFilterChip(label: '$r+', isActive: active, isDark: isDark, onTap: () => setState(() => _rating = active ? 0 : r)),
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 20.h),
//
//           AppGradientButton(
//             label: l10n.filterApply,
//             onTap: () { widget.onApply(_sort, _avail, _rating); Navigator.of(context).pop(); },
//             gradient: LinearGradient(colors: [AppColors.primary[60]!, AppColors.secondary[60]!]),
//             shadowColor: AppColors.primary[60]!.withOpacity(0.28),
//           ),
//         ],
//       ),
//     );
//   }
// }
