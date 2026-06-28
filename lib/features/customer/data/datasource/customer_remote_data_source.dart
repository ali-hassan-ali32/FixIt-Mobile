import '../models/requests/create_service_request.dart';
import '../models/requests/review_request.dart';
import '../models/requests/update_profile_request.dart';

import '../models/responses/customer_profile_model.dart';
import '../models/responses/customer_request_details_model.dart';
import '../models/responses/customer_request_summary_model.dart';
import '../models/responses/customer_statistics_model.dart';
import '../models/responses/handyman_details_model.dart';
import '../models/responses/handyman_list_model.dart';
import '../models/responses/portfolio_item_model.dart';
import '../models/responses/review_model.dart';


abstract class CustomerRemoteDataSource {
  Future<CustomerProfileModel>
  getProfile();

  Future<String> updateProfile(
      UpdateProfileRequest request,
      );

  Future<
      List<
          CustomerRequestSummaryModel>>
  getRequests();

  Future<String> createRequest(
      CreateServiceRequest request,
      );

  Future<CustomerRequestDetailsModel>
  getRequestDetails(
      String id,
      );

  Future<void> cancelRequest(
      String id,
      );

  Future<CustomerStatisticsModel>
  getStatistics();


  Future<List<HandymanListModel>> getHandymen({
    String? search,
    String? categoryId,
    bool? availableOnly,
  });

  Future<List<HandymanListModel>> getFeaturedHandymen();

  Future<HandymanDetailsModel> getHandymanDetails(
      String handymanId,
      );

  Future<List<PortfolioItemModel>> getHandymanPortfolio(
      String handymanId,
      );


  Future<List<ReviewModel>> getHandymanReviews(
      String handymanId,
      );

  Future<void> addReview(
      String requestId,
      ReviewRequest request,
      );

  Future<List<ReviewModel>> getMyReviews();
}