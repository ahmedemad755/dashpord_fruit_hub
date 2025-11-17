import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';

abstract class OrdersRepo {
  Stream<Either<Faliur, List<OrderEntity>>> fetchOrders();

  Future<Either<Faliur, void>> updateOrder({
    required OrderStatus status,
    required String orderID,
  });
}
