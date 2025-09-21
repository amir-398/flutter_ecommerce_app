import '../models/order.dart';
import '../models/cart.dart';
import 'api_service.dart';
import 'firestore_order_service.dart';

class OrderService {
  // Délégation vers le service Firestore

  // Sauvegarder une commande
  static Future<Order> createOrder({
    required List<CartItem> items,
    required double total,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    // Déléguer vers FirestoreOrderService
    return await FirestoreOrderService.createOrder(
      items: items,
      total: total,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  // Récupérer toutes les commandes
  static Future<List<Order>> getOrders() async {
    return await FirestoreOrderService.getOrders();
  }

  // Récupérer une commande par ID
  static Future<Order?> getOrderById(String orderId) async {
    return await FirestoreOrderService.getOrderById(orderId);
  }

  // Mettre à jour le statut d'une commande
  static Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return await FirestoreOrderService.updateOrderStatus(orderId, status);
  }

  // Mettre à jour le statut de paiement
  static Future<bool> updatePaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {
    return await FirestoreOrderService.updatePaymentStatus(orderId, status);
  }

  // Simuler un paiement (mock)
  static Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    // Simuler un délai de traitement
    await Future.delayed(const Duration(seconds: 2));

    // Mock de validation de carte
    final isValidCard = _validateCard(cardNumber, expiryDate, cvv);

    if (!isValidCard) {
      return PaymentResult(
        success: false,
        message: 'Informations de carte invalides',
        transactionId: null,
      );
    }

    // Simuler un échec aléatoire (5% de chance)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 5) {
      return PaymentResult(
        success: false,
        message: 'Paiement refusé par la banque',
        transactionId: null,
      );
    }

    // Paiement réussi
    final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

    // Mettre à jour le statut de paiement
    await updatePaymentStatus(orderId, PaymentStatus.paid);
    await updateOrderStatus(orderId, OrderStatus.confirmed);

    return PaymentResult(
      success: true,
      message: 'Paiement effectué avec succès',
      transactionId: transactionId,
    );
  }

  // Validation simple de carte (mock)
  static bool _validateCard(String cardNumber, String expiryDate, String cvv) {
    // Supprimer les espaces et tirets
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Vérifier que la carte a 16 chiffres
    if (cleanCardNumber.length != 16) return false;

    // Vérifier que tous les caractères sont des chiffres
    if (!RegExp(r'^\d+$').hasMatch(cleanCardNumber)) return false;

    // Vérifier la date d'expiration (format MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;

    // Vérifier le CVV (3 ou 4 chiffres)
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) return false;

    return true;
  }

  // Récupérer les détails des produits pour une commande
  static Future<void> loadProductDetailsForOrder(String orderId) async {
    // Cette méthode n'est plus nécessaire avec Firestore car les détails sont stockés
    // Mais on peut l'utiliser pour mettre à jour les détails depuis l'API
    final order = await getOrderById(orderId);
    if (order == null) return;

    for (final item in order.items) {
      if (item.product == null || item.product!.title.startsWith('Produit #')) {
        try {
          final product = await ApiService.getProduct(item.productId);
          await FirestoreOrderService.updateProductDetailsInOrder(
            orderId,
            item.productId,
            product,
          );
        } catch (e) {
          // Ignorer les erreurs
        }
      }
    }
  }

  // Forcer le rechargement de tous les détails des produits pour toutes les commandes
  static Future<void> reloadAllProductDetails() async {
    final orders = await getOrders();

    for (final order in orders) {
      for (final item in order.items) {
        if (item.product == null ||
            item.product!.title.startsWith('Produit #')) {
          try {
            final product = await ApiService.getProduct(item.productId);
            await FirestoreOrderService.updateProductDetailsInOrder(
              order.id,
              item.productId,
              product,
            );
          } catch (e) {
            // Ignorer les erreurs
          }
        }
      }
    }
  }

  // Méthode de debug pour afficher les détails des commandes
  static Future<void> debugOrders() async {
    final orders = await getOrders();
    print('=== DEBUG ORDERS ===');
    for (final order in orders) {
      print('Commande ${order.id}:');
      print('  Total: ${order.total}');
      print('  Items count: ${order.items.length}');
      for (final item in order.items) {
        print('    Item ${item.productId}:');
        print('      Quantity: ${item.quantity}');
        print('      Product: ${item.product?.title ?? "NULL"}');
        print('      Product price: ${item.product?.price ?? "NULL"}');
      }
      print('  Total items: ${order.totalItems}');
      print('---');
    }
    print('==================');
  }

  // Supprimer toutes les commandes (pour les tests)
  static Future<void> clearAllOrders() async {
    await FirestoreOrderService.clearAllOrders();
  }

  // Écouter les changements de commandes en temps réel
  static Stream<List<Order>> getOrdersStream() {
    return FirestoreOrderService.getOrdersStream();
  }
}

class PaymentResult {
  final bool success;
  final String message;
  final String? transactionId;

  PaymentResult({
    required this.success,
    required this.message,
    this.transactionId,
  });
}
