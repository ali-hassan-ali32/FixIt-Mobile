import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/widgets/animations/app_animated_indexed_stack.dart';
import '../../../../core/utils/widgets/app_bottom_nav_bar.dart';
import 'handyman_home_view.dart';
import 'handyman_jobs_view.dart';
import 'handyman_profile_view.dart';

class HandymanShell extends StatefulWidget {
  const HandymanShell({super.key});

  @override
  State<HandymanShell> createState() => _HandymanShellState();
}

class _HandymanShellState extends State<HandymanShell> {
  int _currentIndex = 0;

  static final _pages = [
    HandymanHomeView(),
    HandymanJobsView(),
    HandymanProfileView(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      body: AppAnimatedIndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        items: [
          AppNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l10n.handymanNavHome,
          ),
          AppNavItem(
            icon: Icons.work_outline_rounded,
            activeIcon: Icons.work_rounded,
            label: l10n.handymanNavJobs,
          ),
          AppNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.handymanNavProfile,
          ),
        ],
        activeColor: AppColors.accent[60],
      ),
    );
  }
}
