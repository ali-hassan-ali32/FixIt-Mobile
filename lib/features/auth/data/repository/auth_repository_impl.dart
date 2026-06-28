import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fix_it/features/auth/data/models/responses/message_response_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/storage/secure_storage_service.dart';

import '../../../../core/utils/functions/extract_error_message.dart';
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
class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDataSource remote;
  final SecureStorageService storage;

  AuthRepositoryImpl(this.remote, this.storage,);

  @override
  Future<Either<Failure, AuthUser>> login(LoginRequest request,) async {
    try {
      final response = await remote.login(request);

      await storage.saveToken(response.token);
      await storage.saveRole(response.role);

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Login failed. Please check your credentials.',
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
  Future<Either<Failure, AuthUser>> registerCustomer(
      RegisterCustomerRequest request,
      ) async {
    try {
      final response = await remote.registerCustomer(request);

      await storage.saveToken(response.token);
      await storage.saveRole(response.role);

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Customer registration failed.',
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
  Future<Either<Failure, AuthUser>> registerHandyman(
      RegisterHandymanRequest request,
      ) async {
    try {
      final response = await remote.registerHandyman(request);

      await storage.saveToken(response.token);
      await storage.saveRole(response.role);

      return Right(response.toEntity());
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Handyman registration failed.',
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
  Future<Either<Failure, MessageResponseModel>> forgotPassword(
      ForgotPasswordRequest request,
      ) async {
    try {
      final response = await remote.forgotPassword(request);

      return Right(
        MessageResponseModel(
          message: response.message ?? 'OTP sent successfully.',
          token: response.token,
        ),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(e, 'Failed to send OTP code.',),
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
  Future<Either<Failure, String>> resetPassword(
      ResetPasswordRequest request,
      ) async {
    try {
      final response = await remote.resetPassword(request);

      return Right(
        response.message ?? 'Password reset successfully.',
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to reset password.',
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
  Future<Either<Failure, String>> verifyOtp(
      VerifyOtpRequest request,
      ) async {
    try {
      final response = await remote.verifyOtp(request);

      return Right(
        response.message ?? 'OTP verified successfully.',
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'OTP verification failed.',
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

}