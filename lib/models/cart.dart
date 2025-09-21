import 'product.dart';

class Cart {
  final int id;
  final int userId;
  final DateTime date;
  final List<CartItem> products;

  Cart({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      products: (json['products'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'products': products.map((item) => item.toJson()).toList(),
    };
  }

  double get total {
    return products.fold(0.0, (sum, item) => sum + item.total);
  }

  int get totalItems {
    return products.fold(0, (sum, item) => sum + item.quantity);
  }
}

class CartItem {
  final int productId;
  final int quantity;
  Product? product; // Sera rempli séparément

  CartItem({required this.productId, required this.quantity, this.product});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    Product? product;

    // Si les détails du produit sont présents dans le JSON
    if (json['product'] != null) {
      product = Product.fromJson(json['product']);
    }

    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (product != null) 'product': product!.toJson(),
    };
  }

  // Méthodes pour Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      if (product != null) 'product': product!.toJson(),
    };
  }

  factory CartItem.fromFirestoreMap(Map<String, dynamic> data) {
    Product? product;

    // Si les détails du produit sont présents dans les données Firestore
    if (data['product'] != null) {
      product = Product.fromJson(data['product']);
    }

    return CartItem(
      productId: data['productId'],
      quantity: data['quantity'],
      product: product,
    );
  }

  double get total {
    if (product == null) return 0.0;
    return product!.price * quantity;
  }

  CartItem copyWith({int? productId, int? quantity, Product? product}) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}
