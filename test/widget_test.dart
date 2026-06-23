import 'package:fix_it/config/providers/app_config_provider.dart';
import 'package:fix_it/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots with provider wiring', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final sharedPreferences = await SharedPreferences.getInstance();
    final config = AppConfigProvider(sharedPreferences: sharedPreferences);
    await config.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppConfigProvider>.value(
        value: config,
        child: const FixItApp(isRememberMe: true),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SearchBar), findsOneWidget);
  });
}
