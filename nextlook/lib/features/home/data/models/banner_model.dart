class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final String? categorySlug;
  final int sortOrder;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.categorySlug,
    this.sortOrder = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      buttonText: json['buttonText'] as String?,
      categorySlug: json['categorySlug'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'buttonText': buttonText,
      'categorySlug': categorySlug,
      'sortOrder': sortOrder,
    };
  }
}
