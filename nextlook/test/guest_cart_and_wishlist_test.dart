import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextlook/features/auth/application/auth_providers.dart';
import 'package:nextlook/features/auth/data/auth_repository.dart';
import 'package:nextlook/features/cart/application/cart_providers.dart';
import 'package:nextlook/features/cart/data/local_cart_store.dart';
import 'package:nextlook/features/wishlist/application/wishlist_providers.dart';
import 'package:nextlook/features/wishlist/data/local_wishlist_store.dart';
import 'package:nextlook/features/products/data/product_card_model.dart';
import 'package:dio/dio.dart';
import 'package:nextlook/core/network/dio_client.dart';

class CountingInterceptor extends Interceptor {
  int cartCalls = 0;
  int wishlistCalls = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.contains('/api/cart')) {
      cartCalls++;
    }
    if (options.path.contains('/api/wishlist')) {
      wishlistCalls++;
    }
    handler.next(options);
  }
}

class FakeGuestAuthController extends AuthController {
  FakeGuestAuthController() : super(FakeGuestAuthRepository()) {
    state = const AuthUnauthenticated();
  }
}

class FakeGuestAuthRepository extends AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const product1 = ProductCard(
    id: 'prod-jacket',
    name: 'Leather Biker Jacket',
    brand: 'NextLook Studio',
    price: 19500,
    discountPrice: 16500,
    rating: 4.8,
    reviewCount: 12,
    thumbnailUrl: 'https://example.com/jacket.jpg',
    isFlashSale: true,
  );

  const product2 = ProductCard(
    id: 'prod-shirt',
    name: 'Slim Fit Cotton Shirt',
    brand: 'UrbanEdge',
    price: 4500,
    discountPrice: null,
    rating: 4.5,
    reviewCount: 30,
    thumbnailUrl: 'https://example.com/shirt.jpg',
    isFlashSale: false,
  );

  group('LocalCartStore Direct Unit Tests', () {
    late SharedPreferences prefs;
    late LocalCartStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = LocalCartStore(prefs: prefs);
    });

    test('Add 2 products (one discounted, with color + size) -> correct line prices and subtotal', () async {
      // Add discounted jacket: price 19500, discountPrice 16500, qty 2
      final summary1 = await store.addItem(
        productId: product1.id,
        name: product1.name,
        brand: product1.brand,
        thumbnailUrl: product1.thumbnailUrl,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 2,
      );

      expect(summary1.items.length, equals(1));
      expect(summary1.items[0].price, equals(19500));
      expect(summary1.items[0].discountPrice, equals(16500));
      expect(summary1.items[0].lineTotal, equals(33000)); // 16500 * 2
      expect(summary1.subtotal, equals(33000));
      expect(summary1.itemCount, equals(2));

      // Add regular shirt: price 4500, no discount, qty 1
      final summary2 = await store.addItem(
        productId: product2.id,
        name: product2.name,
        brand: product2.brand,
        thumbnailUrl: product2.thumbnailUrl,
        price: product2.price,
        discountPrice: product2.discountPrice,
        colorName: 'White',
        sizeLabel: 'M',
        quantity: 1,
      );

      expect(summary2.items.length, equals(2));
      expect(summary2.items[1].lineTotal, equals(4500));
      expect(summary2.subtotal, equals(37500)); // 33000 + 4500
      expect(summary2.itemCount, equals(3));
    });

    test('Add same product/color/size again -> quantity increments, no duplicate row (max 10)', () async {
      await store.addItem(
        productId: product1.id,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 2,
      );

      // Add same combo again with qty 3
      final summary = await store.addItem(
        productId: product1.id,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 3,
      );

      expect(summary.items.length, equals(1));
      expect(summary.items[0].quantity, equals(5));
      expect(summary.items[0].lineTotal, equals(16500 * 5));
      expect(summary.subtotal, equals(82500));
      expect(summary.itemCount, equals(5));

      // Try adding 8 more (should cap at 10)
      final cappedSummary = await store.addItem(
        productId: product1.id,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 8,
      );

      expect(cappedSummary.items[0].quantity, equals(10));
      expect(cappedSummary.itemCount, equals(10));
    });

    test('Update quantity and remove line -> totals update correctly', () async {
      await store.addItem(
        productId: product1.id,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 2,
      );
      final item2Summary = await store.addItem(
        productId: product2.id,
        name: product2.name,
        price: product2.price,
        colorName: 'Blue',
        sizeLabel: 'S',
        quantity: 1,
      );

      final item1Id = item2Summary.items[0].id;
      final item2Id = item2Summary.items[1].id;

      // Update item 1 quantity from 2 to 4
      final updatedSummary = await store.updateQuantity(item1Id, 4);
      expect(updatedSummary.items[0].quantity, equals(4));
      expect(updatedSummary.items[0].lineTotal, equals(16500 * 4)); // 66000
      expect(updatedSummary.subtotal, equals(66000 + 4500)); // 70500
      expect(updatedSummary.itemCount, equals(5));

      // Remove item 2
      final removedSummary = await store.removeItem(item2Id);
      expect(removedSummary.items.length, equals(1));
      expect(removedSummary.subtotal, equals(66000));
      expect(removedSummary.itemCount, equals(4));

      // Clear cart
      final clearedSummary = await store.clearCart();
      expect(clearedSummary.items, isEmpty);
      expect(clearedSummary.subtotal, equals(0.0));
      expect(clearedSummary.itemCount, equals(0));
    });

    test('Persistence: Fully re-instantiate store -> cart is still there', () async {
      await store.addItem(
        productId: product1.id,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 3,
      );

      // Create new store instance pointing to same prefs
      final freshStore = LocalCartStore(prefs: prefs);
      final persisted = await freshStore.getCartSummary();

      expect(persisted.items.length, equals(1));
      expect(persisted.items[0].productId, equals(product1.id));
      expect(persisted.items[0].quantity, equals(3));
      expect(persisted.subtotal, equals(16500 * 3));
    });
  });

  group('LocalWishlistStore Direct Unit Tests', () {
    late SharedPreferences prefs;
    late LocalWishlistStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = LocalWishlistStore(prefs: prefs);
    });

    test('Heart 2 products -> both appear; un-heart removes', () async {
      final isHearted1 = await store.toggleWishlist(product1);
      expect(isHearted1, isTrue);

      final isHearted2 = await store.toggleWishlist(product2);
      expect(isHearted2, isTrue);

      var items = await store.getWishlist();
      expect(items.length, equals(2));
      expect(await store.isWishlisted(product1.id), isTrue);
      expect(await store.isWishlisted(product2.id), isTrue);

      // Un-heart product 1
      final unHearted1 = await store.toggleWishlist(product1);
      expect(unHearted1, isFalse);

      items = await store.getWishlist();
      expect(items.length, equals(1));
      expect(items[0].id, equals(product2.id));
      expect(await store.isWishlisted(product1.id), isFalse);
    });

    test('Persistence: Fully re-instantiate store -> wishlist is still there', () async {
      await store.toggleWishlist(product1);

      final freshStore = LocalWishlistStore(prefs: prefs);
      final items = await freshStore.getWishlist();

      expect(items.length, equals(1));
      expect(items[0].id, equals(product1.id));
      expect(await freshStore.isWishlisted(product1.id), isTrue);
    });
  });

  group('Zero Network Calls As Guest Verification', () {
    test('Interceptors record ZERO calls to /api/cart and /api/wishlist during guest operations', () async {
      SharedPreferences.setMockInitialValues({});
      final countingInterceptor = CountingInterceptor();

      final dio = Dio();
      dio.interceptors.add(countingInterceptor);
      final dioClient = DioClient(dio: dio);

      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWith((ref) => FakeGuestAuthController()),
          dioClientProvider.overrideWithValue(dioClient),
        ],
      );

      // Initial read of cart and wishlist
      final initialCart = await container.read(cartProvider.future);
      expect(initialCart.items, isEmpty);

      final initialWishlist = await container.read(wishlistNotifierProvider.future);
      expect(initialWishlist.items, isEmpty);

      // Add to cart as guest
      await container.read(cartProvider.notifier).addToCart(
        productId: product1.id,
        colorName: 'Black',
        sizeLabel: 'L',
        quantity: 2,
        name: product1.name,
        price: product1.price,
        discountPrice: product1.discountPrice,
      );

      // Update quantity as guest
      final cartState = container.read(cartProvider).value!;
      await container.read(cartProvider.notifier).updateQuantity(cartState.items.first.id, 4);

      // Toggle wishlist as guest
      await container.read(wishlistNotifierProvider.notifier).toggleWishlist(product1);
      await container.read(wishlistNotifierProvider.notifier).toggleWishlist(product2);
      await container.read(wishlistNotifierProvider.notifier).toggleWishlist(product1); // remove

      // Verify ZERO network requests were sent to backend
      expect(countingInterceptor.cartCalls, equals(0));
      expect(countingInterceptor.wishlistCalls, equals(0));
    });
  });
}
