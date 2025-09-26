import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/models/cart.dart';
import 'package:flutter_ecommerce_app/models/product.dart';

void main() {
  group('Cart Model Tests', () {
    late Product testProduct;
    late CartItem testCartItem;

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

      testCartItem = CartItem(productId: 1, quantity: 2, product: testProduct);
    });

    test('should create Cart from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'userId': 123,
        'date': '2024-01-15T10:30:00.000Z',
        'products': [
          {
            'productId': 1,
            'quantity': 2,
            'product': {
              'id': 1,
              'title': 'Test Product',
              'price': 29.99,
              'description': 'A test product',
              'category': 'electronics',
              'image': 'https://example.com/image.jpg',
              'rating': {'rate': 4.5, 'count': 100},
            },
          },
        ],
      };

      // Act
      final cart = Cart.fromJson(json);

      // Assert
      expect(cart.id, equals(1));
      expect(cart.userId, equals(123));
      expect(cart.date, equals(DateTime.parse('2024-01-15T10:30:00.000Z')));
      expect(cart.products.length, equals(1));
      expect(cart.products.first.productId, equals(1));
      expect(cart.products.first.quantity, equals(2));
      expect(cart.products.first.product?.title, equals('Test Product'));
    });

    test('should calculate total correctly', () {
      // Arrange
      final cartItem1 = CartItem(
        productId: 1,
        quantity: 2,
        product: Product(
          id: 1,
          title: 'Product 1',
          price: 10.0,
          description: 'Test',
          category: 'test',
          image: 'test.jpg',
          rating: Rating(rate: 4.0, count: 10),
        ),
      );

      final cartItem2 = CartItem(
        productId: 2,
        quantity: 3,
        product: Product(
          id: 2,
          title: 'Product 2',
          price: 15.0,
          description: 'Test',
          category: 'test',
          image: 'test.jpg',
          rating: Rating(rate: 4.0, count: 10),
        ),
      );

      final cart = Cart(
        id: 1,
        userId: 123,
        date: DateTime.now(),
        products: [cartItem1, cartItem2],
      );

      // Act & Assert
      // Product 1: 2 * 10.0 = 20.0
      // Product 2: 3 * 15.0 = 45.0
      // Total: 65.0
      expect(cart.total, equals(65.0));
    });

    test('should calculate total items correctly', () {
      // Arrange
      final cart = Cart(
        id: 1,
        userId: 123,
        date: DateTime.now(),
        products: [
          CartItem(productId: 1, quantity: 2, product: testProduct),
          CartItem(productId: 2, quantity: 3, product: testProduct),
          CartItem(productId: 3, quantity: 1, product: testProduct),
        ],
      );

      // Act & Assert
      expect(cart.totalItems, equals(6)); // 2 + 3 + 1
    });

    test('should convert Cart to JSON', () {
      // Arrange
      final cart = Cart(
        id: 1,
        userId: 123,
        date: DateTime.parse('2024-01-15T10:30:00.000Z'),
        products: [testCartItem],
      );

      // Act
      final json = cart.toJson();

      // Assert
      expect(json['id'], equals(1));
      expect(json['userId'], equals(123));
      expect(json['date'], equals('2024-01-15T10:30:00.000Z'));
      expect(json['products'], isA<List>());
      expect(json['products'].length, equals(1));
    });
  });

  group('CartItem Model Tests', () {
    late Product testProduct;

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
    });

    test('should create CartItem from JSON', () {
      // Arrange
      final json = {
        'productId': 1,
        'quantity': 3,
        'product': {
          'id': 1,
          'title': 'Test Product',
          'price': 29.99,
          'description': 'A test product',
          'category': 'electronics',
          'image': 'https://example.com/image.jpg',
          'rating': {'rate': 4.5, 'count': 100},
        },
      };

      // Act
      final cartItem = CartItem.fromJson(json);

      // Assert
      expect(cartItem.productId, equals(1));
      expect(cartItem.quantity, equals(3));
      expect(cartItem.product?.title, equals('Test Product'));
    });

    test('should create CartItem from JSON without product', () {
      // Arrange
      final json = {'productId': 1, 'quantity': 3};

      // Act
      final cartItem = CartItem.fromJson(json);

      // Assert
      expect(cartItem.productId, equals(1));
      expect(cartItem.quantity, equals(3));
      expect(cartItem.product, isNull);
    });

    test('should calculate total correctly', () {
      // Arrange
      final cartItem = CartItem(
        productId: 1,
        quantity: 3,
        product: testProduct,
      );

      // Act & Assert
      // 3 * 29.99 = 89.97
      expect(cartItem.total, equals(89.97));
    });

    test('should return 0 total when product is null', () {
      // Arrange
      final cartItem = CartItem(productId: 1, quantity: 3, product: null);

      // Act & Assert
      expect(cartItem.total, equals(0.0));
    });

    test('should convert CartItem to JSON', () {
      // Arrange
      final cartItem = CartItem(
        productId: 1,
        quantity: 3,
        product: testProduct,
      );

      // Act
      final json = cartItem.toJson();

      // Assert
      expect(json['productId'], equals(1));
      expect(json['quantity'], equals(3));
      expect(json['product'], isNotNull);
      expect(json['product']['title'], equals('Test Product'));
    });

    test('should convert CartItem to Firestore map', () {
      // Arrange
      final cartItem = CartItem(
        productId: 1,
        quantity: 3,
        product: testProduct,
      );

      // Act
      final firestoreMap = cartItem.toFirestoreMap();

      // Assert
      expect(firestoreMap['productId'], equals(1));
      expect(firestoreMap['quantity'], equals(3));
      expect(firestoreMap['product'], isNotNull);
    });

    test('should create CartItem from Firestore map', () {
      // Arrange
      final firestoreData = {
        'productId': 1,
        'quantity': 3,
        'product': {
          'id': 1,
          'title': 'Test Product',
          'price': 29.99,
          'description': 'A test product',
          'category': 'electronics',
          'image': 'https://example.com/image.jpg',
          'rating': {'rate': 4.5, 'count': 100},
        },
      };

      // Act
      final cartItem = CartItem.fromFirestoreMap(firestoreData);

      // Assert
      expect(cartItem.productId, equals(1));
      expect(cartItem.quantity, equals(3));
      expect(cartItem.product?.title, equals('Test Product'));
    });

    test('should copy CartItem with new values', () {
      // Arrange
      final originalCartItem = CartItem(
        productId: 1,
        quantity: 3,
        product: testProduct,
      );

      final newProduct = Product(
        id: 2,
        title: 'New Product',
        price: 39.99,
        description: 'A new product',
        category: 'clothing',
        image: 'https://example.com/new.jpg',
        rating: Rating(rate: 4.0, count: 50),
      );

      // Act
      final copiedCartItem = originalCartItem.copyWith(
        quantity: 5,
        product: newProduct,
      );

      // Assert
      expect(copiedCartItem.productId, equals(1)); // Unchanged
      expect(copiedCartItem.quantity, equals(5)); // Changed
      expect(copiedCartItem.product?.title, equals('New Product')); // Changed
    });
  });
}
