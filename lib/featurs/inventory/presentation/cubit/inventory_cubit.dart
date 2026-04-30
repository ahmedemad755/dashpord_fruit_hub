// lib/featurs/inventory/presentation/cubit/inventory_cubit.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/cubit/inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepo _inventoryRepo;
  StreamSubscription? _inventorySubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InventoryCubit(this._inventoryRepo) : super(InventoryInitial());

  void getInventory(String pharmacyId) {
    if (pharmacyId.isEmpty) return;
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    
    _inventorySubscription = _inventoryRepo.getInventoryStream(pharmacyId).listen((inventoryList) {
      final activeItems = inventoryList.where((item) => item.quantity > 0).toList();
      emit(InventoryLoaded(activeItems));
    }, onError: (error) => emit(InventoryError(error.toString())));
  }

  // --- تحديث الكمية (توالف/توريد للمخزن) ---
  Future<void> updateInventoryQuantity(InventoryEntity item, int amount, bool isSupply) async {
    try {
      final batch = _firestore.batch();
      
      // بناءً على بياناتك: الـ inventory موجود في الـ Root مباشرة
      final inventoryRef = _firestore.collection(BackendPoints.inventory).doc(item.id);
      final productRef = _firestore.collection(BackendPoints.getProducts).doc(item.productId);

      if (isSupply) {
        // زيادة في المخزن + زيادة في المعروض (unitAmount)
        batch.update(inventoryRef, {
          'quantity': FieldValue.increment(amount),
          'stock_in': FieldValue.increment(amount), // تعديل لـ snake_case
        });
        batch.update(productRef, {'unitAmount': FieldValue.increment(amount)});
      } else {
        // توالف: نقص من المخزن + نقص من المعروض
        if (item.quantity - amount <= 0) {
          batch.delete(inventoryRef);
        } else {
          batch.update(inventoryRef, {
            'quantity': FieldValue.increment(-amount),
            'damaged': FieldValue.increment(amount),
          });
        }
        batch.update(productRef, {'unitAmount': FieldValue.increment(-amount)});
      }

      await batch.commit();
    } catch (e) {
      emit(InventoryError("فشل التحديث: ${e.toString()}"));
    }
  }

  // --- عملية التوريد (نقل من المخزن للمتجر) ✅ النقطة اللي بتسأل عنها ---
// --- عملية التوريد (نقل من المخزن للمتجر) ---
Future<void> transferStockToProduct(InventoryEntity item, int amount) async {
  try {
    emit(InventoryLoading()); // لإظهار مؤشر التحميل في الـ UI
    
    final batch = _firestore.batch();
    
    // 1. مراجع الوثائق
    final inventoryRef = _firestore.collection(BackendPoints.inventory).doc(item.id);
    final productRef = _firestore.collection(BackendPoints.getProducts).doc(item.productId);
    final expiredLogRef = _firestore.collection('expired_logs').doc(); // سجل الهالك للتحليل

    // 2. جلب بيانات المنتج الحالي للتحقق من الصلاحية
    final productSnap = await productRef.get();
    bool isCurrentProductExpired = false;
    Map<String, dynamic>? currentProductData;

    if (productSnap.exists) {
      currentProductData = productSnap.data() as Map<String, dynamic>;
      final Timestamp? expiryTimestamp = currentProductData['expirationDate'];
      
      if (expiryTimestamp != null && expiryTimestamp.toDate().isBefore(DateTime.now())) {
        isCurrentProductExpired = true;
      }
    }

    // 3. منطق تحديث المنتج (Product Collection)
    if (isCurrentProductExpired && currentProductData != null) {
      // أ- حفظ الكمية المنتهية في سجل الهالك (Analytics)
      batch.set(expiredLogRef, {
        'productId': item.productId,
        'productName': item.productName,
        'quantityExpired': currentProductData['unitAmount'] ?? 0,
        'lostRevenue': (currentProductData['unitAmount'] ?? 0) * (currentProductData['price'] ?? 0),
        'expiryDate': currentProductData['expirationDate'],
        'movedAt': FieldValue.serverTimestamp(),
        'pharmacyId': item.pharmacyId,
        'reason': 'Auto-replaced by fresh stock',
      });

      // ب- إحلال المنتج: مسح الكمية التالفة ووضع الكمية الجديدة والتاريخ الجديد
      batch.update(productRef, {
        'unitAmount': amount, // نضع الكمية الموردة فقط (تصفير التالف ضمنياً)
        'expirationDate': Timestamp.fromDate(item.expiryDate!), // تحديث لتاريخ المخزن الجديد
        'price': item.sellingPrice,
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    } else {
      // ج- التوريد العادي (المنتج الحالي سليم أو جديد)
      batch.update(productRef, {
        'unitAmount': FieldValue.increment(amount),
        'expirationDate': Timestamp.fromDate(item.expiryDate!), // تحديث لأحدث تاريخ
        'lastUpdate': FieldValue.serverTimestamp(),
      });
    }

    // 4. تحديث أو حذف من المخزن (Inventory Collection)
    if (item.quantity - amount <= 0) {
      batch.delete(inventoryRef);
    } else {
      batch.update(inventoryRef, {
        'quantity': FieldValue.increment(-amount),
        'stock_out': FieldValue.increment(amount),
      });
    }

    // 5. تنفيذ العمليات
    await batch.commit();

    // // 6. تحديث الحالة في الـ Cubit
    getInventory(item.pharmacyId);
    emit(InventoryLoaded((state as InventoryLoaded).inventoryList)); // إعادة تحميل البيانات بعد التحديث
    
  } catch (e) {
    emit(InventoryError( "حدث خطأ أثناء التوريد: ${e.toString()}"));
  }
}

  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _inventoryRepo.deleteInventoryItem(itemId);
    } catch (e) {
      emit(InventoryError("فشل الحذف: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}