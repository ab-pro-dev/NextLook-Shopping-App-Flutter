import '../../../core/network/dio_client.dart';
import 'category_model.dart';
import 'home_sections_model.dart';
import 'product_detail_model.dart';
import 'product_list_result.dart';
import 'product_query_params.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  /// Fetches all product categories.
  Future<List<Category>> getCategories() async {
    final response = await _dioClient.dio.get('/api/categories');
    final list = (response.data as List<dynamic>)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// Fetches paginated & filtered products.
  Future<ProductListResult> getProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? color,
    String? size,
    String sort = 'newest',
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = ProductQueryParams(
      category: category,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      color: color,
      size: size,
      sort: sort,
      page: page,
      limit: limit,
    ).toQueryParams();

    final response = await _dioClient.dio.get(
      '/api/products',
      queryParameters: queryParams,
    );

    return ProductListResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches product list using a [ProductQueryParams] object.
  Future<ProductListResult> getProductsByParams(ProductQueryParams params) async {
    final response = await _dioClient.dio.get(
      '/api/products',
      queryParameters: params.toQueryParams(),
    );

    return ProductListResult.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches curated product sections for the home screen.
  Future<HomeSections> getHomeSections() async {
    final response = await _dioClient.dio.get('/api/products/home-sections');
    return HomeSections.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches full product detail by ID.
  Future<ProductDetail> getProductDetail(String id) async {
    final response = await _dioClient.dio.get('/api/products/$id');
    return ProductDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
