class Category {
  final String id;
  final String name;
  final String slug;
  final String iconName;
  final int productCount;
  final String? imageUrl;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.productCount,
    this.imageUrl,
  });

  /// Returns the asset path for category avatar images, or null if none is matched.
  String? get assetImagePath {
    final s = slug.toLowerCase();
    final n = name.toLowerCase();
    final i = iconName.toLowerCase();

    if (s == 'men' || i == 'male' || i == 'men' || n == 'men') {
      return 'assets/images/categories/category_men.jpg';
    } else if (s == 'women' || i == 'female' || i == 'women' || n == 'women') {
      return 'assets/images/categories/category_women.jpg';
    } else if (s == 'kids' || i == 'child' || i == 'kids' || n == 'kids') {
      return 'assets/images/categories/category_kids.jpg';
    } else if (s == 'shoes' || i == 'shoe' || i == 'shoes' || n == 'shoes') {
      return 'assets/images/categories/category_shoes.jpg';
    } else if (s == 'accessories' || i == 'accessories' || n == 'accessories') {
      return 'assets/images/categories/category_accessories.jpg';
    }
    return null;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      iconName: json['iconName'] as String,
      productCount: (json['productCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'iconName': iconName,
      'productCount': productCount,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
