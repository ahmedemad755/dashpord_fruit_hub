import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔹 أضفنا هذا السطر
import 'package:fruitesdashboard/core/enums/order_enum.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/services/database_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/enteties/order_entety.dart';
import 'package:fruitesdashboard/featurs/orders/data/domain/repos/order_repo.dart';

import '../models/order_model.dart';

class OrdersRepoImpl implements OrdersRepo {
  final DatabaseService _dataService;
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // 🔹 أضفنا الوصول لـ Firebase Auth

  OrdersRepoImpl(this._dataService);

  @override
  Stream<Either<Faliur, List<OrderEntity>>> fetchOrders() async* {
    try {
      // 1. الحصول على الـ uId الخاص بالصيدلية الحالية (هو نفسه الـ pharmacyId)
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        yield Left(ServerFaliur('لم يتم العثور على صيدلية مسجلة دخول'));
        return;
      }

      // 2. تمرير الـ query لفلترة الطلبات بحيث تظهر طلبات هذه الصيدلية فقط
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
      return Left(ServerFaliur('فشل في تحديث حالة الطلب'));
    }
  }
}
