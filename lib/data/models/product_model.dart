class Product {
  final String id;
  final String userId;
  final String? categoryId;
  final String name;
  final String? description;
  final String? barcode;
  final String? sku;
  final String? hsnCode;
  final String unit;
  final double salePrice;
  final double? purchasePrice;
  final double gstRate;
  final double stockQuantity;
  final double lowStockAlert;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.name,
    this.description,
    this.barcode,
    this.sku,
    this.hsnCode,
    this.unit = 'Pcs',
    required this.salePrice,
    this.purchasePrice,
    this.gstRate = 0,
    this.stockQuantity = 0,
    this.lowStockAlert = 5,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      categoryId: map['category_id'],
      name: map['name'] ?? '',
      description: map['description'],
      barcode: map['barcode'],
      sku: map['sku'],
      hsnCode: map['hsn_code'],
      unit: map['unit'] ?? 'Pcs',
      salePrice: (map['sale_price'] ?? 0).toDouble(),
      purchasePrice: map['purchase_price'] != null ? (map['purchase_price'] as num).toDouble() : null,
      gstRate: (map['gst_rate'] ?? 0).toDouble(),
      stockQuantity: (map['stock_quantity'] ?? 0).toDouble(),
      lowStockAlert: (map['low_stock_alert'] ?? 5).toDouble(),
      imageUrl: map['image_url'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'barcode': barcode,
      'sku': sku,
      'hsn_code': hsnCode,
      'unit': unit,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'gst_rate': gstRate,
      'stock_quantity': stockQuantity,
      'low_stock_alert': lowStockAlert,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
