import 'package:aarogivya/features/notifications/domain/entities/app_notification.dart';

abstract interface class NotificationRepository {
  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<void> markAsRead(String userId, String notificationId);

  Future<void> markAllAsRead(String userId);
}
