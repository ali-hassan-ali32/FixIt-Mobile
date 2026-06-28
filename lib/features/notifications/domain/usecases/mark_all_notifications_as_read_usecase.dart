import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/failure.dart';
import '../repository/notification_repository.dart';

@injectable
class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.markAllNotificationsAsRead();
  }
}