import 'package:aarogivya/core/utils/firestore_values.dart';

enum AppNotificationType {
  appointment,
  medicine,
  record,
  system,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.route,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? route;

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      title: FirestoreValues.string(map['title'], 'Notification'),
      body: FirestoreValues.string(map['body']),
      type: AppNotificationType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => AppNotificationType.system,
      ),
      createdAt: FirestoreValues.date(map['createdAt']),
      isRead: FirestoreValues.boolean(map['isRead']),
      route: map['route'] as String?,
    );
  }
}
