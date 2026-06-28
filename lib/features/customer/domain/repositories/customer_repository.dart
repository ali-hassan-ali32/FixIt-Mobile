import 'package:dartz/dartz.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/review_request.dart';
import '../entities/customer_profile_entity.dart';
import '../entities/customer_request_details_entity.dart';
import '../entities/customer_request_summary_entity.dart';
import '../entities/customer_statistics_entity.dart';

import '../../data/models/requests/create_service_request.dart';
import '../../data/models/requests/update_profile_request.dart';
import '../entities/handyman_details_entity.dart';
import '../entities/handyman_list_entity.dart';
import '../entities/portfolio_item_entity.dart';
import '../entities/review_entity.dart';

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

  Future<Either<Failure, List<HandymanListEntity>>> getHandymen({
    String? search,
    String? categoryId,
    bool? availableOnly,
  });

  Future<Either<Failure, List<HandymanListEntity>>> getFeaturedHandymen();

  Future<Either<Failure, HandymanDetailsEntity>> getHandymanDetails(
      String handymanId,
      );

  Future<Either<Failure, List<PortfolioItemEntity>>> getHandymanPortfolio(String handymanId,);


  Future<Either<Failure, List<ReviewEntity>>>
  getHandymanReviews(
      String handymanId,
      );

  Future<Either<Failure, void>>
  addReview(
      String requestId,
      ReviewRequest request,
      );

  Future<Either<Failure, List<ReviewEntity>>>
  getMyReviews();
}