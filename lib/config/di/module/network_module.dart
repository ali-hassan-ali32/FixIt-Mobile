import 'package:dio/dio.dart';
import 'package:fix_it/features/handyman/api/services/handyman_api_service.dart';
import 'package:fix_it/features/notifications/api/services/notification_api_service.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/dio_factory.dart';
import '../../../features/customer/api/services/customer_api_service.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(DioFactory dioFactory,) {
    return dioFactory.create();
  }

  @lazySingleton
  CustomerApiService customerApiService(Dio dio,) {
    return CustomerApiService(dio);
  }

  @lazySingleton
  HandymanApiService handymanApiService(Dio dio,) {
    return HandymanApiService(dio);
  }

  @lazySingleton
  NotificationApiService notificationApiService(Dio dio,) {
    return NotificationApiService(dio);
  }
}