class ProductImage {
  final String? id;
  final String url;
  final int sortOrder;

  const ProductImage({
    this.id,
    required this.url,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as String?,
      url: json['url'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'sortOrder': sortOrder,
    };
  }
}

class ProductColor {
  final String? id;
  final String name;
  final String hexCode;

  const ProductColor({
    this.id,
    required this.name,
    required this.hexCode,
  });

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      id: json['id'] as String?,
      name: json['name'] as String,
      hexCode: json['hexCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hexCode': hexCode,
    };
  }
}

class ProductSize {
  final String? id;
  final String label;
  final int stock;

  const ProductSize({
    this.id,
    required this.label,
    required this.stock,
  });

  bool get isOutOfStock => stock <= 0;

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id'] as String?,
      label: json['label'] as String,
      stock: (json['stock'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'stock': stock,
    };
  }
}

class ProductDetail {
  final String id;
  final String name;
  final String description;
  final String? brand;
  final String categoryName;
  final String categorySlug;
  final double price;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final List<ProductImage> images;
  final List<ProductColor> colors;
  final List<ProductSize> sizes;
  final String sku;
  final bool isFlashSale;
  final bool isNewArrival;
  final bool isTrending;
  final bool isBestSeller;

  const ProductDetail({
    required this.id,
    required this.name,
    required this.description,
    this.brand,
    required this.categoryName,
    required this.categorySlug,
    required this.price,
    this.discountPrice,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.colors,
    required this.sizes,
    required this.sku,
    required this.isFlashSale,
    required this.isNewArrival,
    required this.isTrending,
    required this.isBestSeller,
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  int? get discountPercent {
    if (!hasDiscount) return null;
    final percent = ((price - discountPrice!) / price) * 100;
    return percent.round();
  }

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>? ?? {};
    final imagesList = (json['images'] as List<dynamic>?)
            ?.map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final colorsList = (json['colors'] as List<dynamic>?)
            ?.map((e) => ProductColor.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final sizesList = (json['sizes'] as List<dynamic>?)
            ?.map((e) => ProductSize.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      brand: json['brand'] as String?,
      categoryName: categoryJson['name'] as String? ?? '',
      categorySlug: categoryJson['slug'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      images: imagesList,
      colors: colorsList,
      sizes: sizesList,
      sku: json['sku'] as String,
      isFlashSale: json['isFlashSale'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
    );
  }
}
