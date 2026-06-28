import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_constants.dart';

import '../../data/models/requests/add_portfolio_request.dart';
import '../../data/models/requests/update_handyman_profile_request.dart';
import '../../data/models/requests/update_job_status_request.dart';

import '../../data/models/responses/handyman_portfolio_model.dart';
import '../../data/models/responses/handyman_profile_model.dart';
import '../../data/models/responses/handyman_job_summary_model.dart';
import '../../data/models/responses/handyman_job_details_model.dart';
import '../../data/models/responses/handyman_review_model.dart';
import '../../data/models/responses/handyman_statistics_model.dart';

part 'handyman_api_service.g.dart';

@RestApi()
abstract class HandymanApiService {
  factory HandymanApiService(
      Dio dio, {
        String baseUrl,
      }) = _HandymanApiService;

  @GET(ApiConstants.handymanProfile)
  Future<HandymanProfileModel> getProfile();

  @PUT(ApiConstants.handymanProfile)
  Future<void> updateProfile(@Body() UpdateHandymanProfileRequest request,);

  @GET(ApiConstants.handymanJobs)
  Future<List<HandymanJobSummaryModel>> getJobs();

  @GET(ApiConstants.handymanJobDetails)
  Future<HandymanJobDetailsModel> getJobDetails(@Path('id') String id,);

  @PUT(ApiConstants.handymanUpdateJobStatus)
  Future<void> updateJobStatus(@Path('id') String id, @Body() UpdateJobStatusRequest request,);

  @GET(ApiConstants.handymanReviews)
  Future<List<HandymanReviewModel>> getReviews();

  @GET(ApiConstants.handymanAvailableRequests)
  Future<List<HandymanJobSummaryModel>> getAvailableRequests();


  @GET(ApiConstants.handymanStatistics)
  Future<HandymanStatisticsModel> getStatistics();

  @GET(ApiConstants.handymanPortfolio)
  Future<List<HandymanPortfolioModel>> getPortfolio();

  @POST(ApiConstants.handymanPortfolio)
  Future<void> addPortfolio(
      @Body() AddPortfolioRequest request,
      );

  @DELETE(ApiConstants.handymanDeletePortfolio)
  Future<void> deletePortfolio(
      @Path('id') String id,
      );


}