import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';
import 'package:flutter_ecommerce_app/models/product.dart';
import 'package:flutter_ecommerce_app/models/cart.dart';

import 'cart_provider_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User])
void main() {
  group('CartProvider Tests', () {
    late CartProvider cartProvider;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late Product testProduct;

    setUp(() {
      cartProvider = CartProvider();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      testProduct = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'A test product',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: Rating(rate: 4.5, count: 100),
      );

      // Setup mock user
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    });

    test('should initialize with empty state', () {
      // Assert
      expect(cartProvider.items, isEmpty);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.total, equals(0.0));
      expect(cartProvider.isEmpty, isTrue);
      expect(cartProvider.isLoading, isFalse);
    });

    test('should handle empty cart state', () {
      // Act & Assert
      expect(cartProvider.isEmpty, isTrue);
      expect(cartProvider.itemCount, equals(0));
      expect(cartProvider.total, equals(0.0));
    });

    test('should check if item is in cart when cart is empty', () {
      // Act & Assert
      expect(cartProvider.isInCart(1), isFalse);
      expect(cartProvider.isInCart(2), isFalse);
    });

    test('should get item by product ID when cart is empty', () {
      // Act
      final foundItem = cartProvider.getItem(1);
      final notFoundItem = cartProvider.getItem(2);

      // Assert
      expect(foundItem, isNull);
      expect(notFoundItem, isNull);
    });

    test('should get quantity by product ID when cart is empty', () {
      // Act & Assert
      expect(cartProvider.getQuantity(1), equals(0));
      expect(cartProvider.getQuantity(2), equals(0));
    });

    test('should handle cart provider state correctly', () {
      // Test initial state
      expect(cartProvider.isEmpty, isTrue);
      expect(cartProvider.isLoading, isFalse);

      // Test that the provider can be instantiated without errors
      expect(cartProvider, isA<CartProvider>());
    });

    test('should have correct getter methods', () {
      // Test that all getter methods return expected types
      expect(cartProvider.items, isA<List<CartItem>>());
      expect(cartProvider.itemCount, isA<int>());
      expect(cartProvider.total, isA<double>());
      expect(cartProvider.isEmpty, isA<bool>());
      expect(cartProvider.isLoading, isA<bool>());
    });

    test('should handle cart operations without errors', () {
      // Test that methods can be called without throwing exceptions
      expect(() => cartProvider.isInCart(1), returnsNormally);
      expect(() => cartProvider.getItem(1), returnsNormally);
      expect(() => cartProvider.getQuantity(1), returnsNormally);
    });
  });
}
