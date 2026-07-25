class ProductQueryParams {
  final String? category;
  final String? search;
  final double? minPrice;
  final double? maxPrice;
  final String? color;
  final String? size;
  final double? minRating;
  final String sort;
  final int page;
  final int limit;

  const ProductQueryParams({
    this.category,
    this.search,
    this.minPrice,
    this.maxPrice,
    this.color,
    this.size,
    this.minRating,
    this.sort = 'newest',
    this.page = 1,
    this.limit = 20,
  });

  ProductQueryParams copyWith({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? color,
    String? size,
    double? minRating,
    String? sort,
    int? page,
    int? limit,
    bool clearCategory = false,
    bool clearSearch = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearColor = false,
    bool clearSize = false,
    bool clearMinRating = false,
  }) {
    return ProductQueryParams(
      category: clearCategory ? null : (category ?? this.category),
      search: clearSearch ? null : (search ?? this.search),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      color: clearColor ? null : (color ?? this.color),
      size: clearSize ? null : (size ?? this.size),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (category != null && category!.isNotEmpty) params['category'] = category;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (color != null && color!.isNotEmpty) params['color'] = color;
    if (size != null && size!.isNotEmpty) params['size'] = size;
    if (minRating != null) params['minRating'] = minRating;
    params['sort'] = sort;
    params['page'] = page;
    params['limit'] = limit;
    return params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductQueryParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          search == other.search &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          color == other.color &&
          size == other.size &&
          minRating == other.minRating &&
          sort == other.sort &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode =>
      category.hashCode ^
      search.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      color.hashCode ^
      size.hashCode ^
      minRating.hashCode ^
      sort.hashCode ^
      page.hashCode ^
      limit.hashCode;
}
