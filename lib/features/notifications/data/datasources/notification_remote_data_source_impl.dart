import 'package:injectable/injectable.dart';

import '../../api/services/notification_api_service.dart';
import '../models/notification_model.dart';
import 'notification_remote_data_source.dart';

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NotificationApiService api;

  NotificationRemoteDataSourceImpl(this.api);

  @override
  Future<List<NotificationModel>> getNotifications() {
    return api.getNotifications();
  }

  @override
  Future<void> markNotificationAsRead(
      String id,
      ) {
    return api.markNotificationAsRead(id);
  }

  @override
  Future<void> markAllNotificationsAsRead() {
    return api.markAllNotificationsAsRead();
  }

  @override
  Future<void> deleteNotification(
      String id,
      ) {
    return api.deleteNotification(id);
  }
}