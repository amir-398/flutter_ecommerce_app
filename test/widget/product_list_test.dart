import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ecommerce_app/widgets/product_list.dart';
import 'package:flutter_ecommerce_app/widgets/product_card.dart';
import 'package:flutter_ecommerce_app/models/product.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';

import 'product_list_test.mocks.dart';

@GenerateMocks([CartProvider])
void main() {
  group('ProductList Widget Tests', () {
    late List<Product> testProducts;
    late MockCartProvider mockCartProvider;

    setUp(() {
      testProducts = [
        Product(
          id: 1,
          title: 'Test Product 1',
          price: 29.99,
          description: 'A test product',
          category: 'electronics',
          image: 'https://example.com/image1.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ),
        Product(
          id: 2,
          title: 'Test Product 2',
          price: 39.99,
          description: 'Another test product',
          category: 'clothing',
          image: 'https://example.com/image2.jpg',
          rating: Rating(rate: 4.2, count: 50),
        ),
        Product(
          id: 3,
          title: 'Test Product 3',
          price: 19.99,
          description: 'Third test product',
          category: 'books',
          image: 'https://example.com/image3.jpg',
          rating: Rating(rate: 4.8, count: 75),
        ),
      ];

      mockCartProvider = MockCartProvider();
      when(mockCartProvider.isInCart(any)).thenReturn(false);
      when(mockCartProvider.getQuantity(any)).thenReturn(0);
    });

    Widget createTestWidget({
      List<Product>? products,
      bool isLoading = false,
      String? error,
      VoidCallback? onRetry,
      Function(Product)? onProductTap,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<CartProvider>(
          create: (_) => mockCartProvider,
          child: Scaffold(
            body: ProductList(
              products: products ?? testProducts,
              isLoading: isLoading,
              error: error,
              onRetry: onRetry,
              onProductTap: onProductTap,
            ),
          ),
        ),
      );
    }

    testWidgets('should display products in grid layout', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ProductCard), findsNWidgets(3));
    });

    testWidgets('should display loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget(products: [], isLoading: true));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Chargement des produits...'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should display error message when error is provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Failed to load products';

      // Act
      await tester.pumpWidget(
        createTestWidget(products: [], error: errorMessage),
      );

      // Assert
      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets(
      'should display retry button when error and onRetry are provided',
      (WidgetTester tester) async {
        // Arrange
        bool retryCalled = false;
        VoidCallback onRetry = () {
          retryCalled = true;
        };

        // Act
        await tester.pumpWidget(
          createTestWidget(
            products: [],
            error: 'Network error',
            onRetry: onRetry,
          ),
        );

        // Assert
        expect(find.text('Réessayer'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);

        // Test retry button functionality
        await tester.tap(find.text('Réessayer'));
        await tester.pump();
        expect(retryCalled, isTrue);
      },
    );

    testWidgets(
      'should not display retry button when error is provided but onRetry is null',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          createTestWidget(products: [], error: 'Network error'),
        );

        // Assert
        expect(find.text('Réessayer'), findsNothing);
        expect(find.byType(ElevatedButton), findsNothing);
      },
    );

    testWidgets('should display empty state when products list is empty', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget(products: []));

      // Assert
      expect(find.text('Aucun produit trouvé'), findsOneWidget);
      expect(
        find.text('Essayez de modifier vos critères de recherche'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('should call onProductTap when product card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      Product? tappedProduct;
      Function(Product)? onProductTap = (product) {
        tappedProduct = product;
      };

      // Act
      await tester.pumpWidget(createTestWidget(onProductTap: onProductTap));
      await tester.tap(find.byType(ProductCard).first);
      await tester.pump();

      // Assert
      expect(tappedProduct, isNotNull);
      expect(tappedProduct!.id, equals(1));
      expect(tappedProduct!.title, equals('Test Product 1'));
    });

    testWidgets('should display correct number of products', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(ProductCard), findsNWidgets(3));
    });

    testWidgets('should handle single product correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final singleProduct = [testProducts.first];

      // Act
      await tester.pumpWidget(createTestWidget(products: singleProduct));

      // Assert
      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should have correct grid layout properties', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.padding, equals(const EdgeInsets.all(16)));

      final gridDelegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(gridDelegate.crossAxisCount, equals(2));
      expect(gridDelegate.childAspectRatio, equals(0.7));
      expect(gridDelegate.crossAxisSpacing, equals(16));
      expect(gridDelegate.mainAxisSpacing, equals(16));
    });

    testWidgets('should prioritize loading state over other states', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          products: testProducts,
          isLoading: true,
          error: 'Some error',
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Chargement des produits...'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.text('Erreur de chargement'), findsNothing);
    });

    testWidgets('should prioritize error state over empty state', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(products: [], error: 'Network error'),
      );

      // Assert
      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.text('Aucun produit trouvé'), findsNothing);
    });

    testWidgets('should display products when all conditions are normal', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(products: testProducts, isLoading: false, error: null),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ProductCard), findsNWidgets(3));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Erreur de chargement'), findsNothing);
      expect(find.text('Aucun produit trouvé'), findsNothing);
    });
  });
}
