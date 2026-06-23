import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../config/constants/values/app_keys.dart';
import '../../../config/di/di.dart';

FlutterSecureStorage _secureStorage() => getIt.get<FlutterSecureStorage>();

Future<bool> getRememberMe() async {
  final rememberMeValue = await _secureStorage().read(
    key: AppKeys.keyRememberMe,
  );
  return rememberMeValue == 'true';
}

Future<void> setRememberMe(bool value) async {
  await _secureStorage().write(
    key: AppKeys.keyRememberMe,
    value: value.toString(),
  );
}

Future<void> clearRememberMe() async {
  await _secureStorage().delete(key: AppKeys.keyRememberMe);
}
