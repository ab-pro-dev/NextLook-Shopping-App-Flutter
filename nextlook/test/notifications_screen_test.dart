import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/features/notifications/presentation/notifications_screen.dart';
import 'package:nextlook/features/notifications/application/notification_providers.dart';
import 'package:nextlook/features/notifications/data/notification_model.dart';
import 'package:nextlook/features/notifications/data/notification_repository.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/user_model.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';

class FakeAuthController extends AuthController {
  FakeAuthController(AuthState initialState) : super(FakeAuthRepository()) {
    state = initialState;
  }
}

class FakeAuthRepository extends AuthRepository {}

const testUser = User(id: 'u1', email: 'test@example.com', name: 'Alex Johnson');

void main() {
  final sampleNotifications = [
    AppNotification(
      id: 'notif-1',
      type: 'ORDER_UPDATE',
      title: 'Order Placed',
      body: 'Your order #NLZK6Y7L has been confirmed',
      isRead: false,
      relatedOrderId: 'order-1',
      createdAt: DateTime.now(),
    ),
    AppNotification(
      id: 'notif-2',
      type: 'PROMOTION',
      title: 'Summer Sale!',
      body: 'Get up to 50% off on selected items',
      isRead: true,
      relatedOrderId: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders title, Mark all read button, and notification list items', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            notificationsNotifierProvider.overrideWith(() => FakeNotificationsNotifier(sampleNotifications)),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byKey(const Key('mark_all_read_button')), findsOneWidget);
      expect(find.text('Order Placed'), findsOneWidget);
      expect(find.text('Your order #NLZK6Y7L has been confirmed'), findsOneWidget);
      expect(find.text('Summer Sale!'), findsOneWidget);
      expect(find.text('Get up to 50% off on selected items'), findsOneWidget);
    });

    testWidgets('renders empty state when notifications list is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            notificationsNotifierProvider.overrideWith(() => FakeNotificationsNotifier([])),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Notifications Yet'), findsOneWidget);
      expect(find.byKey(const Key('mark_all_read_button')), findsNothing);
    });

    testWidgets('renders retry button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => FakeAuthController(const AuthAuthenticated(testUser))),
            notificationsNotifierProvider.overrideWith(() => FakeErrorNotificationsNotifier()),
          ],
          child: const MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load notifications'), findsOneWidget);
      expect(find.byKey(const Key('notifications_retry_button')), findsOneWidget);
    });
  });
}

class FakeNotificationsNotifier extends NotificationsNotifier {
  final List<AppNotification> initialList;
  FakeNotificationsNotifier(this.initialList);

  @override
  Future<List<AppNotification>> build() async {
    return initialList;
  }
}

class FakeErrorNotificationsNotifier extends NotificationsNotifier {
  @override
  Future<List<AppNotification>> build() async {
    throw Exception('Network error');
  }
}

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> getNotifications() async => [];

  @override
  Future<AppNotification> markAsRead(String id) async => throw UnimplementedError();

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<int> getUnreadCount() async => 0;
}
