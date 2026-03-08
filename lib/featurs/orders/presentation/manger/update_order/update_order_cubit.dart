// ملف: lib/featurs/orders/presentation/cubit/update_order_cubit/update_order_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:meta/meta.dart';

part 'update_order_state.dart';

class UpdateOrderCubit extends Cubit<UpdateOrderState> {
  UpdateOrderCubit(this.ordersRepo) : super(UpdateOrderInitial());

  final OrdersRepo ordersRepo;

  Future<void> updateOrder({
    required OrderStatus status,
    required String orderID,
    required OrderEntity orderEntity,
  }) async {
    emit(UpdateOrderLoading());

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final docRef = firestore.collection('orders').doc(orderID);

      // 1. تحديث حالة الطلب
      batch.update(docRef, {'status': status.name});

      // 2. إدارة المخزون (كم خرج - Sold) - عند الشحن أو التوصيل
      if (status == OrderStatus.shipped || status == OrderStatus.delivered) {
        for (var product in orderEntity.orderProducts) {
          final productQuery = await firestore
              .collection('products')
              .where('code', isEqualTo: product.code)
              .limit(1)
              .get();

          if (productQuery.docs.isNotEmpty) {
            final productDocRef = productQuery.docs.first.reference;

            // إنقاص الكمية من المخزون الحالي
            batch.update(productDocRef, {
              'unitAmount': FieldValue.increment(-product.quantity),
              // تسجيل حركة خروج
              'stockOut': FieldValue.increment(product.quantity),
            });
          }
        }
      }

      // 3. تحديث المبيعات (Selling Count) - عند التوصيل فقط
      if (status == OrderStatus.delivered) {
        for (var product in orderEntity.orderProducts) {
          final productQuery = await firestore
              .collection('products')
              .where('code', isEqualTo: product.code)
              .limit(1)
              .get();

          if (productQuery.docs.isNotEmpty) {
            final productDocRef = productQuery.docs.first.reference;
            batch.update(productDocRef, {
              'sellingcount': FieldValue.increment(product.quantity),
            });
          }
        }
      }

      await batch.commit();
      emit(UpdateOrderSuccess());
    } catch (e) {
      emit(UpdateOrderFailure("حدث خطأ أثناء التحديث: ${e.toString()}"));
    }
  }
}
