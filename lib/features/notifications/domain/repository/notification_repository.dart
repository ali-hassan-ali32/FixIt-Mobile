import 'package:dartz/dartz.dart';

import '../../../../core/network/failure.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>>
  getNotifications();

  Future<Either<Failure, void>>
  markNotificationAsRead(
      String id,
      );

  Future<Either<Failure, void>>
  markAllNotificationsAsRead();

  Future<Either<Failure, void>>
  deleteNotification(
      String id,
      );
}