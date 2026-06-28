import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../../../../core/utils/functions/extract_error_message.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl
    implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getNotifications() async {
    try {
      final response = await remote.getNotifications();

      return Right(
        response.map((e) => e.toEntity()).toList(),
      );
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to load notifications.',
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
  markNotificationAsRead(
      String id,
      ) async {
    try {
      await remote.markNotificationAsRead(id);

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to mark notification as read.',
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
  markAllNotificationsAsRead() async {
    try {
      await remote.markAllNotificationsAsRead();

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to mark all notifications as read.',
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
  deleteNotification(
      String id,
      ) async {
    try {
      await remote.deleteNotification(id);

      return const Right(null);
    } on DioException catch (e) {
      return Left(
        Failure(
          message: extractErrorMessage(
            e,
            'Failed to delete notification.',
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