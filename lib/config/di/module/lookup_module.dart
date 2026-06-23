import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../features/lookups/api/services/lookup_api_service.dart';

@module
abstract class LookupModule {

  @lazySingleton
  LookupApiService lookupApiService(
      Dio dio,
      ) {
    return LookupApiService(dio);
  }
}