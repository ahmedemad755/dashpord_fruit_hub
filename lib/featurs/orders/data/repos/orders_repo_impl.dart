import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_product_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';

import '../models/order_model.dart';

class OrdersRepoImpl implements OrdersRepo {
  final DatabaseService _dataService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OrdersRepoImpl(this._dataService);

  @override
  Stream<Either<Faliur, List<OrderEntity>>> fetchOrders() async* {
    try {
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        yield Left(ServerFaliur('لم يتم العثور على صيدلية مسجلة دخول'));
        return;
      }

      final Stream<dynamic> stream = _dataService.getDataStream(
        path: BackendPoints.getOrders,
        query: {'field': 'pharmacyId', 'value': currentPharmacyId},
      );

      await for (var snapshot in stream) {
        final List<dynamic> data = snapshot as List<dynamic>;
        final List<OrderEntity> orders = data.map<OrderEntity>((e) {
          return OrderModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ).toEntity();
        }).toList();

        yield Right(orders);
      }
    } catch (e) {
      print("🔥 FetchOrders Error: $e");
      yield Left(ServerFaliur('فشل في جلب الطلبات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Faliur, void>> updateOrderWithProducts({
    required String orderID,
    required List<OrderProductEntity> products,
    required double totalPrice,
  }) async {
    try {
      await _dataService.updateOrder(
        path: BackendPoints.updateOrder,
        documentId: orderID,
        data: {
          'orderProducts': products.map((e) => e.toJson()).toList(),
          'totalPrice': totalPrice,
          'status': OrderStatus.shipped.name, // تتحول لشحن فوراً بعد التسعير
        },
      );
      return right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في تحديث بيانات الروشتة'));
    }
  }

  @override
  Future<Either<Faliur, void>> updateOrder({
    required OrderStatus status,
    required String orderID,
  }) async {
    try {
      // 1. تجهيز البيانات الأساسية للتحديث (تغيير الحالة)
      Map<String, dynamic> updateData = {
        'status': status.name,
      };

      // 2. 👈 إذا كانت الحالة "ملغي"، نحدد أن الصيدلية هي من قامت بذلك
      if (status == OrderStatus.canceled) {
        updateData['cancelledBy'] = 'pharmacy';
      }

      await _dataService.updateOrder(
        data: updateData,
        path: BackendPoints.updateOrder,
        documentId: orderID,
      );
      
      return right(null);
    } catch (e) {
      return Left(ServerFaliur('فشل في تحديث حالة الطلب'));
    }
  }
}