import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:meta/meta.dart';

part 'update_order_state.dart';

class UpdateOrderCubit extends Cubit<UpdateOrderState> {
  UpdateOrderCubit(this.ordersRepo) : super(UpdateOrderInitial());

  final OrdersRepo ordersRepo;

  /// تحديث حالة الطلب
  Future<void> updateOrder({
    required OrderStatus status,
    required String orderID,
  }) async {
    emit(UpdateOrderLoading());
    print('🟢 Start updating order: $orderID to status: ${status.name}');

    try {
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderID);

      // 1️⃣ تحقق إذا الدوكمنت موجود أصلاً
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        final errMsg = '❌ Document with ID $orderID does not exist!';
        print(errMsg);
        emit(UpdateOrderFailure(errMsg));
        return;
      }

      // 2️⃣ عمل الـ update
      await docRef.update({'status': status.name});
      print('✅ Order $orderID updated successfully to ${status.name}');

      emit(UpdateOrderSuccess());
    } catch (e, st) {
      print('❌ Update failed for order $orderID: $e');
      print('StackTrace: $st');
      emit(UpdateOrderFailure(e.toString()));
    }
  }
}
