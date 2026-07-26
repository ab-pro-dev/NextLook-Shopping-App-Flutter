import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/notification_model.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRepository(dioClient);
});

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    final repository = ref.watch(notificationRepositoryProvider);
    return repository.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);

    // Optimistically update local state
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) {
          if (n.id == id) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList(),
      );
    });

    try {
      await repository.markAsRead(id);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);

    // Optimistically update local state
    state.whenData((notifications) {
      state = AsyncValue.data(
        notifications.map((n) => n.copyWith(isRead: true)).toList(),
      );
    });

    try {
      await repository.markAllAsRead();
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  Future<void> refreshNotifications() async {
    ref.invalidateSelf();
  }
}

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(() {
  return NotificationsNotifier();
});

/// Derived provider computing count of unread notifications (isRead == false)
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsNotifierProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
