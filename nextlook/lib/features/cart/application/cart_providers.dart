import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CartRepository(dioClient);
});

class CartNotifier extends AsyncNotifier<CartSummary> {
  late final CartRepository _repository;

  @override
  Future<CartSummary> build() async {
    final authState = ref.watch(authControllerProvider);
    _repository = ref.watch(cartRepositoryProvider);

    if (authState is! AuthAuthenticated) {
      return CartSummary.empty();
    }

    return await _repository.getCart();
  }

  /// Add item to cart and update state on success
  Future<void> addToCart({
    required String productId,
    required String colorName,
    required String sizeLabel,
    required int quantity,
  }) async {
    final freshCart = await _repository.addToCart(
      productId: productId,
      colorName: colorName,
      sizeLabel: sizeLabel,
      quantity: quantity,
    );
    state = AsyncValue.data(freshCart);
  }

  /// Update item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final freshCart = await _repository.updateQuantity(cartItemId, quantity);
    state = AsyncValue.data(freshCart);
  }

  /// Remove item
  Future<void> removeItem(String cartItemId) async {
    final freshCart = await _repository.removeItem(cartItemId);
    state = AsyncValue.data(freshCart);
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    final freshCart = await _repository.clearCart();
    state = AsyncValue.data(freshCart);
  }

  /// Manually refresh cart from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCart());
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartSummary>(() {
  return CartNotifier();
});

/// Derived provider for bottom navigation cart badge count
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.valueOrNull?.itemCount ?? 0;
});
