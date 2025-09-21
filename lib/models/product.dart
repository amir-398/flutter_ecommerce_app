class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final Rating rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // Gérer les images - DummyJSON a 'images' (array) et 'thumbnail'
      String imageUrl = 'https://via.placeholder.com/300x300?text=No+Image';
      if (json['thumbnail'] != null) {
        imageUrl = json['thumbnail'].toString();
      } else if (json['images'] != null &&
          (json['images'] as List).isNotEmpty) {
        imageUrl = (json['images'] as List).first.toString();
      } else if (json['image'] != null) {
        imageUrl = json['image'].toString();
      }

      final product = Product(
        id: json['id'] ?? 0,
        title: json['title']?.toString() ?? 'Produit sans nom',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description:
            json['description']?.toString() ?? 'Aucune description disponible',
        category: json['category']?.toString() ?? 'uncategorized',
        image: imageUrl,
        rating: _parseRating(json['rating']),
      );

      return product;
    } catch (e) {
      rethrow;
    }
  }

  static Rating _parseRating(dynamic ratingData) {
    if (ratingData == null) {
      return Rating(rate: 0.0, count: 0);
    }

    // Si c'est un nombre (double), c'est le format DummyJSON
    if (ratingData is num) {
      return Rating(rate: ratingData.toDouble(), count: 0);
    }

    // Si c'est un objet Map, c'est le format FakeStore
    if (ratingData is Map<String, dynamic>) {
      return Rating.fromJson(ratingData);
    }

    // Fallback
    return Rating(rate: 0.0, count: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': image,
      'rating': rating.toJson(),
    };
  }
}

class Rating {
  final double rate;
  final int count;

  Rating({required this.rate, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'rate': rate, 'count': count};
  }
}
