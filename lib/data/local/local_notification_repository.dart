import 'dart:async';
import 'package:aarogivya/features/notifications/domain/entities/app_notification.dart';
import 'package:aarogivya/features/notifications/domain/repositories/notification_repository.dart';

class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository() {
    _initNotifications();
  }

  final _notificationsController = StreamController<List<AppNotification>>.broadcast();
  final List<AppNotification> _notifications = [];

  void _initNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      AppNotification(
        id: 'notif_1',
        title: 'Welcome to Aarogivya!',
        body: 'Your all-in-one healthcare companion. Book appointments, order medicines, and track records with ease.',
        type: AppNotificationType.system,
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Upcoming Appointment',
        body: 'Consultation with Dr. Priya Sharma is scheduled for tomorrow at 10:00 AM.',
        type: AppNotificationType.appointment,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Medicine Order Delivered',
        body: 'Order #order_1001 containing Paracetamol and Vitamin D3 has been delivered.',
        type: AppNotificationType.medicine,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ]);
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) async* {
    yield List<AppNotification>.from(_notifications);
    yield* _notificationsController.stream.map((list) => List<AppNotification>.from(list));
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final old = _notifications[index];
      _notifications[index] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        type: old.type,
        createdAt: old.createdAt,
        isRead: true,
        route: old.route,
      );
      _notificationsController.add(_notifications);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    for (var i = 0; i < _notifications.length; i++) {
      final old = _notifications[i];
      _notifications[i] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        type: old.type,
        createdAt: old.createdAt,
        isRead: true,
        route: old.route,
      );
    }
    _notificationsController.add(_notifications);
  }
}
