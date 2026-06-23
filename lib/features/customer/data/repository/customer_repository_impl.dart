import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';

import '../../domain/entities/customer_profile_entity.dart';
import '../../domain/entities/customer_request_details_entity.dart';
import '../../domain/entities/customer_request_summary_entity.dart';
import '../../domain/entities/customer_statistics_entity.dart';

import '../../domain/repositories/customer_repository.dart';

import '../datasource/customer_remote_data_source.dart';

import '../models/requests/create_service_request.dart';
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Get Profile',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Update Profile',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Get Requests',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Create Request',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Get Request Details',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Cancel Request',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
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
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              'Failed To Get Statistics',
        ),
      );
    } catch (e) {
      return Left(
        Failure(
          message: e.toString(),
        ),
      );
    }
  }
}