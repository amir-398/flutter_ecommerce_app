import 'cart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

enum PaymentStatus { pending, paid, failed, refunded }

class Order {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String paymentMethod;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    required this.paymentMethod,
    this.trackingNumber,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  // Méthodes pour Firestore
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'items': items.map((item) => item.toFirestoreMap()).toList(),
      'total': total,
      'status': status.toString().split('.').last,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  factory Order.fromFirestoreMap(Map<String, dynamic> data) {
    return Order(
      id: data['id'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      items: (data['items'] as List)
          .map((item) => CartItem.fromFirestoreMap(item))
          .toList(),
      total: (data['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      ),
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      trackingNumber: data['trackingNumber'],
      notes: data['notes'],
    );
  }

  Order copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CartItem>? items,
    double? total,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? paymentMethod,
    String? trackingNumber,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.processing:
        return 'En cours de traitement';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.paid:
        return 'Payé';
      case PaymentStatus.failed:
        return 'Échec';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
