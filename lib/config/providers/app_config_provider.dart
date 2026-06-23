import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/values/app_keys.dart';

@lazySingleton
class AppConfigProvider extends ChangeNotifier {
  SharedPreferences sharedPreferences;
  String selectedLocale = 'ar';
  String selectedTheme  = 'light';
  bool   isHandyman     = false;

  AppConfigProvider({required this.sharedPreferences});

  Future<void> init() async {
    selectedLocale = sharedPreferences.getString(AppKeys.localeKey)   ?? AppKeys.arLocaleKey;
    selectedTheme  = sharedPreferences.getString(AppKeys.themeKey)    ?? 'light';
    isHandyman     = sharedPreferences.getString(AppKeys.userTypeKey) == AppKeys.handymanType;
    notifyListeners();
  }

  // ── User Type ────────────────────────────────────────────
  bool get isCustomer => !isHandyman;

  Future<void> setUserType({required bool isHandyman}) async {
    if (this.isHandyman == isHandyman) return;
    this.isHandyman = isHandyman;
    await sharedPreferences.setString(
      AppKeys.userTypeKey,
      isHandyman ? AppKeys.handymanType : AppKeys.customerType,
    );
    notifyListeners();
  }

  // ── Locale ───────────────────────────────────────────────
  bool isAr() => selectedLocale == AppKeys.arLocaleKey;

  Future<void> changeLocale({required String currentLocale}) async {
    if (currentLocale == selectedLocale) return;
    selectedLocale = currentLocale;
    await sharedPreferences.setString(AppKeys.localeKey, selectedLocale);
    notifyListeners();
  }

  // ── Theme ────────────────────────────────────────────────
  bool isDark() => selectedTheme == 'dark';

  ThemeMode get themeMode =>
      selectedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  Future<void> changeTheme({required String currentTheme}) async {
    if (currentTheme == selectedTheme) return;
    selectedTheme = currentTheme;
    await sharedPreferences.setString(AppKeys.themeKey, selectedTheme);
    notifyListeners();
  }
}
