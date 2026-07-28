import '../../../core/network/dio_client.dart';
import 'order_model.dart';

class OrderRepository {
  final DioClient _dioClient;

  OrderRepository(this._dioClient);

  /// Create a new order via POST /api/orders
  /// Sends deliveryMethod identifier (e.g. 'standard' or 'express')
  Future<OrderDetail> createOrder({
    required String addressId,
    required String deliveryMethod,
    required String paymentMethod,
    String? deliveryMethodLabel,
    double? deliveryMethodPrice,
  }) async {
    final Map<String, dynamic> body = {
      'addressId': addressId,
      'deliveryMethod': deliveryMethod,
      'paymentMethod': paymentMethod,
    };

    if (deliveryMethodLabel != null) {
      body['deliveryMethodLabel'] = deliveryMethodLabel;
    }
    if (deliveryMethodPrice != null) {
      body['deliveryMethodPrice'] = deliveryMethodPrice.round();
    }

    final response = await _dioClient.post(
      '/api/orders',
      data: body,
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
