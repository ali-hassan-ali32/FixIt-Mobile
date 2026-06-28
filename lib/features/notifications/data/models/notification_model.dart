import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/notification_entity.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String? id;
  final String? title;
  final String? message;
  final int? type;
  final bool? isRead;
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    this.title,
    this.message,
    this.type,
    this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationModelToJson(this);

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id ?? 'unknown',
      title: title ?? 'إشعار',
      message: message ?? 'لديك إشعار جديد.',
      type: type ?? 0,
      isRead: isRead ?? false,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}