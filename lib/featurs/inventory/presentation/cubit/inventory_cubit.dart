// lib/featurs/inventory/presentation/cubit/inventory_cubit.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';
import 'package:fruitesdashboard/featurs/inventory/domain/repos/inventory_repo.dart';
import 'package:fruitesdashboard/featurs/inventory/presentation/cubit/inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepo _inventoryRepo;
  StreamSubscription? _inventorySubscription;

  InventoryCubit(this._inventoryRepo) : super(InventoryInitial());

  void getInventory() {
    emit(InventoryLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _inventoryRepo.getInventoryStream().listen((
      inventoryList,
    ) {
      // فلترة المنتجات التي كميتها صفر تلقائياً قبل العرض
      final activeItems = inventoryList
          .where((item) => item.quantity > 0)
          .toList();
      emit(InventoryLoaded(activeItems));
    }, onError: (error) => emit(InventoryError(error.toString())));
  }

  // --- تحديث الكمية (توالف/توريد) مع حذف تلقائي عند الصفر ---
  Future<void> updateInventoryQuantity(
    InventoryEntity item,
    int amount,
    bool isSupply,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final inventoryRef = firestore.collection('inventory').doc(item.id);
      final productRef = firestore.collection('products').doc(item.productId);

      if (isSupply) {
        batch.update(inventoryRef, {
          'quantity': FieldValue.increment(amount),
          'stock_in': FieldValue.increment(amount),
        });
        batch.update(productRef, {'unitAmount': FieldValue.increment(amount)});
      } else {
        // في حالة التوالف: إذا كانت الكمية المتبقية ستصبح صفر أو أقل، نحذف المستند
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

  // --- نقل للمتجر مع حذف تلقائي عند الصفر ---
  Future<void> transferStockToProduct(InventoryEntity item, int amount) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final inventoryRef = firestore.collection('inventory').doc(item.id);
      final productRef = firestore.collection('products').doc(item.productId);

      if (item.quantity - amount <= 0) {
        batch.delete(inventoryRef);
      } else {
        batch.update(inventoryRef, {
          'quantity': FieldValue.increment(-amount),
          'stock_out': FieldValue.increment(amount),
        });
      }

      batch.update(productRef, {'unitAmount': FieldValue.increment(amount)});
      await batch.commit();
    } catch (e) {
      emit(InventoryError("فشل النقل: ${e.toString()}"));
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
