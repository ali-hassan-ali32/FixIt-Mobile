import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';

import '../../domain/entities/auth_user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import '../datasource/auth_remote_data_source.dart';

import '../models/requests/login_request.dart';
import '../models/requests/register_customer_request.dart';
import '../models/requests/register_handyman_request.dart';
import '../models/requests/forgot_password_request.dart';
import '../models/requests/reset_password_request.dart';
import '../models/requests/verify_otp_request.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl
    implements AuthRepository {

  final AuthRemoteDataSource remote;
  final SecureStorageService storage;

  AuthRepositoryImpl(
      this.remote,
      this.storage,
      );

  @override
  Future<Either<Failure, AuthUser>>
  login(
      LoginRequest request,
      ) async {

    try {

      final response =
      await remote.login(request);

      await storage.saveToken(
        response.token,
      );

      await storage.saveRole(
        response.role,
      );

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        Failure(
          message:  e.response?.data?[
          'errorMessage'] ??
              'Login Failed',
        ),
      );

    } catch (e) {

      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, AuthUser>>
  registerCustomer(
      RegisterCustomerRequest request,
      ) async {

    try {

      final response =
      await remote.registerCustomer(
        request,
      );

      await storage.saveToken(
        response.token,
      );

      await storage.saveRole(
        response.role,
      );

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        Failure(
          message: e.response?.data?[
          'errorMessage'] ??
              'Registration Failed',
        ),
      );

    } catch (e) {

      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, AuthUser>>
  registerHandyman(
      RegisterHandymanRequest request,
      ) async {

    try {

      final response =
      await remote.registerHandyman(
        request,
      );

      await storage.saveToken(
        response.token,
      );

      await storage.saveRole(
        response.role,
      );

      return Right(
        response.toEntity(),
      );

    } on DioException catch (e) {

      return Left(
        Failure(
          message: e.response?.data?[
          'errorMessage'] ??
              'Registration Failed',
        ),
      );

    } catch (e) {

      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, String>>
  forgotPassword(
      ForgotPasswordRequest request,
      ) async {

    try {

      final response =
      await remote.forgotPassword(
        request,
      );

      return Right(
        response.message ??
            'Success',
      );

    } on DioException catch (e) {

      return Left(
        Failure(
          message: e.response?.data?[
          'errorMessage'] ??
              'Operation Failed',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>>
  resetPassword(
      ResetPasswordRequest request,
      ) async {

    try {

      final response =
      await remote.resetPassword(
        request,
      );

      return Right(
        response.message ??
            'Password Reset Successfully',
      );

    } on DioException catch (e) {

      return Left(
        Failure(
         message:  e.response?.data?[
         'errorMessage'] ??
             'Operation Failed',
        ),
      );
    }
  }
  @override
  Future<Either<Failure, String>>
  verifyOtp(
      VerifyOtpRequest request,
      ) async {

    try {

      final response =
      await remote.verifyOtp(
        request,
      );

      return Right(
        response.message ??
            'OTP verified',
      );

    } on DioException catch (e) {

      return Left(
        Failure(
          message:
          e.response?.data?[
          'ErrorMessage'] ??
              e.response?.data?[
              'errorMessage'] ??
              'OTP Verification Failed',
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