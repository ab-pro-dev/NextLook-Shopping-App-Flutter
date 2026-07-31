import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nextlook/core/network/dio_client.dart';
import 'package:nextlook/features/products/presentation/categories_list_screen.dart';
import 'package:nextlook/features/products/presentation/category_products_screen.dart';
import 'package:nextlook/features/products/presentation/product_detail_screen.dart';
import 'package:nextlook/features/products/presentation/widgets/category_skeletons.dart';
import 'package:nextlook/features/products/presentation/widgets/product_grid_skeleton.dart';
import 'package:nextlook/features/products/presentation/widgets/product_detail_skeleton.dart';
import 'package:nextlook/features/products/application/product_providers.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/data/product_detail_model.dart';
import 'package:nextlook/features/products/data/product_list_result.dart';
import 'package:nextlook/features/products/data/product_query_params.dart';
import 'package:nextlook/features/products/data/product_repository.dart';

class FakeTestProductRepository extends ProductRepository {
  final Completer<ProductListResult> completer = Completer<ProductListResult>();

  @override
  Future<ProductListResult> getProductsByParams(ProductQueryParams params) {
    return completer.future;
  }
}

class FakeLoadingProductListNotifier extends ProductListNotifier {
  FakeLoadingProductListNotifier() : super(FakeTestProductRepository()) {
    state = const AsyncValue.loading();
  }
}

void main() {
  group('Product Browsing Screens Skeleton Loading Tests', () {
    testWidgets('CategoriesListScreen renders CategoriesListSkeleton when loading', (tester) async {
      final completer = Completer<List<Category>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoriesProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: CategoriesListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CategoriesListSkeleton), findsOneWidget);
    });

    testWidgets('CategoryProductsScreen renders ProductGridSkeleton when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productListNotifierProvider.overrideWith((ref) => FakeLoadingProductListNotifier()),
          ],
          child: const MaterialApp(
            home: CategoryProductsScreen(categorySlug: 'men'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductGridSkeleton), findsOneWidget);
    });

    testWidgets('ProductDetailScreen renders ProductDetailSkeleton when loading', (tester) async {
      final completer = Completer<ProductDetail>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productDetailProvider('prod-123').overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: ProductDetailScreen(productId: 'prod-123'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ProductDetailSkeleton), findsOneWidget);
    });
  });
}
