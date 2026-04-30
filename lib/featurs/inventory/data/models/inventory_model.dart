import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';

class InventoryModel extends InventoryEntity {
  InventoryModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.pharmacyId,
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
      // التعديل هنا: شلنا الـ _ وخليناها CamelCase زي الفايربيز
      productId: data['productId'] ?? '', 
      productName: data['productName'] ?? '', // كانت productname (خطأ)
      productImageUrl: data['productImageUrl'], // كانت productimage_url (خطأ)
      pharmacyId: data['pharmacyId'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      reorderLevel: (data['reorderLevel'] ?? 0).toInt(), // شلنا الـ _
      
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
          
      costPrice: (data['costPrice'] ?? 0.0).toDouble(), // شلنا الـ _
      sellingPrice: (data['sellingPrice'] ?? 0.0).toDouble(), // شلنا الـ _
      category: data['category'] ?? "تصنيف عام",
      
      stockIn: (data['stockIn'] ?? 0).toInt(), // شلنا الـ _
      stockOut: (data['stockOut'] ?? 0).toInt(), // شلنا الـ _
      damaged: (data['damaged'] ?? 0).toInt(), // شلنا الـ _
    );
  }

@override
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'pharmacyId': pharmacyId,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'reorderLevel': reorderLevel,
      'expiryDate': expiryDate != null
          ? Timestamp.fromDate(expiryDate!)
          : null,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'category': category,
      'stockIn': stockIn,
      'stockOut': stockOut,
      'damaged': damaged,
    };
  }
}
