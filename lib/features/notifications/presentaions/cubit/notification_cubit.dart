import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase
  markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase
  markAllNotificationsAsReadUseCase;
  final DeleteNotificationUseCase
  deleteNotificationUseCase;

  NotificationCubit(
      this.getNotificationsUseCase,
      this.markNotificationAsReadUseCase,
      this.markAllNotificationsAsReadUseCase,
      this.deleteNotificationUseCase,
      ) : super(const NotificationState.initial());

  List<NotificationEntity> notifications = [];

  Future<void> getNotifications() async {
    emit(const NotificationState.loading());

    final result = await getNotificationsUseCase();

    result.fold(
          (failure) => emit(
        NotificationState.error(
          failure.message,
        ),
      ),
          (data) {
        notifications = data;

        emit(
          NotificationState.loaded(data),
        );
      },
    );
  }

  Future<void> markNotificationAsRead(
      String id,
      ) async {
    final result =
    await markNotificationAsReadUseCase(id);

    result.fold(
          (failure) => emit(
        NotificationState.error(
          failure.message,
        ),
      ),
          (_) async {
        await getNotifications();
      },
    );
  }

  Future<void> markAllNotificationsAsRead() async {
    final result =
    await markAllNotificationsAsReadUseCase();

    result.fold(
          (failure) => emit(
        NotificationState.error(
          failure.message,
        ),
      ),
          (_) async {
        await getNotifications();
      },
    );
  }

  Future<void> deleteNotification(
      String id,
      ) async {
    final result =
    await deleteNotificationUseCase(id);

    result.fold(
          (failure) => emit(
        NotificationState.error(
          failure.message,
        ),
      ),
          (_) async {
        await getNotifications();
      },
    );
  }
}