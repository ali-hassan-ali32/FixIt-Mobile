import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppRatingStars
// Row of stars + optional numeric value.
// Replaces _RatingRow in contact cards and search card.
//
// Usage:
//   AppRatingStars(rating: 4.9)
//   AppRatingStars(rating: 4.5, starSize: 16, showValue: false)
//   AppRatingStars(rating: 4.9, starSize: 18, valueStyle: textTheme.bodyMedium)
// ══════════════════════════════════════════════════════════════
class AppRatingStars extends StatelessWidget {
  final double     rating;
  final double     starSize;
  final bool       showValue;
  final TextStyle? valueStyle;

  const AppRatingStars({
    super.key,
    required this.rating,
    this.starSize   = 14,
    this.showValue  = true,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) => Icon(
          i < rating.floor()
              ? Icons.star_rounded
              : i < rating
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          size: starSize.sp,
          color: AppColors.star,
        )),
        if (showValue) ...[
          SizedBox(width: 4.w),
          Text(
            rating.toStringAsFixed(1),
            style: valueStyle ??
                GoogleFonts.cairo(
                  fontSize: (starSize - 2).sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.star,
                ),
          ),
        ],
      ],
    );
  }
}