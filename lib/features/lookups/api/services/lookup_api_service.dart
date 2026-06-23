import 'package:dio/dio.dart';
import 'package:fix_it/core/network/api_constants.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/lookup_item_model.dart';


part 'lookup_api_service.g.dart';

@RestApi()
abstract class LookupApiService {

  factory LookupApiService(
      Dio dio, {
        String baseUrl,
      }) = _LookupApiService;

  @GET(ApiConstants.cities)
  Future<List<LookupItemModel>> getCities();

  @GET(ApiConstants.regions)
  Future<List<LookupItemModel>> getRegions(
      @Path('cityId') String cityId,
      );

  @GET(ApiConstants.categories)
  Future<List<LookupItemModel>> getCategories();
}