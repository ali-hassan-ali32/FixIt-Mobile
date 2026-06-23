import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/dio_factory.dart';
import '../../../features/customer/api/services/customer_api_service.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(
      DioFactory dioFactory,
      ) {
    return dioFactory.create();
  }

  @lazySingleton
  CustomerApiService customerApiService(
      Dio dio,
      ) {
    return CustomerApiService(dio);
  }
}