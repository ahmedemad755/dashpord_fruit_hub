import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';

abstract class InventoryRepo {
  // الدالة الأساسية: Stream لجلب البيانات لحظياً
  Stream<List<InventoryEntity>> getInventoryStream( String pharmacyId); // تم إضافة pharmacyId كمعامل

  Future<void> updateStockQuantity(String inventoryId, int newQuantity);
  Future<void> addOrUpdateInventory(InventoryEntity inventory);
  Future<void> deleteInventoryItem(String itemId);
}
