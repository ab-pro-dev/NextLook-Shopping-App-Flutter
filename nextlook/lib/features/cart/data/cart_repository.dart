import '../../../core/network/dio_client.dart';
import 'cart_models.dart';

class CartRepository {
  final DioClient _dioClient;

  CartRepository(this._dioClient);

  /// Fetch user's cart
  Future<CartSummary> getCart() async {
    final response = await _dioClient.get('/api/cart');
    return CartSummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Add item to cart
  Future<CartSummary> addToCart({
    required String productId,
    required String colorName,
    required String sizeLabel,
    required int quantity,
  }) async {
    final response = await _dioClient.post('/api/cart/items', data: {
      'productId': productId,
      'colorName': colorName,
      'sizeLabel': sizeLabel,
      'quantity': quantity,
    });
    return CartSummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update cart item quantity
  Future<CartSummary> updateQuantity(String cartItemId, int quantity) async {
    final response = await _dioClient.put('/api/cart/items/$cartItemId', data: {
      'quantity': quantity,
    });
    return CartSummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Remove line item from cart
  Future<CartSummary> removeItem(String cartItemId) async {
    final response = await _dioClient.delete('/api/cart/items/$cartItemId');
    return CartSummary.fromJson(response.data as Map<String, dynamic>);
  }

  /// Clear entire cart
  Future<CartSummary> clearCart() async {
    final response = await _dioClient.delete('/api/cart');
    return CartSummary.fromJson(response.data as Map<String, dynamic>);
  }
}
