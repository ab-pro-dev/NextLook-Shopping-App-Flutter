import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/application/auth_providers.dart';
import '../data/category_model.dart';
import '../data/home_sections_model.dart';
import '../data/product_card_model.dart';
import '../data/product_detail_model.dart';
import '../data/product_query_params.dart';
import '../data/product_repository.dart';

/// Provider for ProductRepository instance.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductRepository(dioClient: dioClient);
});

/// FutureProvider for fetching all Categories.
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getCategories();
});

/// FutureProvider for fetching Home Sections.
final homeSectionsProvider = FutureProvider<HomeSections>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getHomeSections();
});

/// FutureProvider.family for fetching Product Detail by ID.
final productDetailProvider =
    FutureProvider.family<ProductDetail, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  return await repo.getProductDetail(id);
});

/// State model for ProductListNotifier.
class ProductListState {
  final ProductQueryParams params;
  final List<ProductCard> products;
  final int total;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  const ProductListState({
    required this.params,
    required this.products,
    required this.total,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  bool get hasMore => page < totalPages;

  ProductListState copyWith({
    ProductQueryParams? params,
    List<ProductCard>? products,
    int? total,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return ProductListState(
      params: params ?? this.params,
      products: products ?? this.products,
      total: total ?? this.total,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Notifier providing paginated, filterable product list state management.
class ProductListNotifier extends StateNotifier<AsyncValue<ProductListState>> {
  final ProductRepository _repository;

  ProductListNotifier(this._repository) : super(const AsyncValue.loading());

  /// Initial or re-fetch with new query parameters.
  Future<void> fetchProducts(ProductQueryParams newParams) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.getProductsByParams(newParams);
      state = AsyncValue.data(
        ProductListState(
          params: newParams,
          products: result.products,
          total: result.total,
          page: result.page,
          totalPages: result.totalPages,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Updates current query parameters and re-fetches products.
  Future<void> updateQueryParams(ProductQueryParams newParams) async {
    await fetchProducts(newParams.copyWith(page: 1));
  }

  /// Convenience helper to set category filter.
  Future<void> setCategory(String? categorySlug) async {
    final currentParams = state.valueOrNull?.params ?? const ProductQueryParams();
    final updated = categorySlug == null
        ? currentParams.copyWith(clearCategory: true, page: 1)
        : currentParams.copyWith(category: categorySlug, page: 1);
    await fetchProducts(updated);
  }

  /// Convenience helper to set search query filter.
  Future<void> setSearch(String? searchQuery) async {
    final currentParams = state.valueOrNull?.params ?? const ProductQueryParams();
    final updated = searchQuery == null || searchQuery.isEmpty
        ? currentParams.copyWith(clearSearch: true, page: 1)
        : currentParams.copyWith(search: searchQuery, page: 1);
    await fetchProducts(updated);
  }

  /// Convenience helper to set sorting order.
  Future<void> setSort(String sortEnum) async {
    final currentParams = state.valueOrNull?.params ?? const ProductQueryParams();
    await fetchProducts(currentParams.copyWith(sort: sortEnum, page: 1));
  }

  /// Loads next page of products for infinite scroll.
  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.page + 1;
      final nextPageParams = currentState.params.copyWith(page: nextPage);
      final result = await _repository.getProductsByParams(nextPageParams);

      state = AsyncValue.data(
        ProductListState(
          params: nextPageParams,
          products: [...currentState.products, ...result.products],
          total: result.total,
          page: result.page,
          totalPages: result.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      // Revert loading flag on error
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }
}

/// Provider for ProductListNotifier state.
final productListNotifierProvider = StateNotifierProvider<ProductListNotifier, AsyncValue<ProductListState>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repo);
});
