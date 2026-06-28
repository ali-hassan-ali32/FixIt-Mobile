import 'package:injectable/injectable.dart';

import '../../api/services/handyman_api_service.dart';

import '../models/requests/add_portfolio_request.dart';
import '../models/requests/update_handyman_profile_request.dart';
import '../models/requests/update_job_status_request.dart';

import '../models/responses/handyman_portfolio_model.dart';
import '../models/responses/handyman_profile_model.dart';
import '../models/responses/handyman_job_summary_model.dart';
import '../models/responses/handyman_job_details_model.dart';
import '../models/responses/handyman_review_model.dart';

import '../models/responses/handyman_statistics_model.dart';
import 'handyman_remote_data_source.dart';

@Injectable(
  as: HandymanRemoteDataSource,
)
class HandymanRemoteDataSourceImpl
    implements HandymanRemoteDataSource {
  final HandymanApiService api;

  HandymanRemoteDataSourceImpl(
      this.api,
      );

  @override
  Future<HandymanProfileModel>
  getProfile() {
    return api.getProfile();
  }

  @override
  Future<void> updateProfile(
      UpdateHandymanProfileRequest request,
      ) {
    return api.updateProfile(
      request,
    );
  }

  @override
  Future<
      List<HandymanJobSummaryModel>>
  getJobs() {
    return api.getJobs();
  }

  @override
  Future<HandymanJobDetailsModel>
  getJobDetails(
      String id,
      ) {
    return api.getJobDetails(
      id,
    );
  }

  @override
  Future<void> updateJobStatus(
      String id,
      UpdateJobStatusRequest request,
      ) {
    return api.updateJobStatus(
      id,
      request,
    );
  }

  @override
  Future<
      List<HandymanReviewModel>>
  getReviews() {
    return api.getReviews();
  }

  @override
  Future<
      List<HandymanJobSummaryModel>>
  getAvailableRequests() {
    return api.getAvailableRequests();
  }


  @override
  Future<HandymanStatisticsModel> getStatistics() {
    return api.getStatistics();
  }

  @override
  Future<List<HandymanPortfolioModel>> getPortfolio() {
    return api.getPortfolio();
  }

  @override
  Future<void> addPortfolio(
      AddPortfolioRequest request,
      ) {
    return api.addPortfolio(request);
  }

  @override
  Future<void> deletePortfolio(
      String id,
      ) {
    return api.deletePortfolio(id);
  }
}