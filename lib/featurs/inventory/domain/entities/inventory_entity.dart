  import 'package:cloud_firestore/cloud_firestore.dart';

  class InventoryEntity {
    final String id;
    final String productId;
    final String pharmacyId;
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
      required this.pharmacyId,
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
      // 'id' غالباً لا يتم تخزينه داخل الـ document لأنه هو الـ Document ID نفسه
      'productId': productId,       // ✅ تم التعديل من product_id لـ productId
      'productName': productName,   // ✅ تم التعديل من productname لـ productName
      'productImageUrl': productImageUrl, // ✅ تم التعديل من product_image_url
      'pharmacyId': pharmacyId,
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
