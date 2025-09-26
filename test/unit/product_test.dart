import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create Product from valid JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 29.99,
        'description': 'A test product',
        'category': 'electronics',
        'thumbnail': 'https://example.com/image.jpg',
        'rating': {'rate': 4.5, 'count': 100},
      };

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, equals(1));
      expect(product.title, equals('Test Product'));
      expect(product.price, equals(29.99));
      expect(product.description, equals('A test product'));
      expect(product.category, equals('electronics'));
      expect(product.image, equals('https://example.com/image.jpg'));
      expect(product.rating.rate, equals(4.5));
      expect(product.rating.count, equals(100));
    });

    test('should handle missing fields with default values', () {
      // Arrange
      final json = {'id': 2, 'title': 'Minimal Product', 'price': 19.99};

      // Act
      final product = Product.fromJson(json);

      // Assert
      expect(product.id, equals(2));
      expect(product.title, equals('Minimal Product'));
      expect(product.price, equals(19.99));
      expect(product.description, equals('Aucune description disponible'));
      expect(product.category, equals('uncategorized'));
      expect(
        product.image,
        equals('https://via.placeholder.com/300x300?text=No+Image'),
      );
      expect(product.rating.rate, equals(0.0));
      expect(product.rating.count, equals(0));
    });

    test('should handle different image field variations', () {
      // Test with images array
      final jsonWithImages = {
        'id': 3,
        'title': 'Product with Images',
        'price': 39.99,
        'images': [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
        ],
      };

      final productWithImages = Product.fromJson(jsonWithImages);
      expect(productWithImages.image, equals('https://example.com/image1.jpg'));

      // Test with image field
      final jsonWithImage = {
        'id': 4,
        'title': 'Product with Image',
        'price': 49.99,
        'image': 'https://example.com/single-image.jpg',
      };

      final productWithImage = Product.fromJson(jsonWithImage);
      expect(
        productWithImage.image,
        equals('https://example.com/single-image.jpg'),
      );
    });

    test('should convert Product to JSON correctly', () {
      // Arrange
      final product = Product(
        id: 5,
        title: 'Test Product',
        price: 59.99,
        description: 'A test product',
        category: 'clothing',
        image: 'https://example.com/test.jpg',
        rating: Rating(rate: 4.2, count: 50),
      );

      // Act
      final json = product.toJson();

      // Assert
      expect(json['id'], equals(5));
      expect(json['title'], equals('Test Product'));
      expect(json['price'], equals(59.99));
      expect(json['description'], equals('A test product'));
      expect(json['category'], equals('clothing'));
      expect(json['image'], equals('https://example.com/test.jpg'));
      expect(json['rating']['rate'], equals(4.2));
      expect(json['rating']['count'], equals(50));
    });

    test('should handle rating parsing correctly', () {
      // Test with null rating
      final jsonNullRating = {
        'id': 6,
        'title': 'Product No Rating',
        'price': 15.99,
      };
      final productNullRating = Product.fromJson(jsonNullRating);
      expect(productNullRating.rating.rate, equals(0.0));
      expect(productNullRating.rating.count, equals(0));

      // Test with numeric rating
      final jsonNumericRating = {
        'id': 7,
        'title': 'Product Numeric Rating',
        'price': 25.99,
        'rating': 3.8,
      };
      final productNumericRating = Product.fromJson(jsonNumericRating);
      expect(productNumericRating.rating.rate, equals(3.8));
      expect(productNumericRating.rating.count, equals(0));
    });
  });

  group('Rating Model Tests', () {
    test('should create Rating from JSON', () {
      // Arrange
      final json = <String, dynamic>{'rate': 4.7, 'count': 250};

      // Act
      final rating = Rating.fromJson(json);

      // Assert
      expect(rating.rate, equals(4.7));
      expect(rating.count, equals(250));
    });

    test('should handle missing rating fields', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final rating = Rating.fromJson(json);

      // Assert
      expect(rating.rate, equals(0.0));
      expect(rating.count, equals(0));
    });

    test('should convert Rating to JSON', () {
      // Arrange
      final rating = Rating(rate: 4.3, count: 75);

      // Act
      final json = rating.toJson();

      // Assert
      expect(json['rate'], equals(4.3));
      expect(json['count'], equals(75));
    });
  });
}
