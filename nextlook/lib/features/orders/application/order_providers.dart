import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/order_model.dart';
import '../data/order_repository.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OrderRepository(dioClient);
});

/// FutureProvider that fetches the list of order summaries for current user
final ordersListProvider = FutureProvider<List<OrderSummary>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});

/// FutureProvider.family that fetches detail for a specific order ID
final orderDetailProvider =
    FutureProvider.family<OrderDetail, String>((ref, orderId) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrderDetail(orderId);
});
