import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

part 'fetch_orders_state.dart';

class FetchOrdersCubit extends Cubit<FetchOrdersState> {
  FetchOrdersCubit(this.ordersRepo) : super(FetchOrdersInitial());

  final OrdersRepo ordersRepo;
  StreamSubscription? _streamSubscription;

  /// Fetch orders and listen for real-time updates
  void fetchOrders() {
    emit(FetchOrdersLoading());

    _streamSubscription = ordersRepo.fetchOrders().listen(
      (result) => result.fold(
        (failure) => emit(FetchOrdersFailure(failure.message)),
        (orders) => emit(FetchOrdersSuccess(orders: orders)),
      ),
    );
  }

  /// Clean up stream when cubit is closed
  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    return super.close();
  }
}
