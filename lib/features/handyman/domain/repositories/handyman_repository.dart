import 'package:dartz/dartz.dart';

import '../../../../core/network/failure.dart';

import '../../data/models/requests/add_portfolio_request.dart';
import '../entities/handyman_portfolio_entity.dart';
import '../entities/handyman_profile_entity.dart';
import '../entities/handyman_job_summary_entity.dart';
import '../entities/handyman_job_details_entity.dart';
import '../entities/handyman_review_entity.dart';

import '../../data/models/requests/update_handyman_profile_request.dart';
import '../../data/models/requests/update_job_status_request.dart';
import '../entities/handyman_statistics_entity.dart';

abstract class HandymanRepository {
  Future<
      Either<
          Failure,
          HandymanProfileEntity>>
  getProfile();

  Future<Either<Failure, void>>
  updateProfile(
      UpdateHandymanProfileRequest request,
      );

  Future<
      Either<
          Failure,
          List<HandymanJobSummaryEntity>>>
  getJobs();

  Future<
      Either<
          Failure,
          HandymanJobDetailsEntity>>
  getJobDetails(
      String id,
      );

  Future<Either<Failure, void>>
  updateJobStatus(
      String id,
      UpdateJobStatusRequest request,
      );

  Future<
      Either<
          Failure,
          List<HandymanReviewEntity>>>
  getReviews();

  Future<
      Either<
          Failure,
          List<HandymanJobSummaryEntity>>>
  getAvailableRequests();

  Future<Either<Failure, HandymanStatisticsEntity>>
  getStatistics();

  Future<Either<Failure, List<HandymanPortfolioEntity>>>
  getPortfolio();

  Future<Either<Failure, void>>
  addPortfolio(
      AddPortfolioRequest request,
      );

  Future<Either<Failure, void>>
  deletePortfolio(
      String id,
      );

}