import '../models/requests/create_service_request.dart';
import '../models/requests/update_profile_request.dart';

import '../models/responses/customer_profile_model.dart';
import '../models/responses/customer_request_details_model.dart';
import '../models/responses/customer_request_summary_model.dart';
import '../models/responses/customer_statistics_model.dart';

import '../../../auth/data/models/responses/message_response_model.dart';

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
}