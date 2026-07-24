class Category {
  final String id;
  final String name;
  final String slug;
  final String iconName;
  final int productCount;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconName,
    required this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      iconName: json['iconName'] as String,
      productCount: (json['productCount'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'iconName': iconName,
      'productCount': productCount,
    };
  }
}
