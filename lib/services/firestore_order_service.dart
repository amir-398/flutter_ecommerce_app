import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as order_model;
import '../models/cart.dart';
import '../models/product.dart';

class FirestoreOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  // Obtenir l'ID de l'utilisateur actuel
  static String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Créer une nouvelle commande
  static Future<order_model.Order> createOrder({
    required List<CartItem> items,
    required double total,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    try {
      // Générer un ID unique pour la commande
      final orderId = _firestore.collection(_ordersCollection).doc().id;

      // Créer une copie des items avec les détails complets du produit
      final orderItems = <CartItem>[];

      for (final item in items) {
        if (item.product != null) {
          // Le produit est déjà présent
          orderItems.add(item);
        } else {
          // Créer un produit temporaire (en production, récupérer depuis l'API)
          orderItems.add(
            CartItem(
              productId: item.productId,
              quantity: item.quantity,
              product: Product(
                id: item.productId,
                title: 'Produit #${item.productId}',
                price: 0.0,
                description: 'Produit commandé',
                category: 'Inconnue',
                image: '',
                rating: Rating(rate: 0.0, count: 0),
              ),
            ),
          );
        }
      }

      final order = order_model.Order(
        id: orderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        items: orderItems,
        total: total,
        status: order_model.OrderStatus.pending,
        paymentStatus: order_model.PaymentStatus.pending,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // Sauvegarder dans Firestore avec l'userId
      final orderData = order.toFirestoreMap();
      orderData['userId'] = userId;

      await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .set(orderData);

      return order;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  // Récupérer les commandes de l'utilisateur connecté
  static Future<List<order_model.Order>> getOrders() async {
    final userId = _currentUserId;
    if (userId == null) {
      print(
        '⚠️ ORDER SERVICE: Utilisateur non connecté, retour d\'une liste vide',
      );
      return [];
    }

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => order_model.Order.fromFirestoreMap(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  // Récupérer une commande par ID
  static Future<order_model.Order?> getOrderById(String orderId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();

      if (doc.exists) {
        return order_model.Order.fromFirestoreMap(
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors du chargement de la commande: $e');
    }
  }

  // Mettre à jour le statut d'une commande
  static Future<bool> updateOrderStatus(
    String orderId,
    order_model.OrderStatus status,
  ) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Mettre à jour le statut de paiement
  static Future<bool> updatePaymentStatus(
    String orderId,
    order_model.PaymentStatus status,
  ) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'paymentStatus': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Écouter les changements de commandes en temps réel
  static Stream<List<order_model.Order>> getOrdersStream() {
    final userId = _currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_ordersCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => order_model.Order.fromFirestoreMap(doc.data()))
              .toList(),
        );
  }

  // Supprimer une commande
  static Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Supprimer toutes les commandes (pour les tests)
  static Future<void> clearAllOrders() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_ordersCollection)
          .get();

      final WriteBatch batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des commandes: $e');
    }
  }

  // Mettre à jour les détails d'un produit dans une commande
  static Future<void> updateProductDetailsInOrder(
    String orderId,
    int productId,
    Product product,
  ) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) return;

      final updatedItems = order.items.map((item) {
        if (item.productId == productId) {
          return CartItem(
            productId: item.productId,
            quantity: item.quantity,
            product: product,
          );
        }
        return item;
      }).toList();

      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'items': updatedItems.map((item) => item.toFirestoreMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }
}
