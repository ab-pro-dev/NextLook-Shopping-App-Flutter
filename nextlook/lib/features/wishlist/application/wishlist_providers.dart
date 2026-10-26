import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../../products/data/product_card_model.dart';
import '../data/wishlist_repository.dart';
import '../data/local_wishlist_store.dart';

class WishlistState {
  final List<ProductCard> items;
  final Set<String> wishlistedIds;

  const WishlistState({
    required this.items,
    required this.wishlistedIds,
  });

  bool isWishlisted(String productId) => wishlistedIds.contains(productId);

  WishlistState copyWith({
    List<ProductCard>? items,
    Set<String>? wishlistedIds,
  }) {
    return WishlistState(
      items: items ?? this.items,
      wishlistedIds: wishlistedIds ?? this.wishlistedIds,
    );
  }
}

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

class WishlistNotifier extends AsyncNotifier<WishlistState> {
  late final LocalWishlistStore _localStore;

  @override
  Future<WishlistState> build() async {
    final authState = ref.watch(authControllerProvider);
    _localStore = ref.watch(localWishlistStoreProvider);

    if (authState is AuthAuthenticated) {
      final repository = ref.read(wishlistRepositoryProvider);
      final items = await repository.getWishlist();
      final ids = items.map((p) => p.id).toSet();
      return WishlistState(items: items, wishlistedIds: ids);
    } else {
      final items = await _localStore.getWishlist();
      final ids = items.map((p) => p.id).toSet();
      return WishlistState(items: items, wishlistedIds: ids);
    }
  }

  /// Refreshes the wishlist from the backend API or local store.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthAuthenticated) {
        final repository = ref.read(wishlistRepositoryProvider);
        final items = await repository.getWishlist();
        final ids = items.map((p) => p.id).toSet();
        return WishlistState(items: items, wishlistedIds: ids);
      } else {
        final items = await _localStore.getWishlist();
        final ids = items.map((p) => p.id).toSet();
        return WishlistState(items: items, wishlistedIds: ids);
      }
    });
  }

  /// Toggles wishlist status for a given [ProductCard].
  /// Performs an optimistic update immediately, rolling back on failure for authenticated users.
  Future<bool> toggleWishlist(ProductCard product) async {
    final authState = ref.read(authControllerProvider);

    if (authState is AuthAuthenticated) {
      final previousState = state.valueOrNull;
      if (previousState == null) return false;

      final isCurrentlyWishlisted = previousState.isWishlisted(product.id);

      // Prepare optimistic state
      final newIds = Set<String>.from(previousState.wishlistedIds);
      final newItems = List<ProductCard>.from(previousState.items);

      if (isCurrentlyWishlisted) {
        newIds.remove(product.id);
        newItems.removeWhere((item) => item.id == product.id);
      } else {
        newIds.add(product.id);
        newItems.insert(0, product);
      }

      // Apply optimistic update
      state = AsyncValue.data(
        WishlistState(items: newItems, wishlistedIds: newIds),
      );

      try {
        final repository = ref.read(wishlistRepositoryProvider);
        if (isCurrentlyWishlisted) {
          await repository.removeFromWishlist(product.id);
        } else {
          await repository.addToWishlist(product.id);
        }
        return !isCurrentlyWishlisted;
      } catch (error) {
        // Rollback on failure
        state = AsyncValue.data(previousState);
        rethrow;
      }
    } else {
      // Local store for guests:
      final isNowWishlisted = await _localStore.toggleWishlist(product);
      final items = await _localStore.getWishlist();
      final ids = items.map((p) => p.id).toSet();
      state = AsyncValue.data(
        WishlistState(items: items, wishlistedIds: ids),
      );
      return isNowWishlisted;
    }
  }
}

final wishlistNotifierProvider =
    AsyncNotifierProvider<WishlistNotifier, WishlistState>(() {
  return WishlistNotifier();
});
