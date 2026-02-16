import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
import 'package:meta/meta.dart';

part 'fetch_orders_state.dart';

class FetchOrdersCubit extends Cubit<FetchOrdersState> {
  final OrdersRepo ordersRepo;
  StreamSubscription? _streamSubscription;

  FetchOrdersCubit(this.ordersRepo) : super(FetchOrdersInitial());

  /// جلب الطلبات والاستماع للتحديثات اللحظية
  void fetchOrders() {
    emit(FetchOrdersLoading());

    // إلغاء أي اشتراك قديم قبل بدء واحد جديد لمنع تكرار الـ Streams
    _streamSubscription?.cancel();

    _streamSubscription = ordersRepo.fetchOrders().listen(
      (result) {
        result.fold(
          (failure) => emit(FetchOrdersFailure(failure.message)),
          (orders) => emit(FetchOrdersSuccess(orders: orders)),
        );
      },
      onError: (error) {
        emit(FetchOrdersFailure("حدث خطأ في الاتصال المباشر: $error"));
      },
    );
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
