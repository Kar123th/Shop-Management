class Sale {
  final String id;
  final String userId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final List<SaleItem> items;
  final double subTotal;
  final double discount;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod; // Cash, Card, UPI
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.userId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subTotal,
    this.discount = 0.0,
    required this.taxAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'sub_total': subTotal,
      'discount': discount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, List<SaleItem> items) {
    return Sale(
      id: map['id'],
      userId: map['user_id'],
      customerId: map['customer_id'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      items: items,
      subTotal: (map['sub_total'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: map['payment_method'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double gstRate;
  final double total;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.gstRate,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'gst_rate': gstRate,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      productName: map['product_name'],
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      gstRate: (map['gst_rate'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
    );
  }
}
