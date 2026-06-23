import 'package:flutter/material.dart';

enum AppSnackType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  const AppSnackBar._();

  static void show(
      BuildContext context, {
        required String message,
        AppSnackType type = AppSnackType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: _backgroundColor(type),
          margin: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                _icon(type),
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static Color _backgroundColor(AppSnackType type) {
    switch (type) {
      case AppSnackType.success:
        return const Color(0xFF16A34A);

      case AppSnackType.error:
        return const Color(0xFFDC2626);

      case AppSnackType.warning:
        return const Color(0xFFF59E0B);

      case AppSnackType.info:
        return const Color(0xFF2563EB);
    }
  }

  static IconData _icon(AppSnackType type) {
    switch (type) {
      case AppSnackType.success:
        return Icons.check_circle_rounded;

      case AppSnackType.error:
        return Icons.cancel_rounded;

      case AppSnackType.warning:
        return Icons.warning_amber_rounded;

      case AppSnackType.info:
        return Icons.info_rounded;
    }
  }
}