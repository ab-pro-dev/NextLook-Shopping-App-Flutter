import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../products/data/product_card_model.dart';

final localWishlistStoreProvider = Provider<LocalWishlistStore>((ref) {
  return LocalWishlistStore();
});

class LocalWishlistStore {
  static const String _storageKey = 'guest_wishlist_products';
  final SharedPreferences? prefs;

  LocalWishlistStore({this.prefs});

  Future<SharedPreferences> _getPrefs() async {
    return prefs ?? await SharedPreferences.getInstance();
  }

  Future<List<ProductCard>> getWishlist() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((e) => ProductCard.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWishlist(List<ProductCard> items) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<bool> toggleWishlist(ProductCard product) async {
    final items = await getWishlist();
    final existingIndex = items.indexWhere((p) => p.id == product.id);

    bool isWishlisted;
    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
      isWishlisted = false;
    } else {
      items.insert(0, product);
      isWishlisted = true;
    }

    await saveWishlist(items);
    return isWishlisted;
  }

  Future<void> addToWishlist(ProductCard product) async {
    final items = await getWishlist();
    if (!items.any((p) => p.id == product.id)) {
      items.insert(0, product);
      await saveWishlist(items);
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    final items = await getWishlist();
    items.removeWhere((p) => p.id == productId);
    await saveWishlist(items);
  }

  Future<bool> isWishlisted(String productId) async {
    final items = await getWishlist();
    return items.any((p) => p.id == productId);
  }

  Future<void> clearWishlist() async {
    final prefs = await _getPrefs();
    await prefs.remove(_storageKey);
  }
}
