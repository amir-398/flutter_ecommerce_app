import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/firestore_cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _currentUserId;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get total => _items.fold(0.0, (sum, item) => sum + item.total);
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  // Initialiser le panier pour l'utilisateur connecté
  Future<void> initializeCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid != _currentUserId) {
      _currentUserId = user.uid;
      await _loadCart();
    } else if (user == null) {
      _currentUserId = null;
      _items.clear();
      notifyListeners();
    }
  }

  // Charger le panier depuis Firestore
  Future<void> _loadCart() async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _items = await FirestoreCartService.getCart();
      notifyListeners();
    } catch (e) {
      print('❌ CART PROVIDER: Erreur lors du chargement du panier: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ajouter un produit au panier
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_currentUserId == null) {
      print(
        '⚠️ CART PROVIDER: Utilisateur non connecté, impossible d\'ajouter au panier',
      );
      return;
    }

    try {
      await FirestoreCartService.addToCart(product, quantity: quantity);
      await _loadCart(); // Recharger le panier depuis Firestore
    } catch (e) {
      print('❌ CART PROVIDER: Erreur lors de l\'ajout au panier: $e');
    }
  }

  // Supprimer un produit du panier
  Future<void> removeFromCart(int productId) async {
    if (_currentUserId == null) {
      print(
        '⚠️ CART PROVIDER: Utilisateur non connecté, impossible de supprimer du panier',
      );
      return;
    }

    try {
      await FirestoreCartService.removeFromCart(productId);
      await _loadCart(); // Recharger le panier depuis Firestore
    } catch (e) {
      print('❌ CART PROVIDER: Erreur lors de la suppression du panier: $e');
    }
  }

  // Mettre à jour la quantité d'un produit
  Future<void> updateQuantity(int productId, int quantity) async {
    if (_currentUserId == null) {
      print(
        '⚠️ CART PROVIDER: Utilisateur non connecté, impossible de mettre à jour le panier',
      );
      return;
    }

    try {
      await FirestoreCartService.updateQuantity(productId, quantity);
      await _loadCart(); // Recharger le panier depuis Firestore
    } catch (e) {
      print('❌ CART PROVIDER: Erreur lors de la mise à jour du panier: $e');
    }
  }

  Future<void> clearCart() async {
    if (_currentUserId == null) {
      print(
        '⚠️ CART PROVIDER: Utilisateur non connecté, impossible de vider le panier',
      );
      return;
    }

    try {
      await FirestoreCartService.clearCart();
      _items.clear();
      notifyListeners();
    } catch (e) {
      print('❌ CART PROVIDER: Erreur lors du vidage du panier: $e');
    }
  }

  CartItem? getItem(int productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.productId == productId);
  }

  int getQuantity(int productId) {
    final item = getItem(productId);
    return item?.quantity ?? 0;
  }

  Future<void> syncWithAPI() async {
    try {
      // En mode debug, on simule juste la synchronisation
      if (kDebugMode) {
        print('Synchronisation du panier avec l\'API...');
        print('Nombre d\'articles: ${_items.length}');
        print('Total: \$${total.toStringAsFixed(2)}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur de synchronisation: $e');
      }
    }
  }
}
