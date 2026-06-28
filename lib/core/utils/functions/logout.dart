import 'package:fix_it/core/utils/functions/remeber_me.dart';

import '../../../config/di/di.dart';
import '../../storage/secure_storage_service.dart';

Future<void> logout() async {
  await clearRememberMe();

  await getIt<SecureStorageService>().clear();
}