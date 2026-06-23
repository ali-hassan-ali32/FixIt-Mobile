import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../l10n/translation/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

class AppTermsModal {
  AppTermsModal._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _TermsModalContent(),
    );
  }
}

class _TermsModalContent extends StatelessWidget {
  const _TermsModalContent();

  @override
  Widget build(BuildContext context) {
    final textTheme   = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n        = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: AppRadius.xxl,
          topRight: AppRadius.xxl,
        ),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────
          SizedBox(height: AppSpacing.sm.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.all(AppRadius.pill),
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),

          // ── Header ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.appLoading, style: textTheme.displaySmall),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.sp,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: colorScheme.outline,
            height: AppSpacing.xl.h,
          ),

          // ── Content ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TermsSection(
                    title: '📋 مقدمة',
                    content:
                    'مرحباً بك في منصة FixIt. باستخدامك لخدماتنا، فإنك توافق على الالتزام بالشروط والأحكام التالية.',
                  ),
                  _TermsSection(
                    title: '1️⃣ قبول الشروط',
                    content:
                    'بإنشائك حساباً على المنصة، فإنك تقر بأنك قرأت وفهمت هذه الشروط، وتوافق على الالتزام بها، وبلغت السن القانونية (18 عاماً).',
                  ),
                  _TermsSection(
                    title: '2️⃣ استخدام الخدمة',
                    content:
                    'تلتزم باستخدام المنصة بطريقة قانونية ومسؤولة، وعدم انتحال شخصية الآخرين، وتقديم معلومات صحيحة ودقيقة، واحترام حقوق المستخدمين الآخرين.',
                  ),
                  _TermsSection(
                    title: '3️⃣ حسابك',
                    content:
                    'أنت مسؤول عن الحفاظ على سرية حسابك. لا تشارك بيانات دخولك مع الآخرين، وأبلغنا فوراً بأي استخدام غير مصرح به.',
                  ),
                  _TermsSection(
                    title: '4️⃣ الخصوصية',
                    content:
                    'نحن ملتزمون بحماية خصوصيتك. تُستخدم بياناتك الشخصية وفقاً لسياسة الخصوصية الخاصة بنا.',
                  ),
                  _TermsSection(
                    title: '5️⃣ المدفوعات والرسوم',
                    content:
                    'جميع الأسعار بالجنيه المصري. يتم خصم عمولة المنصة من كل معاملة. المدفوعات آمنة ومشفرة.',
                  ),
                  _TermsSection(
                    title: '6️⃣ إلغاء وتعديل الخدمات',
                    content:
                    'نحتفظ بالحق في تعديل أو إيقاف الخدمة في أي وقت دون إشعار مسبق.',
                  ),
                  _TermsSection(
                    title: '7️⃣ المسؤولية',
                    content:
                    'FixIt منصة وساطة بين العملاء والفنيين. نحن غير مسؤولين عن جودة الخدمات المقدمة من الفنيين، أو النزاعات بين الأطراف، أو الأضرار الناتجة عن العمل.',
                  ),
                  _TermsSection(
                    title: '8️⃣ إنهاء الحساب',
                    content:
                    'يحق لنا تعليق أو إنهاء حسابك في حالة انتهاك هذه الشروط.',
                  ),
                  _TermsSection(
                    title: '9️⃣ التواصل',
                    content: 'لأي استفسارات، تواصل معنا عبر: support@fixit.com',
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // ── Info Box ─────────────────────────
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md.w),
                    decoration: BoxDecoration(
                      color: AppColors.accent[60]!.withOpacity(0.1),
                      borderRadius: BorderRadius.all(AppRadius.md),
                      border: Border(
                        right: BorderSide(
                          color: AppColors.accent[60]!,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      '✅ بالموافقة على هذه الشروط، فإنك تقر بأنك قرأتها وفهمتها بالكامل',
                      style: textTheme.bodySmall?.copyWith(height: 1.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),
                ],
              ),
            ),
          ),

          // ── Footer Button ─────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl.w,
              AppSpacing.md.h,
              AppSpacing.xl.w,
              AppSpacing.xl.h,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary[60]!, AppColors.secondary[60]!],
                  ),
                  borderRadius: BorderRadius.all(AppRadius.lg),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.appLoading,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Terms Section ─────────────────────────────────────────────
class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 6.h),
          Text(content,
              style: textTheme.bodyLarge
                  ?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}