import '../../../core/network/dio_client.dart';
import 'order_model.dart';

class OrderRepository {
  final DioClient _dioClient;

  OrderRepository(this._dioClient);

  /// Create a new order via POST /api/orders
  Future<OrderDetail> createOrder({
    required String addressId,
    required String deliveryMethodLabel,
    required double deliveryMethodPrice,
    required String paymentMethod,
  }) async {
    final response = await _dioClient.post(
      '/api/orders',
      data: {
        'addressId': addressId,
        'deliveryMethodLabel': deliveryMethodLabel,
        'deliveryMethodPrice': deliveryMethodPrice.round(),
        'paymentMethod': paymentMethod,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return OrderDetail.fromJson(data);
  }

  /// Get list of user order summaries via GET /api/orders
  Future<List<OrderSummary>> getOrders() async {
    final response = await _dioClient.get('/api/orders');
    final rawList = response.data as List<dynamic>;
    return rawList
        .map((item) => OrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get detailed order by ID via GET /api/orders/:id
  Future<OrderDetail> getOrderDetail(String orderId) async {
    final response = await _dioClient.get('/api/orders/$orderId');
    final data = response.data as Map<String, dynamic>;
    return OrderDetail.fromJson(data);
  }

  /// Alias for backward compatibility
  Future<OrderDetail> getOrderById(String orderId) => getOrderDetail(orderId);
}
