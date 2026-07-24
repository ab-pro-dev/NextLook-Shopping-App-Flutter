import 'product_card_model.dart';

class ProductListResult {
  final List<ProductCard> products;
  final int total;
  final int page;
  final int totalPages;

  const ProductListResult({
    required this.products,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ProductListResult.fromJson(Map<String, dynamic> json) {
    final list = (json['products'] as List<dynamic>?)
            ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return ProductListResult(
      products: list,
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );
  }
}
