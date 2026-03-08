import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryEntity {
  final String id;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final int quantity;
  final int reorderLevel;
  // ✅ التعديل هنا: جعل الـ type يقبل null
  final DateTime? expiryDate;
  final double costPrice;
  final double sellingPrice;
  final String category;
  final int stockIn;
  final int stockOut;
  final int damaged;

  InventoryEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImageUrl,
    required this.quantity,
    required this.reorderLevel,
    this.expiryDate, // ✅ تم إزالة required هنا
    required this.costPrice,
    required this.sellingPrice,
    required this.category,
    required this.stockIn,
    required this.stockOut,
    required this.damaged,
  });

  bool get isLowStock => quantity <= reorderLevel;

  // ✅ التعديل هنا: التعامل مع الـ null في الـ helper
  bool get isExpiryNear =>
      expiryDate != null && expiryDate!.difference(DateTime.now()).inDays <= 90;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'quantity': quantity,
      'reorder_level': reorderLevel,
      // تحويل الـ DateTime إلى Timestamp ليناسب Firestore
      'expiry_date': expiryDate != null
          ? Timestamp.fromDate(expiryDate!)
          : null,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'category': category,
      'stock_in': stockIn,
      'stock_out': stockOut,
      'damaged': damaged,
    };
  }
}
