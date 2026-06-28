import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_constants.dart';
import '../../data/models/requests/create_service_request.dart';
import '../../data/models/requests/review_request.dart';
import '../../data/models/requests/update_profile_request.dart';

import '../../data/models/responses/customer_profile_model.dart';
import '../../data/models/responses/customer_request_details_model.dart';
import '../../data/models/responses/customer_request_summary_model.dart';
import '../../data/models/responses/customer_statistics_model.dart';
import '../../data/models/responses/handyman_details_model.dart';
import '../../data/models/responses/handyman_list_model.dart';
import '../../data/models/responses/portfolio_item_model.dart';
import '../../data/models/responses/review_model.dart';

part 'customer_api_service.g.dart';

@RestApi()
abstract class CustomerApiService {
  factory CustomerApiService(Dio dio, {String baseUrl,}) = _CustomerApiService;

  @GET(ApiConstants.customerProfile)
  Future<CustomerProfileModel> getProfile();

  @PUT(ApiConstants.customerProfile)
  Future<String> updateProfile(@Body() UpdateProfileRequest request,);

  @GET(ApiConstants.customerRequests)
  Future<List<CustomerRequestSummaryModel>> getRequests();

  @POST(ApiConstants.customerRequests)
  Future<String> createRequest(@Body() CreateServiceRequest request,);

  @GET(ApiConstants.customerRequestDetails)
  Future<CustomerRequestDetailsModel> getRequestDetails(@Path('id') String id,);

  @POST(ApiConstants.customerCancelRequest)
  Future<void> cancelRequest(@Path('id') String id,);

  @GET(ApiConstants.customerStatistics)
  Future<CustomerStatisticsModel> getStatistics();


  @GET(ApiConstants.customerHandymen)
  Future<List<HandymanListModel>> getHandymen({
    @Query('search') String? search,
    @Query('categoryId') String? categoryId,
    @Query('availableOnly') bool? availableOnly,
  });

  @GET(ApiConstants.customerFeaturedHandymen)
  Future<List<HandymanListModel>> getFeaturedHandymen();

  @GET(ApiConstants.customerHandymanDetails)
  Future<HandymanDetailsModel> getHandymanDetails(@Path('handymanId') String handymanId,);

  @GET(ApiConstants.customerHandymanPortfolio)
  Future<List<PortfolioItemModel>> getHandymanPortfolio(@Path('handymanId') String handymanId,);


  @GET(ApiConstants.customerHandymanReviews)
  Future<List<ReviewModel>> getHandymanReviews(@Path('handymanId') String handymanId,);

  @POST(ApiConstants.customerAddReview)
  Future<void> addReview(
      @Path('requestId') String requestId,
      @Body() ReviewRequest request,
      );

  @GET(ApiConstants.customerReviews)
  Future<List<ReviewModel>> getMyReviews();
}