import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();

  Future<void> markNotificationAsRead(
      String id,
      );

  Future<void> markAllNotificationsAsRead();

  Future<void> deleteNotification(
      String id,
      );
}