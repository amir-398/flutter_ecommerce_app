import '../models/order.dart';
import '../models/cart.dart';
import 'api_service.dart';
import 'firestore_order_service.dart';

class OrderService {
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

  static Future<List<Order>> getOrders() async {
    return await FirestoreOrderService.getOrders();
  }

  static Future<Order?> getOrderById(String orderId) async {
    return await FirestoreOrderService.getOrderById(orderId);
  }

  static Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return await FirestoreOrderService.updateOrderStatus(orderId, status);
  }

  static Future<bool> updatePaymentStatus(
    String orderId,
    PaymentStatus status,
  ) async {
    return await FirestoreOrderService.updatePaymentStatus(orderId, status);
  }

  static Future<PaymentResult> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final isValidCard = _validateCard(cardNumber, expiryDate, cvv);

    if (!isValidCard) {
      return PaymentResult(
        success: false,
        message: 'Informations de carte invalides',
        transactionId: null,
      );
    }

    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 5) {
      return PaymentResult(
        success: false,
        message: 'Paiement refusé par la banque',
        transactionId: null,
      );
    }

    final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

    await updatePaymentStatus(orderId, PaymentStatus.paid);
    await updateOrderStatus(orderId, OrderStatus.confirmed);

    return PaymentResult(
      success: true,
      message: 'Paiement effectué avec succès',
      transactionId: transactionId,
    );
  }

  static bool _validateCard(String cardNumber, String expiryDate, String cvv) {
    final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    if (cleanCardNumber.length != 16) return false;

    if (!RegExp(r'^\d+$').hasMatch(cleanCardNumber)) return false;

    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDate)) return false;

    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) return false;

    return true;
  }

  static Future<void> loadProductDetailsForOrder(String orderId) async {
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
        }
      }
    }
  }

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
          }
        }
      }
    }
  }

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

  static Future<void> clearAllOrders() async {
    await FirestoreOrderService.clearAllOrders();
  }

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
