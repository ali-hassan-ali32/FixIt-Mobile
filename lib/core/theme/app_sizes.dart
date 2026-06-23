import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppSpacing {
  static const xs   = 8.0;
  static const sm   = 12.0;
  static const md   = 16.0;
  static const lg   = 20.0;
  static const xl   = 24.0;
  static const xxl  = 32.0;

  static const xxxl = 40.0;
  static const huge = 48.0;

  static const s56  = 56.0;
  static const s64  = 64.0;
  static const s72  = 72.0;
  static const s80  = 80.0;
  static const s96  = 96.0;

  static const s112 = 112.0;
  static const s128 = 128.0;
  static const s160 = 160.0;
  static const s192 = 192.0;
  static const s224 = 224.0;
  static const s256 = 256.0;
}

class AppRadius {
  static Radius sm   = Radius.circular(8.r);
  static Radius md   = Radius.circular(12.r);
  static Radius lg   = Radius.circular(16.r);
  static Radius xl   = Radius.circular(20.r);
  static Radius xxl  = Radius.circular(24.r);
  static Radius pill = Radius.circular(100.r);
}

