import '../../../core/network/dio_client.dart';
import '../../products/data/product_card_model.dart';

class WishlistRepository {
  final DioClient _dioClient;

  WishlistRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Fetches current user's wishlist products.
  Future<List<ProductCard>> getWishlist() async {
    final response = await _dioClient.dio.get('/api/wishlist');
    final data = response.data;
    final List<dynamic> productsJson = (data is Map<String, dynamic>)
        ? (data['products'] as List<dynamic>?) ?? []
        : (data as List<dynamic>?) ?? [];

    return productsJson
        .map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Adds product to current user's wishlist.
  Future<void> addToWishlist(String productId) async {
    await _dioClient.dio.post('/api/wishlist/$productId');
  }

  /// Removes product from current user's wishlist.
  Future<void> removeFromWishlist(String productId) async {
    await _dioClient.dio.delete('/api/wishlist/$productId');
  }
}
