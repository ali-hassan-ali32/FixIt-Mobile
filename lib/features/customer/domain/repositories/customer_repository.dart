import 'package:dartz/dartz.dart';

import '../../../../core/network/failure.dart';

import '../entities/customer_profile_entity.dart';
import '../entities/customer_request_details_entity.dart';
import '../entities/customer_request_summary_entity.dart';
import '../entities/customer_statistics_entity.dart';

import '../../data/models/requests/create_service_request.dart';
import '../../data/models/requests/update_profile_request.dart';

abstract class CustomerRepository {
  Future<
      Either<
          Failure,
          CustomerProfileEntity>>
  getProfile();

  Future<Either<Failure, String>>
  updateProfile(
      UpdateProfileRequest request,
      );

  Future<
      Either<
          Failure,
          List<
              CustomerRequestSummaryEntity>>>
  getRequests();

  Future<Either<Failure, String>>
  createRequest(
      CreateServiceRequest request,
      );

  Future<
      Either<
          Failure,
          CustomerRequestDetailsEntity>>
  getRequestDetails(
      String id,
      );

  Future<Either<Failure, void>>
  cancelRequest(
      String id,
      );

  Future<
      Either<
          Failure,
          CustomerStatisticsEntity>>
  getStatistics();
}