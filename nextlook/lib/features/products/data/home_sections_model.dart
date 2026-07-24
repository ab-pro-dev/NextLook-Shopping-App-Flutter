import 'product_card_model.dart';

class HomeSections {
  final List<ProductCard> flashSale;
  final List<ProductCard> newArrivals;
  final List<ProductCard> trending;
  final List<ProductCard> bestSellers;

  const HomeSections({
    required this.flashSale,
    required this.newArrivals,
    required this.trending,
    required this.bestSellers,
  });

  factory HomeSections.fromJson(Map<String, dynamic> json) {
    return HomeSections(
      flashSale: (json['flashSale'] as List<dynamic>?)
              ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      newArrivals: (json['newArrivals'] as List<dynamic>?)
              ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trending: (json['trending'] as List<dynamic>?)
              ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestSellers: (json['bestSellers'] as List<dynamic>?)
              ?.map((e) => ProductCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
