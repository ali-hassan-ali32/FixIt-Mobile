import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/translation/app_localizations.dart';
import '../../../../core/utils/widgets/animations/app_animated_indexed_stack.dart';
import '../../../../core/utils/widgets/app_bottom_nav_bar.dart';
import 'customer_browse_categories_view.dart';
import 'customer_home_view.dart';
import 'customer_profile_view.dart';
import 'customer_request_history_view.dart';

class CustomerShell extends StatefulWidget {
  final int initialIndex;

  const CustomerShell({super.key, this.initialIndex = 0});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  late int _currentIndex;

  static final _pages = [
    CustomerHomeView(),
    CustomerBrowseCategoriesView(),
    CustomerRequestHistoryView(),
    CustomerProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTap(int index) {
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
        onTap: _onTap,
        items: [
          AppNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l10n.navHome,
          ),
          AppNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: l10n.navExplore,
          ),
          AppNavItem(
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
            label: l10n.navRequests,
          ),
          AppNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
