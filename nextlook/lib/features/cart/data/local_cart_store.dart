import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_models.dart';

final localCartStoreProvider = Provider<LocalCartStore>((ref) {
  return LocalCartStore();
});

class LocalCartStore {
  static const String _storageKey = 'guest_cart_items';
  final SharedPreferences? prefs;

  LocalCartStore({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  /// Unique line item key based on (productId, colorName, sizeLabel)
  static String buildKey(String productId, String colorName, String sizeLabel) {
    return '${productId}_${colorName.trim().toLowerCase()}_${sizeLabel.trim().toLowerCase()}';
  }

  Future<List<CartItem>> getItems() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveItems(List<CartItem> items) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  CartSummary calculateSummary(List<CartItem> items) {
    double subtotal = 0.0;
    int itemCount = 0;

    for (final item in items) {
      subtotal += item.lineTotal;
      itemCount += item.quantity;
    }

    return CartSummary(
      items: items,
      subtotal: double.parse(subtotal.toStringAsFixed(2)),
      itemCount: itemCount,
    );
  }

  Future<CartSummary> getCartSummary() async {
    final items = await getItems();
    return calculateSummary(items);
  }

  Future<CartSummary> addItem({
    required String productId,
    required String name,
    String? brand,
    String? thumbnailUrl,
    required double price,
    double? discountPrice,
    required String colorName,
    required String sizeLabel,
    required int quantity,
  }) async {
    final items = await getItems();
    final targetKey = buildKey(productId, colorName, sizeLabel);

    final existingIndex = items.indexWhere((item) =>
        buildKey(item.productId, item.colorName, item.sizeLabel) == targetKey);

    final unitPrice = (discountPrice != null && discountPrice < price)
        ? discountPrice
        : price;

    if (existingIndex >= 0) {
      final existing = items[existingIndex];
      // Max 10 per line, same as the backend
      final newQuantity = min(existing.quantity + quantity, 10);
      final lineTotal = double.parse((unitPrice * newQuantity).toStringAsFixed(2));

      items[existingIndex] = CartItem(
        id: existing.id,
        productId: existing.productId,
        name: existing.name,
        brand: existing.brand ?? brand,
        thumbnailUrl: existing.thumbnailUrl ?? thumbnailUrl,
        price: existing.price,
        discountPrice: existing.discountPrice,
        colorName: existing.colorName,
        sizeLabel: existing.sizeLabel,
        quantity: newQuantity,
        lineTotal: lineTotal,
        inStock: true,
      );
    } else {
      final safeQuantity = min(max(quantity, 1), 10);
      final lineTotal = double.parse((unitPrice * safeQuantity).toStringAsFixed(2));
      final newItem = CartItem(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
        productId: productId,
        name: name,
        brand: brand,
        thumbnailUrl: thumbnailUrl,
        price: price,
        discountPrice: discountPrice,
        colorName: colorName,
        sizeLabel: sizeLabel,
        quantity: safeQuantity,
        lineTotal: lineTotal,
        inStock: true,
      );
      items.add(newItem);
    }

    await saveItems(items);
    return calculateSummary(items);
  }

  Future<CartSummary> updateQuantity(String cartItemId, int quantity) async {
    final items = await getItems();
    final index = items.indexWhere((item) => item.id == cartItemId);

    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        final existing = items[index];
        final safeQuantity = min(quantity, 10);
        final unitPrice = (existing.discountPrice != null && existing.discountPrice! < existing.price)
            ? existing.discountPrice!
            : existing.price;
        final lineTotal = double.parse((unitPrice * safeQuantity).toStringAsFixed(2));

        items[index] = CartItem(
          id: existing.id,
          productId: existing.productId,
          name: existing.name,
          brand: existing.brand,
          thumbnailUrl: existing.thumbnailUrl,
          price: existing.price,
          discountPrice: existing.discountPrice,
          colorName: existing.colorName,
          sizeLabel: existing.sizeLabel,
          quantity: safeQuantity,
          lineTotal: lineTotal,
          inStock: true,
        );
      }
      await saveItems(items);
    }

    return calculateSummary(items);
  }

  Future<CartSummary> removeItem(String cartItemId) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == cartItemId);
    await saveItems(items);
    return calculateSummary(items);
  }

  Future<CartSummary> clearCart() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
    return CartSummary.empty();
  }
}
