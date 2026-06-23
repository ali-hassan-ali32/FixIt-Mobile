import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// Timeline step status
// ══════════════════════════════════════════════════════════════
enum TimelineStepStatus { completed, active, pending, cancelled }

// ══════════════════════════════════════════════════════════════
// AppTimelineStep — data model for one step
// ══════════════════════════════════════════════════════════════
class AppTimelineStep {
  final String             title;
  final String             time;
  final String?            description;
  final TimelineStepStatus status;

  const AppTimelineStep({
    required this.title,
    required this.time,
    this.description,
    required this.status,
  });
}

// ══════════════════════════════════════════════════════════════
// AppRequestTimeline
// Vertical timeline showing request progress steps.
// Used across: pending / active / completed / cancelled views.
//
// Usage:
//   AppRequestTimeline(
//     isDark: isDark,
//     steps: [
//       AppTimelineStep(title: 'تم الإنشاء', time: '8:30 ص', status: TimelineStepStatus.completed),
//       AppTimelineStep(title: 'قيد الانتظار', time: 'جاري...', status: TimelineStepStatus.active),
//       AppTimelineStep(title: 'سيتم التعيين', time: '...', status: TimelineStepStatus.pending),
//       AppTimelineStep(title: 'مكتمل', time: '...', status: TimelineStepStatus.pending),
//     ],
//   )
// ══════════════════════════════════════════════════════════════
class AppRequestTimeline extends StatelessWidget {
  final List<AppTimelineStep> steps;
  final bool                  isDark;

  const AppRequestTimeline({
    super.key,
    required this.steps,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final isLast = i == steps.length - 1;
        return _AppTimelineItem(
          step: steps[i],
          isDark: isDark,
          isLast: isLast,
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// _AppTimelineItem — single step row (private)
// ══════════════════════════════════════════════════════════════
class _AppTimelineItem extends StatefulWidget {
  final AppTimelineStep step;
  final bool            isDark;
  final bool            isLast;

  const _AppTimelineItem({
    required this.step,
    required this.isDark,
    required this.isLast,
  });

  @override
  State<_AppTimelineItem> createState() => _AppTimelineItemState();
}

class _AppTimelineItemState extends State<_AppTimelineItem>
    with SingleTickerProviderStateMixin {
  // pulse animation for active step dot
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    if (widget.step.status == TimelineStepStatus.active) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final status      = widget.step.status;
    final isDark      = widget.isDark;

    // ── Dot colors ─────────────────────────────────────────
    Color dotBg, dotBorder;
    Widget dotChild;

    switch (status) {
      case TimelineStepStatus.completed:
        dotBg     = AppColors.accent[60]!;
        dotBorder = AppColors.accent[60]!;
        dotChild  = Icon(Icons.check_rounded,
            size: 12.sp, color: Colors.white);
      case TimelineStepStatus.active:
        dotBg     = AppColors.secondary[60]!;
        dotBorder = AppColors.secondary[60]!;
        dotChild  = Icon(Icons.access_time_rounded,
            size: 12.sp, color: Colors.white);
      case TimelineStepStatus.pending:
        dotBg     = Colors.transparent;
        dotBorder = AppColors.primary[60]!.withOpacity(0.2);
        dotChild  = Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.primary[60]!.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        );
      case TimelineStepStatus.cancelled:
        dotBg     = AppColors.danger;
        dotBorder = AppColors.danger;
        dotChild  = Icon(Icons.close_rounded,
            size: 12.sp, color: Colors.white);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Line + dot column ───────────────────────────
          SizedBox(
            width: 40.w,
            child: Column(
              children: [
                // Dot
                status == TimelineStepStatus.active
                    ? AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: _buildDot(dotBg, dotBorder, dotChild, status),
                )
                    : _buildDot(dotBg, dotBorder, dotChild, status),

                // Line below dot
                if (!widget.isLast)
                  Expanded(
                    child: Container(
                      width: 3.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: status == TimelineStepStatus.completed
                              ? [AppColors.accent[60]!, AppColors.primary[60]!.withOpacity(0.2)]
                              : [AppColors.primary[60]!.withOpacity(0.15), AppColors.primary[60]!.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // ── Content card ────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 16.h),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: status == TimelineStepStatus.active
                        ? AppColors.secondary[60]!.withOpacity(0.3)
                        : status == TimelineStepStatus.cancelled
                        ? AppColors.danger.withOpacity(0.2)
                        : AppColors.primary[60]!.withOpacity(0.08),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0.15 : 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.step.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: status == TimelineStepStatus.pending
                            ? colorScheme.onSurfaceVariant
                            : status == TimelineStepStatus.cancelled
                            ? AppColors.danger
                            : null,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.step.time,
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.step.description != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        widget.step.description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(
      Color bg,
      Color border,
      Widget child,
      TimelineStepStatus status,
      ) {
    return Container(
      width: 26.w,
      height: 26.h,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: border, width: 2.5),
        boxShadow: status == TimelineStepStatus.active
            ? [
          BoxShadow(
            color: AppColors.secondary[60]!.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}