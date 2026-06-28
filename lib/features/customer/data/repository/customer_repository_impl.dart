import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../../../core/utils/functions/extract_error_message.dart';
import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/entities/customer_request_details_entity.dart';
import '../../domain/entities/customer_request_summary_entity.dart';
import '../../domain/entities/customer_statistics_entity.dart';

import '../../domain/entities/handyman_details_entity.dart';
import '../../domain/entities/handyman_list_entity.dart';
import '../../domain/entities/portfolio_item_entity.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/customer_repository.dart';

import '../datasource/customer_remote_data_source.dart';

import '../models/requests/create_service_request.dart';
import '../models/requests/review_request.dart';
import '../models/requests/update_profile_request.dart';

@Injectable(
  as: CustomerRepository,
)
class CustomerRepositoryImpl
    implements CustomerRepository {
  final CustomerRemoteDataSource remote;

  CustomerRepositoryImpl(
      this.remote,
      );

  @override
  Future<
      Either<
          Failure,
          CustomerProfileEntity>>
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
          message: extractErrorMessage(
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
  Future<Either<Failure, String>>
  updateProfile(
      UpdateProfileRequest request,
      ) async {
    try {
      final response =
      await remote.updateProfile(request);

      return Right(response);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
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
          List<
              CustomerRequestSummaryEntity>>>
  getRequests() async {
    try {
      final response =
      await remote.getRequests();

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
          message: extractErrorMessage(
            e,
            'Failed to load requests.',
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
  Future<Either<Failure, String>>
  createRequest(
      CreateServiceRequest request,
      ) async {
    try {
      final response =
      await remote.createRequest(
        request,
      );

      return Right(response);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to create request.',
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
          CustomerRequestDetailsEntity>>
  getRequestDetails(
      String id,
      ) async {
    try {
      final response =
      await remote
          .getRequestDetails(
        id,
      );

      return Right(
        response.toEntity(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load request details.',
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
  cancelRequest(
      String id,
      ) async {
    try {
      await remote.cancelRequest(
        id,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to cancel request.',
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
          CustomerStatisticsEntity>>
  getStatistics() async {
    try {
      final response =
      await remote
          .getStatistics();

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
  Future<Either<Failure, List<PortfolioItemEntity>>>
  getHandymanPortfolio(
      String handymanId,
      ) async {
    try {
      final response =
      await remote.getHandymanPortfolio(
        handymanId,
      );

      return Right(
        response.map((e) => e.toEntity()).toList(),
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
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }


  @override
  Future<Either<Failure, HandymanDetailsEntity>>
  getHandymanDetails(
      String handymanId,
      ) async {
    try {
      final response =
      await remote.getHandymanDetails(
        handymanId,
      );

      return Right(
        response.toEntity(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load handyman details.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<HandymanListEntity>>>
  getFeaturedHandymen() async {
    try {
      final response =
      await remote.getFeaturedHandymen();

      return Right(
        response.map((e) => e.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load featured handymen.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<HandymanListEntity>>> getHandymen({
    String? search,
    String? categoryId,
    bool? availableOnly,
  }) async {
    try {
      final response = await remote.getHandymen(
        search: search,
        categoryId: categoryId,
        availableOnly: availableOnly,
      );

      return Right(
        response.map((e) => e.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load handymen.',
          ),
        ),
      );
    } catch (_) {
      return const Left(
        Failure(
          message: 'Something went wrong. Please try again.',
        ),
      );
    }
  }


  @override
  Future<Either<Failure, List<ReviewEntity>>>
  getHandymanReviews(
      String handymanId,
      ) async {
    try {
      final response =
      await remote.getHandymanReviews(
        handymanId,
      );

      return Right(
        response.map((e) => e.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
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
  Future<Either<Failure, void>>
  addReview(
      String requestId,
      ReviewRequest request,
      ) async {
    try {
      await remote.addReview(
        requestId,
        request,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to add review.',
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
  Future<Either<Failure, List<ReviewEntity>>>
  getMyReviews() async {
    try {
      final response =
      await remote.getMyReviews();

      return Right(
        response.map((e) => e.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
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
}