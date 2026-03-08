import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/featurs/inventory/data/models/inventory_model.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';

class InventoryRepoImpl implements InventoryRepo {
  final DatabaseService databaseService; // بفرض أنك تستخدمه داخل الـ repo

  InventoryRepoImpl(this.databaseService);

  @override
  Stream<List<InventoryEntity>> getInventoryStream() {
    return FirebaseFirestore.instance
        .collection('inventory') // ✅ الكوليكشن الصحيح
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => InventoryModel.fromDocument(doc))
              .toList();
        });
  }

  @override
  Future<void> updateStockQuantity(String inventoryId, int newQuantity) async {
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(inventoryId)
        .update({'quantity': newQuantity});
  }

  @override
  Future<void> deleteInventoryItem(String inventoryId) async {
    await FirebaseFirestore.instance
        .collection('inventory')
        .doc(inventoryId)
        .delete();
  }

  // تم تعديلها لتتوافق مع الـ Entity والـ Model الجديد
  @override
  Future<void> addOrUpdateInventory(InventoryEntity inventory) async {
    final model = InventoryModel(
      id: inventory.id,
      productId: inventory.productId,
      productName: inventory.productName,
      productImageUrl: inventory.productImageUrl,
      quantity: inventory.quantity,
      reorderLevel: inventory.reorderLevel,
      expiryDate: inventory.expiryDate,
      costPrice: inventory.costPrice,
      sellingPrice: inventory.sellingPrice,
      category: inventory.category,
      stockIn: inventory.stockIn,
      stockOut: inventory.stockOut,
      damaged: inventory.damaged,
    );

    if (model.id.isEmpty) {
      await FirebaseFirestore.instance
          .collection('inventory')
          .add(model.toMap());
    } else {
      await FirebaseFirestore.instance
          .collection('inventory')
          .doc(model.id)
          .update(model.toMap());
    }
  }
}
