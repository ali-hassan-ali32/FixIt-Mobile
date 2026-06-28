import '../models/requests/add_portfolio_request.dart';
import '../models/requests/update_handyman_profile_request.dart';
import '../models/requests/update_job_status_request.dart';

import '../models/responses/handyman_portfolio_model.dart';
import '../models/responses/handyman_profile_model.dart';
import '../models/responses/handyman_job_summary_model.dart';
import '../models/responses/handyman_job_details_model.dart';
import '../models/responses/handyman_review_model.dart';
import '../models/responses/handyman_statistics_model.dart';

abstract class HandymanRemoteDataSource {
  Future<HandymanProfileModel>
  getProfile();

  Future<void> updateProfile(
      UpdateHandymanProfileRequest request,
      );

  Future<
      List<HandymanJobSummaryModel>>
  getJobs();

  Future<HandymanJobDetailsModel>
  getJobDetails(
      String id,
      );

  Future<void> updateJobStatus(
      String id,
      UpdateJobStatusRequest request,
      );

  Future<
      List<HandymanReviewModel>>
  getReviews();

  Future<
      List<HandymanJobSummaryModel>>
  getAvailableRequests();



  Future<HandymanStatisticsModel> getStatistics();

  Future<List<HandymanPortfolioModel>> getPortfolio();

  Future<void> addPortfolio(
      AddPortfolioRequest request,
      );

  Future<void> deletePortfolio(
      String id,
      );
}