import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart.dart';
import '../models/product.dart';

class FirestoreCartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cartsCollection = 'carts';

  static String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  static Future<void> saveCart(List<CartItem> items) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final cartData = {
        'userId': userId,
        'items': items.map((item) => item.toFirestoreMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'total': items.fold<double>(0.0, (sum, item) => sum + item.total),
        'itemCount': items.fold<int>(0, (sum, item) => sum + item.quantity),
      };

      await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .set(cartData, SetOptions(merge: true));

      print('🛒 CART SERVICE: Panier sauvegardé pour l\'utilisateur $userId');
    } catch (e) {
      print('❌ CART SERVICE: Erreur lors de la sauvegarde du panier: $e');
      throw Exception('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  static Future<List<CartItem>> getCart() async {
    final userId = _currentUserId;
    if (userId == null) {
      print(
        '⚠️ CART SERVICE: Utilisateur non connecté, retour d\'un panier vide',
      );
      return [];
    }

    try {
      final doc = await _firestore
          .collection(_cartsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        print(
          '📝 CART SERVICE: Aucun panier trouvé pour l\'utilisateur $userId',
        );
        return [];
      }

      final data = doc.data()!;
      final items = (data['items'] as List)
          .map((item) => CartItem.fromFirestoreMap(item))
          .toList();

      print(
        '🛒 CART SERVICE: Panier récupéré pour l\'utilisateur $userId: ${items.length} articles',
      );
      return items;
    } catch (e) {
      print('❌ CART SERVICE: Erreur lors de la récupération du panier: $e');
      throw Exception('Erreur lors de la récupération du panier: $e');
    }
  }

  static Stream<List<CartItem>> getCartStream() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore.collection(_cartsCollection).doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return <CartItem>[];
      }

      final data = snapshot.data()!;
      return (data['items'] as List)
          .map((item) => CartItem.fromFirestoreMap(item))
          .toList();
    });
  }

  static Future<void> clearCart() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      await _firestore.collection(_cartsCollection).doc(userId).delete();

      print('🗑️ CART SERVICE: Panier vidé pour l\'utilisateur $userId');
    } catch (e) {
      print('❌ CART SERVICE: Erreur lors du vidage du panier: $e');
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }

  static Future<void> addToCart(Product product, {int quantity = 1}) async {
    final currentItems = await getCart();

    final existingItemIndex = currentItems.indexWhere(
      (item) => item.productId == product.id,
    );

    List<CartItem> updatedItems;
    if (existingItemIndex >= 0) {
      updatedItems = List.from(currentItems);
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex]
          .copyWith(
            quantity: updatedItems[existingItemIndex].quantity + quantity,
            product: product,
          );
    } else {
      updatedItems = [
        ...currentItems,
        CartItem(productId: product.id, quantity: quantity, product: product),
      ];
    }

    await saveCart(updatedItems);
  }

  static Future<void> removeFromCart(int productId) async {
    final currentItems = await getCart();
    final updatedItems = currentItems
        .where((item) => item.productId != productId)
        .toList();
    await saveCart(updatedItems);
  }

  static Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final currentItems = await getCart();
    final itemIndex = currentItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (itemIndex >= 0) {
      final updatedItems = List<CartItem>.from(currentItems);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        quantity: quantity,
      );
      await saveCart(updatedItems);
    }
  }

  static Future<int> getItemCount() async {
    final items = await getCart();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  static Future<double> getTotal() async {
    final items = await getCart();
    return items.fold<double>(0.0, (sum, item) => sum + item.total);
  }
}
