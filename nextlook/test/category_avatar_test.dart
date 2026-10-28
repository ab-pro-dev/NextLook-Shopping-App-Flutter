import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nextlook/features/products/data/category_model.dart';
import 'package:nextlook/features/products/presentation/widgets/category_avatar_widget.dart';

void main() {
  group('CategoryAvatarWidget & assetImagePath mapping tests', () {
    test('Category model resolves correct assetImagePath for all 5 core categories', () {
      const men = Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 5);
      const women = Category(id: '2', name: 'Women', slug: 'women', iconName: 'female', productCount: 5);
      const kids = Category(id: '3', name: 'Kids', slug: 'kids', iconName: 'child', productCount: 5);
      const shoes = Category(id: '4', name: 'Shoes', slug: 'shoes', iconName: 'shoe', productCount: 5);
      const accessories = Category(id: '5', name: 'Accessories', slug: 'accessories', iconName: 'accessories', productCount: 5);
      const other = Category(id: '6', name: 'Other', slug: 'other', iconName: 'tag', productCount: 1);

      expect(men.assetImagePath, 'assets/images/categories/category_men.jpg');
      expect(women.assetImagePath, 'assets/images/categories/category_women.jpg');
      expect(kids.assetImagePath, 'assets/images/categories/category_kids.jpg');
      expect(shoes.assetImagePath, 'assets/images/categories/category_shoes.jpg');
      expect(accessories.assetImagePath, 'assets/images/categories/category_accessories.jpg');
      expect(other.assetImagePath, isNull);
    });

    testWidgets('CategoryAvatarWidget renders Image.asset for Men category', (tester) async {
      const men = Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 5);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryAvatarWidget(category: men, size: 58),
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<AssetImage>());
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/categories/category_men.jpg');
    });

    testWidgets('CategoryAvatarWidget renders Image.asset for all 5 categories', (tester) async {
      final categories = [
        const Category(id: '1', name: 'Men', slug: 'men', iconName: 'male', productCount: 5),
        const Category(id: '2', name: 'Women', slug: 'women', iconName: 'female', productCount: 5),
        const Category(id: '3', name: 'Kids', slug: 'kids', iconName: 'child', productCount: 5),
        const Category(id: '4', name: 'Shoes', slug: 'shoes', iconName: 'shoe', productCount: 5),
        const Category(id: '5', name: 'Accessories', slug: 'accessories', iconName: 'accessories', productCount: 5),
      ];

      for (final cat in categories) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryAvatarWidget(category: cat, size: 58),
            ),
          ),
        );

        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget, reason: 'Failed for ${cat.name}');
        final imageWidget = tester.widget<Image>(imageFinder);
        final assetImage = imageWidget.image as AssetImage;
        expect(assetImage.assetName, cat.assetImagePath);
      }
    });

    testWidgets('CategoryAvatarWidget falls back to Icon for unknown category without image', (tester) async {
      const unknownCat = Category(id: '99', name: 'Sports', slug: 'sports', iconName: 'tag', productCount: 0);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryAvatarWidget(category: unknownCat, size: 58),
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
      expect(find.byType(Icon), findsOneWidget);
    });
  });
}
