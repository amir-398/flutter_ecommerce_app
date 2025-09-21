import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';

class CartService {
  static const String baseUrl = 'https://fakestoreapi.com';

  // Créer un nouveau panier
  static Future<Cart> createCart(List<CartItem> items) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/carts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 1, // Utilisateur par défaut
          'date': DateTime.now().toIso8601String(),
          'products': items.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to create cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating cart: $e');
    }
  }

  // Récupérer un panier par ID
  static Future<Cart> getCart(int cartId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to get cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cart: $e');
    }
  }

  // Mettre à jour un panier
  static Future<Cart> updateCart(int cartId, List<CartItem> items) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': 1,
          'date': DateTime.now().toIso8601String(),
          'products': items.map((item) => item.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Cart.fromJson(jsonData);
      } else {
        throw Exception('Failed to update cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating cart: $e');
    }
  }

  // Supprimer un panier
  static Future<void> deleteCart(int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/carts/$cartId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting cart: $e');
    }
  }

  // Récupérer tous les paniers d'un utilisateur
  static Future<List<Cart>> getUserCarts(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/carts/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((cart) => Cart.fromJson(cart)).toList();
      } else {
        throw Exception('Failed to get user carts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting user carts: $e');
    }
  }
}
