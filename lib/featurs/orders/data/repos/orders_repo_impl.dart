import 'package:dartz/dartz.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';

import '../models/order_model.dart';

class OrdersRepoImpl implements OrdersRepo {
  final DatabaseService _dataService;

  OrdersRepoImpl(this._dataService);

  @override
  Stream<Either<Faliur, List<OrderEntity>>> fetchOrders() async* {
    try {
      await for (var (data as List<Map<String, dynamic>>)
          in _dataService.getDataStream(path: BackendPoints.getOrders)) {
        final List<OrderEntity> orders = (data as List<dynamic>)
            .map<OrderEntity>((e) => OrderModel.fromJson(e).toEntity())
            .toList();
        print("📌 Raw orders data: $data");
        yield Right(orders);
        // debug
      }
    } catch (e) {
      print("🔥 FetchOrders Error: $e");
      yield Left(ServerFaliur('Failed to fetch orders'));
    }
  }

  @override
  Future<Either<Faliur, void>> updateOrder({
    required OrderStatus status,
    required String orderID,
  }) async {
    try {
      await _dataService.updateOrder(
        data: {'status': status.name},
        path: BackendPoints.updateOrder,
        documentId: orderID,
      );
      return right(null);
    } catch (e) {
      return Left(ServerFaliur('Failed to update order'));
    }
  }
}
