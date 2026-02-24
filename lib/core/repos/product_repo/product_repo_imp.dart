import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fruitesdashboard/core/errors/faliur.dart';
import 'package:fruitesdashboard/core/repos/product_repo/product_repo.dart';
import 'package:fruitesdashboard/core/services/cloud_fire_store_service.dart';
import 'package:fruitesdashboard/core/utils/backend_points.dart';
import 'package:fruitesdashboard/featurs/add_product/domain/entities/add_product_intety.dart';
import 'package:fruitesdashboard/featurs/data/models/add_product_input_model.dart';

class ProductRepoImp implements ProductRepo {
  final FireStoreService fireStoreService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProductRepoImp({required this.fireStoreService});

  @override
  Future<Either<Faliur, String>> addProduct(
    AddProductIntety addProductIntety, {
    String? documentId,
  }) async {
    try {
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        return left(ServerFaliur("❌ يجب تسجيل الدخول أولاً"));
      }

      final productModel = AddProductInputModel.fromentity(addProductIntety);
      final Map<String, dynamic> productJson = productModel.toJson();

      productJson['pharmacyId'] = currentPharmacyId;

      final String finalDocId =
          documentId ?? "${addProductIntety.code}_$currentPharmacyId";

      await fireStoreService.addData(
        path: BackendPoints.addProduct,
        data: productJson,
        documentId: finalDocId,
      );

      return right("✅ Product added successfully to Firestore");
    } catch (e, stack) {
      log(
        "❌ Firestore Add Error: $e",
        name: "ProductRepoImp",
        error: e,
        stackTrace: stack,
      );
      return left(ServerFaliur("❌ Failed to add product: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Faliur, List<AddProductIntety>>> getProducts() async {
    try {
      final String? currentPharmacyId = _auth.currentUser?.uid;

      if (currentPharmacyId == null) {
        return left(ServerFaliur("❌ غير مسموح بالوصول"));
      }

      final result = await fireStoreService.getData(
        path: BackendPoints.addProduct,
        query: {'field': 'pharmacyId', 'value': currentPharmacyId},
      );

      final List<dynamic> data = result as List<dynamic>;
      // هنا يتم تحويل الـ List لـ Entities بناءً على الـ Model الخاص بك
      // List<AddProductIntety> products = data.map((e) => AddProductInputModel.fromJson(e)).toList();

      return left(ServerFaliur("دالة التحويل لم تكتمل بعد"));
    } catch (e) {
      return left(ServerFaliur("❌ فشل جلب المنتجات"));
    }
  }
}
