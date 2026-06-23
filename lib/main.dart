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

  // final isRememberMe = await getRememberMe();
  // final token = await getIt<SecureStorageService>().getToken();

  runApp(
    ChangeNotifierProvider<AppConfigProvider>.value(
      value: config,
      child: DevicePreview(
        enabled: !kReleaseMode,
          builder: (context) => FixItApp(
            // isRememberMe: isRememberMe,
            // hasToken: token != null && token.isNotEmpty,
          ),
      ),
    ),
  );
}

class FixItApp extends StatelessWidget {
  const FixItApp({
    super.key,
    // required this.isRememberMe,
    // required this.hasToken,
  });

  // final bool isRememberMe;
  // final bool hasToken;

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

  // String _resolveInitialRoute(AppConfigProvider config,) {
  //   if (!isRememberMe || !hasToken) {
  //     return AppRoutes.splash;
  //   }
  //
  //   return config.isHandyman
  //       ? AppRoutes.handymanHome
  //       : AppRoutes.customerHome;
  // }
}

// Save JWT token في Secure Storage.
// Auto Login إذا Remember Me مفعلة.
// Logout.
// Auth Guard / Route Guard.
// Refresh Token (إذا الـ Backend يدعمه).



/*
* ////////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/customers/me :
* /////// Response:
* {
    "id": "f985a782-a3a8-457c-9019-a346b87fe168",
    "email": "",
    "fullName": "ali test",
    "phone": "",
    "avatar": null,
    "address": "string",
    "isVerified": false,
    "memberSince": "2026-06-21T16:22:07.2443091"
}
* /////////////////// Put: https://lucrative-ladies-resilient.ngrok-free.dev/customers/me :
* ////////////// Response:
* Profileupdatedsuccessfully
* /////////// Request Body:
* {
  "fullName": "ali test",
  "phoneNumber": "01014194073",
  "email": "alitest@gmail.com",
  "address": "string",
  "avatar": "string"
}
* ///////////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/customers/requests :
* //////////////////// Response:
* [
    {
        "id": "d5233e40-3cd3-4706-a35c-17e9ae4b5534",
        "title": "string",
        "status": "Pending",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    },
    {
        "id": "11e083fc-1eda-4056-bef8-c0ccb8ed1c7b",
        "title": "string",
        "status": "Cancelled",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    },
    {
        "id": "fc064dcd-1a93-4421-9491-ff7f0d21cc3e",
        "title": "string",
        "status": "Cancelled",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    }
]
* /////////////////////// Post: https://lucrative-ladies-resilient.ngrok-free.dev/customers/requests :
* //////////////////// Response:
* "d5233e40-3cd3-4706-a35c-17e9ae4b5534"
* //////////////////// Request Body:
* {
  "categoryId": "cca8cd7c-4731-49b2-ba69-068ea40b673b",
  "cityId": "2f2ba71e-c827-4239-a7b6-e9e8adf07b23",
  "regionId": "4870bbf1-5d60-4bcd-ab05-297941e4ff9c",
  "title": "string",
  "description": "string",
  "addressLine": "string",
  "scheduledAtUtc": "2026-06-21T16:34:02.335Z",
  "estimatedDurationInMinutes": 0,
  "images": [
    "string"
  ]
}
* ////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/customers/requests/{id} :
* ////////////// Response:
* {
    "id": "d5233e40-3cd3-4706-a35c-17e9ae4b5534",
    "handymanName": null,
    "title": "string",
    "description": "string",
    "status": "Pending",
    "address": "string",
    "scheduledAt": "2026-06-21T16:34:02.335",
    "imageUrls": [
        "string"
    ],
    "createdAt": "2026-06-21T17:07:01.3561532"
}
* //////////////////// Post: https://lucrative-ladies-resilient.ngrok-free.dev/customers/requests/{id}/cancel :
* //////////////////// Response:
* 204 No Content
* There is no content to send for this request except for headers.
* Note!: it no aa message its realy no Content
*
* ///////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/customers/requests :
* ///////////////// Response:
* [
    {
        "id": "d5233e40-3cd3-4706-a35c-17e9ae4b5534",
        "title": "string",
        "status": "Pending",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    },
    {
        "id": "057ea592-a1df-42fa-81a9-bddc590a31a0",
        "title": "string",
        "status": "Cancelled",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    },
    {
        "id": "11e083fc-1eda-4056-bef8-c0ccb8ed1c7b",
        "title": "string",
        "status": "Cancelled",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    },
    {
        "id": "fc064dcd-1a93-4421-9491-ff7f0d21cc3e",
        "title": "string",
        "status": "Cancelled",
        "handymanName": null,
        "scheduledAt": "2026-06-21T16:34:02.335",
        "location": "string"
    }
]
*
*
* /////////////////// Put: https://lucrative-ladies-resilient.ngrok-free.dev/customers/notifications/read-all :
* /////////////////// Response:
* 204 No Content
* There is no content to send for this request except for headers.
* ////////////////// Get: https://lucrative-ladies-resilient.ngrok-free.dev/customers/statistics :
* ////////////////// Response:
* {
    "totalRequests": 4,
    "pendingRequests": 1,
    "completedRequests": 0,
    "cancelledRequests": 3,
    "totalReviews": 0
}
* */


