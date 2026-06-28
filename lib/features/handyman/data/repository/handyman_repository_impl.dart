import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/utils/functions/extract_error_message.dart';

import '../../domain/entities/handyman_portfolio_entity.dart';
import '../../domain/entities/handyman_profile_entity.dart';
import '../../domain/entities/handyman_job_summary_entity.dart';
import '../../domain/entities/handyman_job_details_entity.dart';
import '../../domain/entities/handyman_review_entity.dart';

import '../../domain/entities/handyman_statistics_entity.dart';
import '../../domain/repositories/handyman_repository.dart';

import '../datasource/handyman_remote_data_source.dart';

import '../models/requests/add_portfolio_request.dart';
import '../models/requests/update_handyman_profile_request.dart';
import '../models/requests/update_job_status_request.dart';

@Injectable(
  as: HandymanRepository,
)
class HandymanRepositoryImpl
    implements HandymanRepository {
  final HandymanRemoteDataSource remote;

  HandymanRepositoryImpl(
      this.remote,
      );

  @override
  Future<
      Either<
          Failure,
          HandymanProfileEntity>>
  getProfile() async {
    try {
      final response =
      await remote.getProfile();

      return Right(
        response.toEntity(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to get profile.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>>
  updateProfile(
      UpdateHandymanProfileRequest request,
      ) async {
    try {
      await remote.updateProfile(
        request,
      );

      return const Right(
        null,
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to update profile.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<
      Either<
          Failure,
          List<HandymanJobSummaryEntity>>>
  getJobs() async {
    try {
      final response =
      await remote.getJobs();

      return Right(
        response
            .map(
              (e) =>
              e.toEntity(),
        )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to load jobs.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<
      Either<
          Failure,
          HandymanJobDetailsEntity>>
  getJobDetails(
      String id,
      ) async {
    try {
      final response =
      await remote.getJobDetails(
        id,
      );

      return Right(
        response.toEntity(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to load job details.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>>
  updateJobStatus(
      String id,
      UpdateJobStatusRequest request,
      ) async {
    try {
      await remote.updateJobStatus(
        id,
        request,
      );

      return const Right(
        null,
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to update job status.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<
      Either<
          Failure,
          List<HandymanReviewEntity>>>
  getReviews() async {
    try {
      final response =
      await remote.getReviews();

      return Right(
        response
            .map(
              (e) =>
              e.toEntity(),
        )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to load reviews.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<
      Either<
          Failure,
          List<HandymanJobSummaryEntity>>>
  getAvailableRequests() async {
    try {
      final response =
      await remote
          .getAvailableRequests();

      return Right(
        response
            .map(
              (e) =>
              e.toEntity(),
        )
            .toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message:
          extractErrorMessage(
            e,
            'Failed to load available requests.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }


  @override
  Future<Either<Failure, HandymanStatisticsEntity>>
  getStatistics() async {
    try {
      final response = await remote.getStatistics();

      return Right(
        response.toEntity(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load statistics.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<HandymanPortfolioEntity>>>
  getPortfolio() async {
    try {
      final response = await remote.getPortfolio();

      return Right(
        response
            .map((e) => e.toEntity())
            .toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load portfolio.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>>
  addPortfolio(
      AddPortfolioRequest request,
      ) async {
    try {
      await remote.addPortfolio(request);

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to add portfolio item.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>>
  deletePortfolio(
      String id,
      ) async {
    try {
      await remote.deletePortfolio(id);

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to delete portfolio item.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message:
          'Something went wrong. Please try again.',
        ),
      );
    }
  }
}