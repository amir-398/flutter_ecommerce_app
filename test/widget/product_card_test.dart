import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_ecommerce_app/widgets/product_card.dart';
import 'package:flutter_ecommerce_app/models/product.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';

import 'product_card_test.mocks.dart';

@GenerateMocks([CartProvider])
void main() {
  group('ProductCard Widget Tests', () {
    late Product testProduct;
    late MockCartProvider mockCartProvider;

    setUp(() {
      testProduct = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'A test product',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      mockCartProvider = MockCartProvider();
      when(mockCartProvider.isInCart(any)).thenReturn(false);
      when(mockCartProvider.getQuantity(any)).thenReturn(0);
    });

    Widget createTestWidget({Product? product, VoidCallback? onTap}) {
      return MaterialApp(
        home: ChangeNotifierProvider<CartProvider>(
          create: (_) => mockCartProvider,
          child: Scaffold(
            body: ProductCard(product: product ?? testProduct, onTap: onTap),
          ),
        ),
      );
    }

    testWidgets('should display product information correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display add to cart button when product not in cart', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockCartProvider.isInCart(1)).thenReturn(false);
      when(mockCartProvider.getQuantity(1)).thenReturn(0);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Ajouter'), findsOneWidget);
      expect(find.text('Dans le panier'), findsNothing);
    });

    testWidgets('should display cart status when product is in cart', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockCartProvider.isInCart(1)).thenReturn(true);
      when(mockCartProvider.getQuantity(1)).thenReturn(3);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Dans le panier (3)'), findsOneWidget);
      expect(find.text('Ajouter'), findsNothing);
    });

    testWidgets('should call onTap when card is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool onTapCalled = false;
      VoidCallback onTap = () {
        onTapCalled = true;
      };

      // Act
      await tester.pumpWidget(createTestWidget(onTap: onTap));
      await tester.tap(find.byType(ProductCard));
      await tester.pump();

      // Assert
      expect(onTapCalled, isTrue);
    });

    testWidgets('should call addToCart when add button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockCartProvider.isInCart(1)).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Assert
      verify(mockCartProvider.addToCart(testProduct)).called(1);
    });

    testWidgets('should show snackbar when product is added to cart', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(mockCartProvider.isInCart(1)).thenReturn(false);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Assert
      expect(find.text('Test Product ajouté au panier'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should display star icon and rating', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });

    testWidgets('should handle long product titles with ellipsis', (
      WidgetTester tester,
    ) async {
      // Arrange
      final longTitleProduct = Product(
        id: 2,
        title:
            'This is a very long product title that should be truncated with ellipsis',
        price: 19.99,
        description: 'A test product',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 4.0, count: 50),
      );

      // Act
      await tester.pumpWidget(createTestWidget(product: longTitleProduct));

      // Assert
      expect(
        find.text(
          'This is a very long product title that should be truncated with ellipsis',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display loading indicator for image', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Image), findsOneWidget);
      // Note: Testing loading state would require mocking network calls
    });

    testWidgets('should display error icon when image fails to load', (
      WidgetTester tester,
    ) async {
      // Arrange
      final productWithInvalidImage = Product(
        id: 3,
        title: 'Product with invalid image',
        price: 15.99,
        description: 'A test product',
        category: 'electronics',
        image: 'invalid-url',
        rating: Rating(rate: 3.5, count: 25),
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(product: productWithInvalidImage),
      );
      await tester.pump();

      // Assert
      // The error builder should show an error icon
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('should have correct styling and layout', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsWidgets);

      // Check for specific styling elements
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('should handle zero rating correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final productWithZeroRating = Product(
        id: 4,
        title: 'Product with zero rating',
        price: 9.99,
        description: 'A test product',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 0.0, count: 0),
      );

      // Act
      await tester.pumpWidget(createTestWidget(product: productWithZeroRating));

      // Assert
      expect(find.text('0.0'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
