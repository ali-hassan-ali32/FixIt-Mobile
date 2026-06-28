import 'package:injectable/injectable.dart';

import '../../api/services/customer_api_service.dart';

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
import 'customer_remote_data_source.dart';

@Injectable(
  as: CustomerRemoteDataSource,
)
class CustomerRemoteDataSourceImpl
    implements
        CustomerRemoteDataSource {
  final CustomerApiService api;

  CustomerRemoteDataSourceImpl(
      this.api,
      );

  @override
  Future<CustomerProfileModel>
  getProfile() {
    return api.getProfile();
  }

  @override
  Future<String> updateProfile(
      UpdateProfileRequest request,
      ) {
    return api.updateProfile(request);
  }

  @override
  Future<
      List<
          CustomerRequestSummaryModel>>
  getRequests() {
    return api.getRequests();
  }

  @override
  Future<String> createRequest(
      CreateServiceRequest request,
      ) {
    return api.createRequest(
      request,
    );
  }

  @override
  Future<CustomerRequestDetailsModel>
  getRequestDetails(
      String id,
      ) {
    return api.getRequestDetails(
      id,
    );
  }

  @override
  Future<void> cancelRequest(
      String id,
      ) {
    return api.cancelRequest(
      id,
    );
  }

  @override
  Future<CustomerStatisticsModel>
  getStatistics() {
    return api.getStatistics();
  }


  @override
  Future<List<HandymanListModel>> getHandymen({
    String? search,
    String? categoryId,
    bool? availableOnly,
  }) {
    return api.getHandymen(
      search: search,
      categoryId: categoryId,
      availableOnly: availableOnly,
    );
  }

  @override
  Future<List<HandymanListModel>> getFeaturedHandymen() {
    return api.getFeaturedHandymen();
  }

  @override
  Future<HandymanDetailsModel> getHandymanDetails(
      String handymanId,
      ) {
    return api.getHandymanDetails(
      handymanId,
    );
  }

  @override
  Future<List<PortfolioItemModel>> getHandymanPortfolio(
      String handymanId,
      ) {
    return api.getHandymanPortfolio(
      handymanId,
    );
  }



  @override
  Future<List<ReviewModel>> getHandymanReviews(
      String handymanId,
      ) {
    return api.getHandymanReviews(
      handymanId,
    );
  }

  @override
  Future<void> addReview(
      String requestId,
      ReviewRequest request,
      ) {
    return api.addReview(
      requestId,
      request,
    );
  }

  @override
  Future<List<ReviewModel>> getMyReviews() {
    return api.getMyReviews();
  }
}