import 'package:device_preview/device_preview.dart';
import 'package:fix_it/core/router/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'config/di/di.dart';
import 'config/providers/app_config_provider.dart';
import 'core/l10n/translation/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/functions/remeber_me.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await configureDependencies();

  final config = getIt<AppConfigProvider>();
  await config.init();

  runApp(
    ChangeNotifierProvider<AppConfigProvider>.value(
      value: config,
      child: DevicePreview(
        enabled: !kReleaseMode,
          builder: (context) => FixItApp(
          ),
      ),
    ),
  );
}

class FixItApp extends StatelessWidget {
  const FixItApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfigProvider>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Fix It',
          debugShowCheckedModeBanner: false,
          builder: DevicePreview.appBuilder,
          locale: Locale(config.selectedLocale),
          theme: AppTheme.lightTheme(isHandyman: config.isHandyman),
          darkTheme: AppTheme.darkTheme(isHandyman: config.isHandyman),
          themeMode: config.themeMode,
          onGenerateRoute: AppRouter.generateRoute,
          initialRoute: AppRoutes.splash,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}



/*
* /////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/me :
* ///////// Response:
* {
    "id": "ffea3fc8-c956-4a76-b2f4-ab60ebaaa903",
    "fullName": "علي السباك",
    "email": "alihandyman@gmail.com",
    "phoneNumber": "01014194080"
}
* //////////// Put: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/me:
* /////////// Response:
* 204 No Content
* There is no content to send for this request except for headers.
* Note!: it no aa message its really no Content
* //////////// Request Body:
* {
  "fullName": "string",
  "email": "string",
  "phoneNumber": "string",
  "avatar": "string"
}
* ////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/me/jobs :
* ///////// Response:
* [
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "title": "string",
    "description": "string",
    "category": "string",
    "location": "string",
    "scheduledDate": "2026-06-23T14:49:27.975Z",
    "price": 0,
    "estimatedDuration": "string",
    "status": "string",
    "customerName": "string"
  }
]
* ////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/jobs/{id} :
* ///////////// Response:
* {
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "title": "string",
  "description": "string",
  "category": "string",
  "location": "string",
  "scheduledDate": "2026-06-23T14:52:38.148Z",
  "price": 0,
  "estimatedDurationInMinutes": 0,
  "status": "string",
  "customerName": "string",
  "images": [
    "string"
  ]
}
* //////////////////// Put: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/jobs/{id}/status :
* //////////////////// Response:
* 204 No Content
* //////////////////// Request Body:
* {
  "status": 1
}
* //////////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/me/reviews :
* //////////////////// Response:
* [
  {
    "rating": 0,
    "comment": "string",
    "customerName": "string",
    "createdAt": "2026-06-24T13:12:46.036Z"
  }
]
* //////////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/handymen/available-requests :
* //////////////////// Response:
* [
  {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "title": "string",
    "description": "string",
    "category": "string",
    "location": "string",
    "scheduledDate": "2026-06-24T13:17:01.017Z",
    "price": 0,
    "estimatedDuration": "string",
    "status": "string",
    "customerName": "string"
  }
]
* */


