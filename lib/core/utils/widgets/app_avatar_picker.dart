import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════
// AppAvatarPicker
// Circular avatar with gradient fallback + edit button overlay.
// Tapping avatar or the label triggers image picker.
//
// Usage (customer — orange default):
//   AppAvatarPicker(
//     imageFile: _avatarFile,
//     changeLabel: l10n.editProfileChangePhoto,
//     onPicked: (file) => setState(() => _avatarFile = file),
//   )
//
// Usage (handyman — teal):
//   AppAvatarPicker(
//     imageFile: _avatarFile,
//     changeLabel: l10n.editProfileChangePhoto,
//     onPicked: (file) => setState(() => _avatarFile = file),
//     accentColor: AppColors.accent[60],
//   )
// ══════════════════════════════════════════════════════════════
class AppAvatarPicker extends StatefulWidget {
  final XFile?              imageFile;
  final String              changeLabel;
  final ValueChanged<XFile> onPicked;
  final double              size;
  /// Accent color for gradient, edit button, and label.
  /// Defaults to AppColors.primary[60] (customer orange).
  final Color?              accentColor;

  const AppAvatarPicker({
    super.key,
    required this.imageFile,
    required this.changeLabel,
    required this.onPicked,
    this.size        = 96,
    this.accentColor,
  });

  @override
  State<AppAvatarPicker> createState() => _AppAvatarPickerState();
}

class _AppAvatarPickerState extends State<AppAvatarPicker>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();

  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  Color get _accent => widget.accentColor ?? AppColors.primary[60]!;
  Color get _accentSecondary => widget.accentColor != null
      ? widget.accentColor!.withOpacity(0.78)
      : AppColors.secondary[60]!;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    HapticFeedback.selectionClick();
    await _pulseCtrl.forward();
    await _pulseCtrl.reverse();

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) widget.onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _pick,
          child: ScaleTransition(
            scale: _pulseAnim,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Avatar circle ─────────────────────────
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.imageFile == null
                        ? LinearGradient(
                      colors: [_accent, _accentSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.imageFile != null
                        ? Image.file(
                      File(widget.imageFile!.path),
                      fit: BoxFit.cover,
                    )
                        : Icon(
                      Icons.person_rounded,
                      size: size * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ── Edit button ───────────────────────────
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: _accent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 15.sp,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // ── Change label ──────────────────────────────────
        GestureDetector(
          onTap: _pick,
          child: Text(
            widget.changeLabel,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
          ),
        ),
      ],
    );
  }
}