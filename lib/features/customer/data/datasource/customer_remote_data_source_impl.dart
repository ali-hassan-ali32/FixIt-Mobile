import 'package:injectable/injectable.dart';

import '../../api/services/customer_api_service.dart';

import '../models/requests/create_service_request.dart';
import '../models/requests/update_profile_request.dart';

import '../models/responses/customer_profile_model.dart';
import '../models/responses/customer_request_details_model.dart';
import '../models/responses/customer_request_summary_model.dart';
import '../models/responses/customer_statistics_model.dart';

import '../../../auth/data/models/responses/message_response_model.dart';

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
}