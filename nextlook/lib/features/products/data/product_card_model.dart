class ProductCard {
  final String id;
  final String name;
  final String? brand;
  final double price;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final String? thumbnailUrl;
  final bool isFlashSale;

  const ProductCard({
    required this.id,
    required this.name,
    this.brand,
    required this.price,
    this.discountPrice,
    required this.rating,
    required this.reviewCount,
    this.thumbnailUrl,
    required this.isFlashSale,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int? get discountPercent {
    if (!hasDiscount) return null;
    final percent = ((price - discountPrice!) / price) * 100;
    return percent.round();
  }

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'discountPrice': discountPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'thumbnailUrl': thumbnailUrl,
      'isFlashSale': isFlashSale,
    };
  }
}
