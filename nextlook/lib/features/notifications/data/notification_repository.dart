import '../../../core/network/dio_client.dart';
import 'notification_model.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository(this._dioClient);

  /// Fetch list of notifications for current user
  Future<List<AppNotification>> getNotifications() async {
    final response = await _dioClient.get('/api/notifications');
    final rawList = response.data as List<dynamic>;
    return rawList
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mark single notification as read
  Future<AppNotification> markAsRead(String id) async {
    final response = await _dioClient.put('/api/notifications/$id/read');
    return AppNotification.fromJson(response.data as Map<String, dynamic>);
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _dioClient.put('/api/notifications/read-all');
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount() async {
    final response = await _dioClient.get('/api/notifications/unread-count');
    final data = response.data as Map<String, dynamic>;
    return (data['count'] as num).toInt();
  }
}
