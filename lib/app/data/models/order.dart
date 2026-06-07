import 'order_item.dart';

class Order {
  final int id;
  final String? userId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String shippingAddress;
  final String paymentMethod;
  final String status; // 'pending', 'confirmed', 'processing', 'packed', 'shipped', 'delivered', 'cancelled'
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.userId,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    if (json['order_items'] != null && json['order_items'] is List) {
      orderItems = (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return Order(
      id: (json['id'] as num? ?? 0).toInt(),
      userId: json['user_id'] as String?,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      customerEmail: json['customer_email'] as String?,
      shippingAddress: json['shipping_address'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? 'COD',
      status: json['status'] as String? ?? 'pending',
      totalAmount: (json['total_amount'] as num? ?? 0.0).toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : DateTime.now(),
      items: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id > 0) 'id': id,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'status': status,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
