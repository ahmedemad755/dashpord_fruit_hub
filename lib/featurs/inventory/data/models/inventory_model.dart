import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  InventoryModel({
    required super.id,
    required super.productId,
    required super.productName,
    super.productImageUrl,
    required super.quantity,
    required super.reorderLevel,
    super.expiryDate,
    required super.costPrice,
    required super.sellingPrice,
    required super.category,
    required super.stockIn,
    required super.stockOut,
    required super.damaged,
  });

  factory InventoryModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InventoryModel(
      id: doc.id,
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      productImageUrl: data['product_image_url'], // يمكن أن يكون null
      quantity: (data['quantity'] ?? 0).toInt(),
      reorderLevel: (data['reorder_level'] ?? 0).toInt(),
      // التعامل مع الـ Timestamp للـ Nullable expiry_date
      expiryDate: data['expiry_date'] != null
          ? (data['expiry_date'] as Timestamp).toDate()
          : null,
      costPrice: (data['cost_price'] ?? 0.0).toDouble(),
      sellingPrice: (data['selling_price'] ?? 0.0).toDouble(),
      category: data['category'] ?? "تصنيف عام", // ✅ جلب التصنيف
      stockIn: (data['stock_in'] ?? 0).toInt(),
      stockOut: (data['stock_out'] ?? 0).toInt(),
      damaged: (data['damaged'] ?? 0).toInt(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'quantity': quantity,
      'reorder_level': reorderLevel,
      // تحويل DateTime إلى Timestamp لـ Firestore
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
