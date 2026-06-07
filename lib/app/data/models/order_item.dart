class OrderItem {
  final String id;
  final int orderId;
  final String? productId;
  final String productTitle;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productTitle,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      orderId: (json['order_id'] as num? ?? 0).toInt(),
      productId: json['product_id'] as String?,
      productTitle: json['product_title'] as String? ?? '',
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      unitPrice: (json['unit_price'] as num? ?? 0.0).toDouble(),
      totalPrice: (json['total_price'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_title': productTitle,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
