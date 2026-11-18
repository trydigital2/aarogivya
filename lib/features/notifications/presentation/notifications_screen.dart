import 'package:aarogivya/core/theme/app_spacing.dart';
import 'package:aarogivya/core/utils/app_formatters.dart';
import 'package:aarogivya/core/utils/firebase_error_mapper.dart';
import 'package:aarogivya/core/widgets/empty_view.dart';
import 'package:aarogivya/core/widgets/error_view.dart';
import 'package:aarogivya/core/widgets/loading_view.dart';
import 'package:aarogivya/features/auth/presentation/providers/auth_provider.dart';
import 'package:aarogivya/features/notifications/domain/entities/app_notification.dart';
import 'package:aarogivya/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.appointment:
        return Icons.calendar_month_outlined;
      case AppNotificationType.medicine:
        return Icons.medication_outlined;
      case AppNotificationType.record:
        return Icons.folder_shared_outlined;
      case AppNotificationType.system:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final repository = context.read<NotificationRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () => repository.markAllAsRead(user.uid),
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: repository.watchNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return ErrorView(message: mapFirebaseError(snapshot.error!).message);
          }
          final notifications = snapshot.data ?? const <AppNotification>[];
          if (notifications.isEmpty) {
            return const EmptyView(
              title: 'You’re all caught up',
              message: 'Appointment and order updates will appear here.',
              icon: Icons.notifications_none_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _iconFor(notification.type),
                      color: notification.isRead
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(notification.body),
                  trailing: Text(
                    AppFormatters.time(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      repository.markAsRead(user.uid, notification.id);
                    }
                    final route = notification.route;
                    if (route != null && route.isNotEmpty) context.go(route);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
