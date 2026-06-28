import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/network/api_constants.dart';
import '../../data/models/notification_model.dart';

part 'notification_api_service.g.dart';

@RestApi()
abstract class NotificationApiService {
  factory NotificationApiService(
      Dio dio, {
        String baseUrl,
      }) = _NotificationApiService;

  @GET(ApiConstants.getNotifications)
  Future<List<NotificationModel>> getNotifications();

  @PUT(ApiConstants.readNotification)
  Future<void> markNotificationAsRead(@Path('id') String id,);

  @PUT(ApiConstants.readAllNotifications)
  Future<void> markAllNotificationsAsRead();

  @DELETE(ApiConstants.deleteNotification)
  Future<void> deleteNotification(@Path('id') String id,);
}