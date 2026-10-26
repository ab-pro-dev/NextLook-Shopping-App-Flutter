class CartItem {
  final String id;
  final String productId;
  final String name;
  final String? brand;
  final String? thumbnailUrl;
  final double price;
  final double? discountPrice;
  final String colorName;
  final String sizeLabel;
  final int quantity;
  final double lineTotal;
  final bool inStock;

  const CartItem({
    required this.id,
    required this.productId,
    required this.name,
    this.brand,
    this.thumbnailUrl,
    required this.price,
    this.discountPrice,
    required this.colorName,
    required this.sizeLabel,
    required this.quantity,
    required this.lineTotal,
    required this.inStock,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      colorName: json['colorName'] as String,
      sizeLabel: json['sizeLabel'] as String,
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      inStock: json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'brand': brand,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'discountPrice': discountPrice,
      'colorName': colorName,
      'sizeLabel': sizeLabel,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'inStock': inStock,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? brand,
    String? thumbnailUrl,
    double? price,
    double? discountPrice,
    String? colorName,
    String? sizeLabel,
    int? quantity,
    double? lineTotal,
    bool? inStock,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      colorName: colorName ?? this.colorName,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
      inStock: inStock ?? this.inStock,
    );
  }
}

class CartSummary {
  final List<CartItem> items;
  final double subtotal;
  final int itemCount;

  const CartSummary({
    required this.items,
    required this.subtotal,
    required this.itemCount,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();

    return CartSummary(
      items: itemsList,
      subtotal: (json['subtotal'] as num).toDouble(),
      itemCount: (json['itemCount'] as num).toInt(),
    );
  }

  factory CartSummary.empty() {
    return const CartSummary(
      items: [],
      subtotal: 0.0,
      itemCount: 0,
    );
  }
}
