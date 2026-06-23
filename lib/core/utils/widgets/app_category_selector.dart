import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/constants/enums/app_enums.dart';
import '../../../features/lookups/domain/entities/lookup_item_entity.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';



// ══════════════════════════════════════════════════════════════
// AppCategorySelector
// Searchable multi-select with tags
//
// Usage:
//   AppCategorySelector(
//     label: 'التخصص',
//     categories: _kCategories,
//     selectedIds: _selectedIds,
//     onChanged: (ids) => setState(() => _selectedIds = ids),
//     userType: AppUserType.handyman, // optional, defaults to customer
//   )
// ══════════════════════════════════════════════════════════════
class AppCategorySelector extends StatefulWidget {
  final String label;
  final String subtitle;
  final String searchHint;
  final String noResultsText;
  final List<LookupItemEntity> categories;
  final List<String> selectedIds;
  final void Function(List<String>) onChanged;
  final String? Function(List<String>)? validator;
  final AppUserType userType;

  const AppCategorySelector({
    super.key,
    required this.label,
    required this.subtitle,
    required this.searchHint,
    required this.noResultsText,
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
    this.validator,
    this.userType = AppUserType.customer,
  });

  @override
  State<AppCategorySelector> createState() => _AppCategorySelectorState();
}

class _AppCategorySelectorState extends State<AppCategorySelector> {
  final _searchController = TextEditingController();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<LookupItemEntity> _filtered = [];
  bool _isOpen = false;

  // ── Dynamic Colors ─────────────────────────────────────────
  bool get isHandyman => widget.userType == AppUserType.handyman;

  Color get mainColor => isHandyman
      ? AppColors.accent[60]!
      : AppColors.primary[60]!;

  Color get secondaryColor => isHandyman
      ? AppColors.accent[40]!
      : AppColors.secondary[60]!;

  @override
  void initState() {
    super.initState();
    _filtered = widget.categories;
  }

  @override
  void didUpdateWidget(covariant AppCategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered list if categories change
    if (oldWidget.categories != widget.categories) {
      _filtered = widget.categories;
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    super.dispose();
  }

  // ── Dropdown ──────────────────────────────────────────────
  void _openDropdown() {
    if (_isOpen) return;
    _isOpen = true;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: _DropdownList(
                  categories: _filtered,
                  selectedIds: widget.selectedIds,
                  noResultsText: widget.noResultsText,
                  onToggle: _toggleCategory,
                  mainColor: mainColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _toggleCategory(String id) {
    final updated = List<String>.from(widget.selectedIds,);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }
    widget.onChanged(updated);
    _overlayEntry?.markNeedsBuild();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = query.trim().isEmpty
          ? widget.categories
          : widget.categories
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final selected = widget.categories
        .where((c) => widget.selectedIds.contains(c.id))
        .toList();

    return FormField<List<String>>(
      initialValue: widget.selectedIds,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.selectedIds)
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Label ────────────────────────────────
            Text(widget.label, style: textTheme.bodyMedium),
            SizedBox(height: 2.h),
            Text(
              widget.subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),

            // ── Search Box ────────────────────────────
            CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                onTap: _openDropdown,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.sp,
                  ),
                  // ── Borders with mainColor ───────────
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: mainColor,
                      width: 2,
                    ),
                  ),
                  errorText: state.hasError ? state.errorText : null,
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // ── Selected Tags ─────────────────────────
            if (selected.isNotEmpty)
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: selected
                    .map((c) => _CategoryTag(
                  category: c,
                  onRemove: () => _toggleCategory(c.id),
                  mainColor: mainColor,
                  secondaryColor: secondaryColor,
                ))
                    .toList(),
              ),

            // ── Count ─────────────────────────────────
            if (selected.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                '${selected.length} ${widget.subtitle}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ── Dropdown List ─────────────────────────────────────────────
class _DropdownList extends StatelessWidget {
  final List<LookupItemEntity> categories;
  final List<String> selectedIds;
  final String noResultsText;
  final void Function(String) onToggle;
  final Color mainColor;

  const _DropdownList({
    required this.categories,
    required this.selectedIds,
    required this.noResultsText,
    required this.onToggle,
    required this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.all(AppRadius.md),
      color: colorScheme.surface,
      child: Container(
        constraints: BoxConstraints(maxHeight: 250.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(AppRadius.md),
          border: Border.all(color: colorScheme.outline),
        ),
        child: categories.isEmpty
            ? Padding(
          padding: EdgeInsets.all(AppSpacing.xl.w),
          child: Center(
            child: Text(
              noResultsText,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )
            : ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: categories.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: colorScheme.outlineVariant),
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isSelected = selectedIds.contains(cat.id);

            return InkWell(
              onTap: () => onToggle(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md.w,
                  vertical: AppSpacing.sm.h,
                ),
                color: isSelected
                    ? mainColor.withOpacity(0.08)
                    : Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      Icons.handyman_outlined,
                      size: 20.sp,
                      color: mainColor,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        cat.name,
                        style: textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? mainColor
                              : colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_rounded,
                        color: mainColor,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Category Tag ──────────────────────────────────────────────
class _CategoryTag extends StatelessWidget {
  final LookupItemEntity category;
  final VoidCallback onRemove;
  final Color mainColor;
  final Color secondaryColor;

  const _CategoryTag({
    required this.category,
    required this.onRemove,
    required this.mainColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mainColor, secondaryColor],
          ),
          borderRadius: BorderRadius.all(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 13.sp,
              color: Colors.white,
            ),
            SizedBox(width: 4.w),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
