import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../../products/application/product_providers.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';
import '../data/local_cart_store.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CartRepository(dioClient);
});

class CartNotifier extends AsyncNotifier<CartSummary> {
  late final CartRepository _repository;
  late final LocalCartStore _localStore;

  @override
  Future<CartSummary> build() async {
    final authState = ref.watch(authControllerProvider);
    _repository = ref.watch(cartRepositoryProvider);
    _localStore = ref.watch(localCartStoreProvider);

    if (authState is AuthAuthenticated) {
      return await _repository.getCart();
    } else {
      return await _localStore.getCartSummary();
    }
  }

  /// Add item to cart and update state on success
  Future<void> addToCart({
    required String productId,
    required String colorName,
    required String sizeLabel,
    required int quantity,
    String? name,
    String? brand,
    String? thumbnailUrl,
    double? price,
    double? discountPrice,
  }) async {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) {
      final freshCart = await _repository.addToCart(
        productId: productId,
        colorName: colorName,
        sizeLabel: sizeLabel,
        quantity: quantity,
      );
      state = AsyncValue.data(freshCart);
    } else {
      if (name == null || price == null) {
        try {
          final product = await ref.read(productRepositoryProvider).getProductDetail(productId);
          name ??= product.name;
          brand ??= product.brand;
          thumbnailUrl ??= product.images.isNotEmpty ? product.images.first.url : null;
          price ??= product.price;
          discountPrice ??= product.discountPrice;
        } catch (_) {}
      }

      final freshCart = await _localStore.addItem(
        productId: productId,
        name: name ?? 'Product',
        brand: brand,
        thumbnailUrl: thumbnailUrl,
        price: price ?? 0.0,
        discountPrice: discountPrice,
        colorName: colorName,
        sizeLabel: sizeLabel,
        quantity: quantity,
      );
      state = AsyncValue.data(freshCart);
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) {
      final freshCart = await _repository.updateQuantity(cartItemId, quantity);
      state = AsyncValue.data(freshCart);
    } else {
      final freshCart = await _localStore.updateQuantity(cartItemId, quantity);
      state = AsyncValue.data(freshCart);
    }
  }

  /// Remove item
  Future<void> removeItem(String cartItemId) async {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) {
      final freshCart = await _repository.removeItem(cartItemId);
      state = AsyncValue.data(freshCart);
    } else {
      final freshCart = await _localStore.removeItem(cartItemId);
      state = AsyncValue.data(freshCart);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) {
      final freshCart = await _repository.clearCart();
      state = AsyncValue.data(freshCart);
    } else {
      final freshCart = await _localStore.clearCart();
      state = AsyncValue.data(freshCart);
    }
  }

  /// Manually refresh cart from server or local store
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthAuthenticated) {
        return await _repository.getCart();
      } else {
        return await _localStore.getCartSummary();
      }
    });
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
