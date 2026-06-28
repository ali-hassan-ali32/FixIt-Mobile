import 'package:fix_it/features/customer/domain/entities/review_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/widgets/app_empty_states.dart';
import '../../../../core/utils/widgets/app_main_background.dart';
import '../../../../core/utils/widgets/app_page_header.dart';
import '../../../../core/utils/widgets/app_rating_star.dart';
import '../../../../core/utils/widgets/buttons/app_gradient_button.dart';
import '../../../../core/utils/widgets/cards/app_section_card.dart';
import '../../domain/entities/handyman_details_entity.dart';
import '../cubit/customer_cubit.dart';
import '../cubit/customer_state.dart';

// ══════════════════════════════════════════════════════════════
// Models
// ══════════════════════════════════════════════════════════════
// class HandymanProfileModel {
//   final String id;
//   final String name;
//   final String specialty;
//   final String hourlyRate;
//   final double rating;
//   final int reviewCount;
//   final String yearsExp;
//   final String completedJobs;
//   final String successRate;
//   final String about;
//   final List<String> services;
//   final String workArea;
//   final String workHours;
//   final List<Color> gradient;
//   final List<ReviewModel> reviews;
//   final int portfolioCount;
//
//   const HandymanProfileModel({
//     required this.id,
//     required this.name,
//     required this.specialty,
//     required this.hourlyRate,
//     required this.rating,
//     required this.reviewCount,
//     required this.yearsExp,
//     required this.completedJobs,
//     required this.successRate,
//     required this.about,
//     required this.services,
//     required this.workArea,
//     required this.workHours,
//     required this.gradient,
//     required this.reviews,
//     this.portfolioCount = 0,
//   });
// }

// class ReviewModel {
//   final String name;
//   final double rating;
//   final String text;
//   final String date;
//   const ReviewModel({
//     required this.name,
//     required this.rating,
//     required this.text,
//     required this.date,
//   });
// }

// ══════════════════════════════════════════════════════════════
// CustomerViewHandymanView — layout router
// ══════════════════════════════════════════════════════════════
class CustomerViewHandymanView extends StatelessWidget {
  final String? handymanId;
  const CustomerViewHandymanView({super.key, this.handymanId});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth >= 600
          ? _HandymanTabletBody(handymanId: handymanId)
          : _HandymanMobileBody(handymanId: handymanId),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Shared base
// ══════════════════════════════════════════════════════════════
abstract class _HandymanBase<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  String? get handymanId;
  Color get accent => AppColors.primary[60]!;

  // HandymanProfileModel? _handyman;

  // Avatar elastic + content stagger
  late final AnimationController entryCtrl;
  late final Animation<double> avatarScale;
  late final List<Animation<double>> sectFade;
  late final List<Animation<Offset>> sectSlide;
  static const _n = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CustomerCubit>();

      cubit.getHandymanDetails(handymanId!);
      cubit.getHandymanPortfolio(handymanId!);
      cubit.getHandymanReviews(handymanId!);
    });

    entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    sectFade = List.generate(_n, (i) {
      final s = (0.25 + i * 0.13).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(s, (s + 0.40).clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });
    sectSlide = List.generate(_n, (i) {
      final s = (0.25 + i * 0.13).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: entryCtrl,
          curve: Interval(
            s,
            (s + 0.48).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
    entryCtrl.forward();
  }

  @override
  void dispose() {
    entryCtrl.dispose();
    super.dispose();
  }

  Widget sa(int i, Widget child) {
    final idx = i.clamp(0, _n - 1);
    return FadeTransition(
      opacity: sectFade[idx],
      child: SlideTransition(position: sectSlide[idx], child: child),
    );
  }

  // HandymanProfileModel getHandyman(AppLocalizations l10n) {
  //   _handyman ??= HandymanProfileModel(
  //     id: handymanId ?? '1',
  //     name: 'محمد علي',
  //     specialty: l10n.handymanSpecialtyPlumber,
  //     hourlyRate: '١٥٠ ج / ساعة',
  //     rating: 4.9,
  //     reviewCount: 128,
  //     yearsExp: '٨+',
  //     completedJobs: '٢٤٠+',
  //     successRate: '٩٨٪',
  //     about: l10n.handymanAboutText,
  //     services: [
  //       l10n.serviceLeak,
  //       l10n.servicePipes,
  //       l10n.serviceSanitary,
  //       l10n.serviceDrainage,
  //       l10n.serviceHeater,
  //       l10n.serviceWaterNet,
  //     ],
  //     workArea: l10n.handymanWorkArea,
  //     workHours: l10n.handymanWorkHours,
  //     gradient: [AppColors.primary[60]!, AppColors.secondary[60]!],
  //     portfolioCount: 5,
  //     reviews: [
  //       ReviewModel(
  //         name: 'أحمد محمود',
  //         rating: 5,
  //         text: l10n.review1Text,
  //         date: l10n.reviewDate1Week,
  //       ),
  //       ReviewModel(
  //         name: 'فاطمة حسن',
  //         rating: 5,
  //         text: l10n.review2Text,
  //         date: l10n.reviewDate2Weeks,
  //       ),
  //       ReviewModel(
  //         name: 'خالد إبراهيم',
  //         rating: 5,
  //         text: l10n.review3Text,
  //         date: l10n.reviewDate3Weeks,
  //       ),
  //     ],
  //   );
  //   return _handyman!;
  // }

  void showReviewModal(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReviewModal(handymanName: name),
    );
  }

  // ── Shared card builders ──────────────────────────────────

  Widget buildProfileCard(
      BuildContext context,
      bool isDark,
      AppLocalizations l10n,
      HandymanDetailsEntity handyman,
      )
  {
    final h = handyman;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final statues = context.watch<CustomerCubit>().statisticsData;
    final successRate = (statues?.completedRequests ?? 0.0 / (statues?.totalRequests ?? 0));

    return AppSectionCard(
      isDark: isDark,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: avatarScale,
            builder: (_, __) => Transform.scale(
              scale: avatarScale.value,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent[60]!, AppColors.accent[70]!],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 50.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            h.fullName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            h.category,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.accent[60]!.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              h.basePrice.toString(),
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.accent[60],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          AppRatingStars(rating: h.averageRating, starSize: 20, showValue: true),
          SizedBox(height: 4.h),
          Text(
            '(${h.reviewsCount} ${l10n.handymanReviewsLabel})',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: accent.withOpacity(0.10)),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _Stat(value: h.yearsOfExperience.toString(), label: l10n.handymanStatYears),
              ),
              _VDiv(),
              Expanded(
                child: _Stat(
                  value: statues?.completedRequests.toString() ?? '0.0',
                  label: l10n.handymanStatJobs,
                ),
              ),
              _VDiv(),
              Expanded(
                child: _Stat(
                  value: successRate == 0 ? 'N/A': successRate.toString(),
                  label: l10n.handymanStatSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAboutCard(
      BuildContext context,
      bool isDark,
      AppLocalizations l10n,
      HandymanDetailsEntity handyman
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.info_outline_rounded,
            label: l10n.handymanAboutTitle,
          ),
          SizedBox(height: 12.h),
          Text(
            handyman.bio ?? 'No Bio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildServicesCard(
      BuildContext context,
      bool isDark,
      AppLocalizations l10n,
      HandymanDetailsEntity handyman
  ) {
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.build_outlined,
            label: l10n.handymanServicesTitle,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: <Widget>[_ServiceBadge(label: handyman.category)]
          ),
        ],
      ),
    );
  }

  Widget buildPortfolioCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
      HandymanDetailsEntity handyman
      ) {
    final count = context.watch<CustomerCubit>().portfolio.length;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      isDark: isDark,
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.15),
                  AppColors.secondary[60]!.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 24.sp,
              color: accent,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.portfolioTitle,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '$count ${l10n.portfolioProjectsCount}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _PressBtn(
            label: l10n.portfolioViewAll,
            enabled: count > 0,
            onTap: count > 0
                ? () => Navigator.of(context).pushNamed(
                    AppRoutes.customerViewHandymanPortfolio,
                    arguments: handyman.id,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget buildContactCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
      HandymanDetailsEntity handyman
      ) {
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.location_on_outlined,
            label: l10n.handymanContactTitle,
          ),
          SizedBox(height: 4.h),
          // _InfoRow(
          //   icon: Icons.phone_outlined,
          //   iconColor: Colors.grey,
          //   label: l10n.handymanPhoneLabel,
          //   value: l10n.handymanPhoneHidden,
          //   valueColor: Colors.grey,
          //   isDark: isDark,
          //   isLast: false,
          //   isPrivate: true,
          // ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            iconColor: accent,
            label: l10n.handymanAreaLabel,
            value: '${handyman.city} - ${handyman.region}',
            isDark: isDark,
            isLast: true,
          ),
          // _InfoRow(
          //   icon: Icons.access_time_rounded,
          //   iconColor: accent,
          //   label: l10n.handymanHoursLabel,
          //   value: handyman.yearsOfExperience,
          //   isDark: isDark,
          //   isLast: true,
          // ),
        ],
      ),
    );
  }

  Widget buildReviewsCard(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
      HandymanDetailsEntity handyman
      ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionCardTitle(
            icon: Icons.star_outline_rounded,
            label: l10n.handymanReviewsTitle,
          ),
          SizedBox(height: 12.h),
          ...context.watch<CustomerCubit>().handymanReviews.asMap().entries.map(
            (e) => _ReviewTile(
              review: e.value,
              index: e.key,
              isDark: isDark,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
          ),
          SizedBox(height: 4.h),
          _ShowMoreBtn(
            label: l10n.handymanShowAllReviews,
            accentColor: accent,
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.customerViewHandymanReviews,
              arguments: handyman.id,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionBar(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
      HandymanDetailsEntity handyman,
      ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl.w,
        AppSpacing.md.h,
        AppSpacing.xl.w,
        MediaQuery.of(context).padding.bottom + AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSecondary : Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AppActionButton(
              label: l10n.handymanWriteReview,
              icon: Icons.edit_outlined,
              isSecondary: true,
              onTap: () => showReviewModal(context, handyman.fullName),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 2,
            child: AppActionButton(
              label: l10n.homeBookNow,
              icon: Icons.note_add_outlined,
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.customerBookService),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Mobile — Stack: scroll + fixed action bar
// ══════════════════════════════════════════════════════════════
class _HandymanMobileBody extends StatefulWidget {
  final String? handymanId;
  const _HandymanMobileBody({this.handymanId});

  @override
  State<_HandymanMobileBody> createState() => _HandymanMobileBodyState();
}

class _HandymanMobileBodyState extends _HandymanBase<_HandymanMobileBody> {
  @override
  String? get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.watch<CustomerCubit>();

    final handyman = cubit.handymanDetails!;

    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {

        if (cubit.handymanDetails == null && state is CustomerLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CustomerError && cubit.handymanDetails == null) {
          return Scaffold(
            body: Center(
              child: AppEmptyState(
                icon: Icons.error_outline,
                title: 'Something went wrong',
                subtitle: state.message,
                color: accent,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppMainBackground(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: AppPageHeader(
                        isDark: isDark,
                        accentColor: accent,
                        title: l10n.handymanProfileTitle,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.xl.w,
                        AppSpacing.md.h,
                        AppSpacing.xl.w,
                        180.h,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          buildProfileCard(context, isDark, l10n,handyman),
                          SizedBox(height: 16.h),
                          sa(0, buildAboutCard(context, isDark, l10n,handyman)),
                          SizedBox(height: 16.h),
                          sa(1, buildServicesCard(context, isDark, l10n,handyman)),
                          SizedBox(height: 16.h),
                          sa(2, buildPortfolioCard(context, isDark, l10n,handyman)),
                          SizedBox(height: 16.h),
                          sa(3, buildContactCard(context, isDark, l10n,handyman)),
                          SizedBox(height: 16.h),
                          sa(4, buildReviewsCard(context, isDark, l10n,handyman)),
                        ]),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: buildActionBar(context, isDark, l10n,handyman),
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
// Tablet — two columns: left profile (40%) | right details (60%)
// ══════════════════════════════════════════════════════════════
class _HandymanTabletBody extends StatefulWidget {
  final String? handymanId;
  const _HandymanTabletBody({this.handymanId});

  @override
  State<_HandymanTabletBody> createState() => _HandymanTabletBodyState();
}

class _HandymanTabletBodyState extends _HandymanBase<_HandymanTabletBody> {
  @override
  String? get handymanId => widget.handymanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    // getHandyman(l10n);
    final cubit = context.watch<CustomerCubit>();
    final handyman = cubit.handymanDetails!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppMainBackground(
        child: Column(
          children: [
            AppPageHeader(
              isDark: isDark,
              accentColor: accent,
              title: l10n.handymanProfileTitle,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: profile card + action bar (38%)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(AppSpacing.xl.w),
                            child: buildProfileCard(context, isDark, l10n,handyman),
                          ),
                        ),
                        buildActionBar(context, isDark, l10n,handyman),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, color: accent.withOpacity(0.08)),

                  // Right: scrollable sections (62%)
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(AppSpacing.xl.w),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              sa(0, buildAboutCard(context, isDark, l10n,handyman)),
                              SizedBox(height: 16.h),
                              sa(1, buildServicesCard(context, isDark, l10n,handyman)),
                              SizedBox(height: 16.h),
                              sa(2, buildPortfolioCard(context, isDark, l10n,handyman)),
                              SizedBox(height: 16.h),
                              sa(3, buildContactCard(context, isDark, l10n,handyman)),
                              SizedBox(height: 16.h),
                              sa(4, buildReviewsCard(context, isDark, l10n,handyman)),
                              SizedBox(height: 32.h),
                            ]),
                          ),
                        ),
                      ],
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
// Review Modal
// ══════════════════════════════════════════════════════════════
class _ReviewModal extends StatefulWidget {
  final String handymanName;
  const _ReviewModal({required this.handymanName});

  @override
  State<_ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<_ReviewModal>
    with SingleTickerProviderStateMixin {
  int _rating = 0;
  final _ctrl = TextEditingController();

  // Modal entry animation
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 60.h,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBgSecondary : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl.w,
            AppSpacing.lg.h,
            AppSpacing.xl.w,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.reviewModalTitle,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              Text(
                '${l10n.reviewModalQuestion} ${widget.handymanName}؟',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _rating = i + 1);
                    },
                    child: AnimatedScale(
                      scale: filled ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 40.sp,
                          color: filled
                              ? AppColors.star
                              : colorScheme.onSurfaceVariant.withOpacity(0.30),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),

              TextField(
                controller: _ctrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.reviewModalHint,
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: AppColors.primary[60]!.withOpacity(0.20),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: AppColors.primary[60]!.withOpacity(0.20),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(
                      color: AppColors.primary[60]!,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.primary[60]!.withOpacity(0.03),
                ),
                style: GoogleFonts.cairo(fontSize: 13.sp),
              ),
              SizedBox(height: 16.h),

              AppGradientButton(
                label: l10n.reviewModalSubmit,
                onTap: _rating == 0 ? null : () => Navigator.pop(context),
                gradient: LinearGradient(
                  colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                ),
                shadowColor: AppColors.primary[60]!.withOpacity(0.30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Small private widgets
// ══════════════════════════════════════════════════════════════
class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
          ).createShader(b),
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 36.h,
    width: 1,
    color: AppColors.primary[60]!.withOpacity(0.10),
  );
}

class _ServiceBadge extends StatelessWidget {
  final String label;
  const _ServiceBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary[60]!.withOpacity(0.10),
            AppColors.secondary[60]!.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary[60],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isDark;
  final bool isLast;
  final bool isPrivate;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
    required this.isLast,
    this.valueColor,
    this.isPrivate = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary[60]!.withOpacity(0.06),
                ),
              ),
            ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (isPrivate) ...[
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Expanded(
                      child: Text(
                        value,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: valueColor,
                          fontStyle: isPrivate
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewEntity review;
  final int index;
  final bool isDark;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  const _ReviewTile({
    required this.review,
    required this.index,
    required this.isDark,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary[60]!.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.customerName,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppRatingStars(
                rating: review.rating.toDouble(),
                starSize: 13,
                showValue: false,
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            review.comment,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            review.createdAt.toString(),
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              color: colorScheme.onSurfaceVariant.withOpacity(0.60),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowMoreBtn extends StatefulWidget {
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  const _ShowMoreBtn({
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ShowMoreBtn> createState() => _ShowMoreBtnState();
}

class _ShowMoreBtnState extends State<_ShowMoreBtn>
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
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.cairo(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14.sp,
                color: widget.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PressBtn extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  const _PressBtn({required this.label, required this.enabled, this.onTap});

  @override
  State<_PressBtn> createState() => _PressBtnState();
}

class _PressBtnState extends State<_PressBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.93,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) {
              _ctrl.forward();
              HapticFeedback.selectionClick();
            }
          : null,
      onTapUp: widget.enabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? LinearGradient(
                    colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                  )
                : null,
            color: widget.enabled ? null : Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: AppColors.primary[60]!.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: widget.enabled ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
